use ::std::{
    borrow::Cow,
    collections::HashMap,
    env, fs, io,
    path::{Path, PathBuf},
    process,
    process::{ExitCode, ExitStatus, Stdio},
    result,
};

use ::error_stack::ResultExt as _;

use crate::{error, ext, wrapper::Wrapper, Error, Result};

#[derive(Clone, Debug, ::serde::Deserialize, ::serde::Serialize)]
pub(crate) struct Digest<'a> {
    path: &'a Path,
    digest: &'a str,
}

#[derive(Debug, ::serde::Deserialize, ::serde::Serialize)]
pub(crate) struct Metadata<'a> {
    version: u8,
    #[serde(borrow)]
    digests: Vec<Digest<'a>>,
}

struct MetadataMapMarker;
type MetadataMap<'a> = Wrapper<HashMap<PathBuf, &'a str>, MetadataMapMarker>;

impl<'a> TryFrom<Metadata<'a>> for MetadataMap<'a> {
    type Error = io::Error;

    fn try_from(metadata: Metadata<'a>) -> result::Result<Self, Self::Error> {
        metadata
            .digests
            .into_iter()
            .filter_map(|digest| match digest.path.canonicalize() {
                Ok(path) => Some(Ok((path, digest.digest))),
                Err(err) if matches!(err.kind(), io::ErrorKind::NotFound) => None,
                Err(err) => Some(Err(err)),
            })
            .collect::<io::Result<HashMap<_, _>>>()
            .map(Self::new)
    }
}

impl MetadataMap<'_> {
    fn keep_diff(&self, input: &str, state: &Self) -> Result<Option<PathBuf>> {
        let input = Path::new(input).canonicalize()?;
        match state.0.get(&input) {
            Some(state) => {
                let metadata = self
                    .0
                    .get(&input)
                    .ok_or(Error::External(error::External::Invariant))
                    .attach_printable_lazy(|| {
                        format!(
                            "expected all inputs to have a metadata entry but `{}` did not",
                            input.display(),
                        )
                    })?;

                Ok(if metadata == state { None } else { Some(input) })
            }
            _ => Ok(Some(input)),
        }
    }
}

#[derive(Debug, ::serde::Deserialize, ::serde::Serialize)]
pub(crate) struct IncrementalCommand<'a> {
    program: &'a str,
    // These are `Cow<'a, str>`s (as opposed to `&'a str`s) because it isn't
    // unreasonable for an argument to contain an escape sequence.
    args: Vec<Cow<'a, str>>,
    inputs: Vec<&'a str>,
    state: &'a Path,
}

impl IncrementalCommand<'_> {
    fn exec(&self) -> Result<Option<ExitStatus>> {
        let metadata = env::var("CXXRS_METADATA")?;

        let state = fs::read_to_string(self.state);
        fs::rename(&metadata, self.state)?;

        if self.inputs.is_empty() {
            return Ok(None);
        }

        let mut cmd = process::Command::new(self.program);
        cmd.args(self.args.iter().map(AsRef::as_ref));

        match state {
            Ok(state) => 'ok: {
                let state = ::serde_json::from_str::<Metadata>(&state)?;

                let metadata = fs::read_to_string(self.state)?;
                let metadata = ::serde_json::from_str::<Metadata>(&metadata)?;

                if metadata.version != state.version {
                    ext::Command::args(&mut cmd, &self.inputs);
                    break 'ok;
                }

                let state = state.try_into()?;
                let metadata: MetadataMap = metadata.try_into()?;

                let inputs = self
                    .inputs
                    .iter()
                    .filter_map(|input| metadata.keep_diff(input, &state).transpose())
                    .collect::<Result<Vec<_>>>()?;

                if inputs.is_empty() {
                    return Ok(None);
                }

                ext::Command::args(&mut cmd, &inputs);
            }

            Err(err) if matches!(err.kind(), io::ErrorKind::NotFound) => {
                ext::Command::args(&mut cmd, &self.inputs);
            }

            Err(err) => return Err(err.into()),
        };

        let exit_status = cmd.stdin(Stdio::null()).status()?;
        Ok(Some(exit_status))
    }
}

// This is an intentionally naïve implementation, here are some ideas to make it
// more useful/robust:
//
// 1. Similar to [`xargs`][0],
//
//    - handle command-line length limits, see
//      `xargs --no-run-if-empty --show-limits </dev/null`; and
//
//    - on a similar note, allow chunking the input and running multiple instances
//      of the command on these chunks in parallel.
//
// 2. Allow setting standard output and standard error for the command.
//
// 3. Allow more refined control over cache invalidation by specifying exit
//    statuses to be allowed, for example.
//
// 4. Use a different format for the state; right now, we use the metadata provided
//    by Buck2 as the state without modification.
//
// 5. Allow tracking extra dependencies (configuration files, for example) that
//    completely invalidate the cache when they differ between runs.
//
// [0]: https://www.gnu.org/software/findutils/xargs
impl super::Run for IncrementalCommand<'_> {
    type Result = Result<ExitCode>;

    fn run(self) -> Self::Result {
        match self.exec() {
            Ok(None) => Ok(ExitCode::SUCCESS),
            Ok(Some(exit_status)) if exit_status.success() => Ok(ExitCode::SUCCESS),
            Ok(_) => {
                fs::remove_file(self.state)?;
                Ok(ExitCode::FAILURE)
            }
            Err(err) => {
                fs::remove_file(self.state)?;
                Err(err)
            }
        }
    }
}

#[derive(Debug, ::serde::Deserialize, ::serde::Serialize)]
pub(crate) struct Cxxbridge<'a> {
    #[serde(borrow)]
    srcs: Vec<&'a str>,
    cxxs: Vec<&'a str>,
    hxxs: Vec<&'a str>,
    with_hacks: bool,
}

impl super::Run for Cxxbridge<'_> {
    type Result = Result<ExitCode>;

    fn run(self) -> Self::Result {
        for ((src, cxx), hxx) in self.srcs.into_iter().zip(self.cxxs).zip(self.hxxs) {
            process::Command::new("cxxbridge")
                .args(["--output", cxx, src])
                .status()?
                .exit_ok()?;

            process::Command::new("cxxbridge")
                .args(["--header", "--output", hxx, src])
                .status()?
                .exit_ok()?;

            if self.with_hacks {
                process::Command::new("sed")
                    .args([
                        "--in-place",
                        "-E",
                        r"s/^(.+\$cxxbridge.+\$.+)noexcept\s*(\{)$/\1\2/",
                        cxx,
                    ])
                    .status()?
                    .exit_ok()?;
            }
        }
        Ok(ExitCode::SUCCESS)
    }
}
