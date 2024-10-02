use ::std::{ffi::OsStr, process};

use ::valuable::Valuable as _;

pub(crate) trait Command {
    fn args<S: AsRef<OsStr>>(&mut self, args: &[S]) -> &mut Self;
}

impl Command for process::Command {
    #[::tracing::instrument(skip_all)]
    fn args<S: AsRef<OsStr>>(&mut self, args: &[S]) -> &mut Self {
        ::tracing::debug!(
            // This guards against [a panic in `valuable-serde`][0] that is (at least for our
            // purposes) triggered when the concrete type of `S` is `::std::path::PathBuf`.
            //
            // <!-- prettier-ignore -->
            // [0]: https://github.com/tokio-rs/valuable/blob/v0.1.0/valuable-serde/src/lib.rs#L258
            args = args
                .iter()
                .map(|s| s.as_ref().to_string_lossy().into_owned())
                .collect::<Vec<_>>()
                .as_value()
        );
        self.args(args)
    }
}
