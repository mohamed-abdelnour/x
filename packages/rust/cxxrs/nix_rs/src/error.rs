use ::std::{error, fmt, result};

use super::nix::ValueType;

#[derive(Debug)]
pub(crate) struct Error;

impl error::Error for Error {}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "cxxrs_nix")
    }
}

#[derive(Debug)]
pub(crate) struct Type<const N: usize> {
    pub(crate) expected: [ValueType; N],
    pub(crate) got: ValueType,
}

impl<const N: usize> error::Error for Type<N> {}

impl<const N: usize> fmt::Display for Type<N> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "invalid type: expected one of: {:?}, got: {:?}",
            self.expected, self.got
        )
    }
}

#[derive(Debug)]
#[repr(transparent)]
pub(crate) struct Verbose<C, const ALT: bool = false>(C);

impl<C: fmt::Debug, const ALT: bool> fmt::Display for Verbose<C, ALT> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if ALT {
            write!(f, "{:#?}", self.0)
        } else {
            write!(f, "{:?}", self.0)
        }
    }
}

impl<C, const ALT: bool> From<C> for Verbose<C, ALT> {
    fn from(inner: C) -> Self {
        Self(inner)
    }
}

pub(crate) type Result<T, const ALT: bool = false> =
    result::Result<T, Verbose<::error_stack::Report<Error>, ALT>>;
