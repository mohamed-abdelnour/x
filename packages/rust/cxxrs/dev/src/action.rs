use ::std::process::{ExitCode, Termination};

use crate::Result;

mod buck;

pub(crate) trait Run {
    type Result: Termination;

    fn run(self) -> Self::Result;
}

#[derive(Debug, ::serde::Deserialize, ::serde::Serialize)]
#[serde(rename_all = "snake_case")]
pub(crate) enum Action<'a> {
    BuckCxxbridge(#[serde(borrow)] buck::Cxxbridge<'a>),
    BuckIncrementalCommand(buck::IncrementalCommand<'a>),
}

impl Run for Action<'_> {
    type Result = Result<ExitCode>;

    fn run(self) -> Self::Result {
        match self {
            Self::BuckCxxbridge(inner) => inner.run(),
            Self::BuckIncrementalCommand(inner) => inner.run(),
        }
    }
}
