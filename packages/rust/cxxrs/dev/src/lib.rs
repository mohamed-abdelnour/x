#![feature(exit_status_error)]

use self::error::{Error, Result};

mod action;
mod error;
mod ext;
mod wrapper;

pub fn main() -> impl ::std::process::Termination {
    use ::std::{env, fs, fs::File, io, path::Path};

    use ::tracing_subscriber::{filter::LevelFilter, EnvFilter};

    use self::action::{Action, Run as _};

    #[derive(Debug, ::serde::Deserialize, ::serde::Serialize)]
    struct Arg<'a> {
        #[serde(borrow)]
        action: Action<'a>,
        log: Option<&'a Path>,
    }

    let arg = &env::args()
        .nth(1)
        .map_or_else(|| io::read_to_string(io::stdin()), fs::read_to_string)?;
    let arg = ::serde_json::from_str::<Arg>(arg)?;

    if let Some(log) = arg.log {
        let env_filter = EnvFilter::builder()
            .with_default_directive(LevelFilter::ERROR.into())
            .with_env_var("CXXRS_LOG")
            .from_env()?;

        ::tracing_subscriber::fmt()
            .json()
            .with_env_filter(env_filter)
            .with_writer(File::create(log)?)
            .try_init()?;
    }

    arg.action.run()
}
