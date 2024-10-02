use ::std::{error, fmt, result};

use ::error_stack::Context;

use crate::wrapper::Wrapper;

#[derive(Debug)]
pub(crate) enum External {
    EnvVar,
    ExitStatus,
    Invariant,
    Io,
    Opaque,
    SerdeJson,
    TracingSubscriber,
}

#[derive(Debug)]
pub(crate) enum Error {
    External(External),
}

impl fmt::Display for External {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let tag = match self {
            Self::EnvVar => "EnvVar",
            Self::ExitStatus => "ExitStatus",
            Self::Invariant => "Invariant",
            Self::Io => "Io",
            Self::Opaque => "Opaque",
            Self::SerdeJson => "SerdeJson",
            Self::TracingSubscriber => "TracingSubscriber",
        };
        write!(f, "{tag}")
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let tag = match self {
            Self::External(inner) => ("External", inner),
        };
        write!(f, "cxxrs_dev: {}({})", tag.0, tag.1)
    }
}

impl error::Error for Error {}

trait Tag {
    fn tag() -> Error;
}

macro_rules! impl_tag {
    ($from:ty => $to:expr) => {
        impl $crate::error::Tag for $from {
            fn tag() -> $crate::error::Error {
                $to
            }
        }
    };
    ($($from:ty => $to:expr)+) => {
        $(impl_tag!($from => $to);)+
    };
}

impl_tag! {
    ::std::env::VarError => Error::External(External::EnvVar)
    ::std::io::Error => Error::External(External::Io)
    ::std::process::ExitStatusError => Error::External(External::ExitStatus)

    ::serde_json::Error => Error::External(External::SerdeJson)
    ::tracing_subscriber::filter::FromEnvError => Error::External(External::TracingSubscriber)
}

pub struct ReportMarker;
type Report<C> = Wrapper<::error_stack::Report<C>, ReportMarker>;
pub(crate) type Result<T> = result::Result<T, Report<Error>>;

impl From<::error_stack::Report<Error>> for Report<Error> {
    #[track_caller]
    fn from(inner: ::error_stack::Report<Error>) -> Self {
        Self::new(inner)
    }
}

impl From<Error> for Report<Error> {
    #[track_caller]
    fn from(err: Error) -> Self {
        ::error_stack::Report::new(err).into()
    }
}

impl<C: Context + Tag> From<::error_stack::Report<C>> for Report<Error> {
    #[track_caller]
    fn from(inner: ::error_stack::Report<C>) -> Self {
        inner.change_context(C::tag()).into()
    }
}

impl<C: Context + Tag> From<C> for Report<Error> {
    #[track_caller]
    fn from(ctx: C) -> Self {
        ::error_stack::Report::new(ctx).into()
    }
}

impl From<Box<dyn error::Error + Send + Sync + 'static>> for Report<Error> {
    #[track_caller]
    fn from(opaque: Box<dyn error::Error + Send + Sync + 'static>) -> Self {
        ::error_stack::Report::new(Error::External(External::Opaque))
            .attach_printable(opaque)
            .into()
    }
}
