use ::std::{fmt, marker::PhantomData};

#[derive(::serde::Deserialize, ::serde::Serialize)]
#[repr(transparent)]
#[serde(transparent)]
pub struct Wrapper<T, M>(pub T, PhantomData<M>);

impl<T, M> Wrapper<T, M> {
    pub fn new(inner: T) -> Self {
        Self(inner, PhantomData)
    }
}

impl<T: fmt::Debug, M> fmt::Debug for Wrapper<T, M> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.0.fmt(f)
    }
}
