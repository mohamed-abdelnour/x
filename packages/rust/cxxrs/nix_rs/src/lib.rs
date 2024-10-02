mod error;

pub(crate) mod nix {
    #[derive(Debug)]
    #[repr(transparent)]
    pub(crate) struct PosIdx(u32);

    unsafe impl ::cxx::ExternType for PosIdx {
        type Id = ::cxx::type_id!("nix::PosIdx");
        type Kind = ::cxx::kind::Trivial;
    }

    #[derive(Debug)]
    #[repr(u8)]
    #[expect(dead_code)]
    pub(crate) enum ValueType {
        Thunk,
        Int,
        Float,
        Bool,
        String,
        Path,
        Null,
        Attrs,
        List,
        Function,
        External,
    }

    unsafe impl ::cxx::ExternType for ValueType {
        type Id = ::cxx::type_id!("cxxrs::nix::ValueType");
        type Kind = ::cxx::kind::Trivial;
    }
}

mod r#impl {
    // This is just to demonstrate that the code generated from expanding the bridge
    // macro wraps a polymorphism in the specified monomorphic declaration of that
    // polymorphism.
    use ::std::{pin::Pin, ptr::eq as ptr_eq};

    use super::{
        error::{self, Result},
        nix,
    };
    use ffi::{EvalState, PosIdx, Value};

    fn fib_0(n: i64) -> i64 {
        (0..n).fold((1, 0), |(a, b), _| (b, a + b)).1
    }

    // This is not particularly well-designed. I'd consider having to ensure the
    // `ARITY` defined here matches that defined on the C++ side the worst offender. In
    // a "real" implementation we'd want to have a library for the C++ bindings (think
    // `nix_expr_sys`) and an abstraction on top of it (written in a mix of C++ and
    // Rust) that exposes a more robust definition to use here.
    fn fib_1<'nix: 'res, 'res>(
        mut state: Pin<&'nix mut EvalState>,
        pos: PosIdx,
        args: *mut *mut Value,
        result: Pin<&'res mut Value>,
    ) -> Result<()> {
        const ARITY: usize = 1;
        let args = unsafe { *(args as *mut [*mut Value; ARITY]) };
        let mut n = unsafe { Pin::new_unchecked(&mut *args[0]) };

        state.as_mut().forceValue(n.as_mut(), pos);

        result.mkInt(match ffi::value_type(&n) {
            nix::ValueType::Int => fib_0(n.integer()),
            nix::ValueType::Float => fib_0(n.fpoint() as i64),
            r#type => {
                return Err(::error_stack::Report::from(error::Type {
                    expected: [nix::ValueType::Int, nix::ValueType::Float],
                    got: r#type,
                })
                .attach_printable(format!(
                    "while evaluating: [0] = {}",
                    ffi::display(state, n)
                ))
                .change_context(error::Error)
                .into())
            }
        });

        Ok(())
    }

    #[::cxx::bridge(namespace = "cxxrs::nix")]
    mod ffi {
        unsafe extern "C++" {
            include!(<nix/config.h>);
            include!(<nix/eval.hh>);
            include!(<nix/pos-idx.hh>);
            include!(<nix/value.hh>);

            // This is not _required_; CXX generates extra code as needed if it's not included.
            // We include it to avoid bloating the generated code unnecessarily for easier
            // inspection.
            include!(<rust/cxx.h>);

            include!(<cxxrs/nix/lib.hxx>);

            type ValueType = crate::nix::ValueType;

            fn display(state: Pin<&mut EvalState>, value: Pin<&mut Value>) -> UniquePtr<CxxString>;
            fn value_type(value: &Value) -> ValueType;
        }

        #[namespace = "nix"]
        unsafe extern "C++" {
            type EvalState;
            type PosIdx = crate::nix::PosIdx;
            type Value;

            fn forceValue(self: Pin<&mut EvalState>, value: Pin<&mut Value>, pos: PosIdx);

            fn fpoint(self: &Value) -> f64;
            fn integer(self: &Value) -> i64;
            fn mkInt(self: Pin<&mut Value>, value: i64);
        }

        extern "Rust" {
            fn fib_0(n: i64) -> i64;

            unsafe fn fib_1(
                state: Pin<&mut EvalState>,
                pos: PosIdx,
                args: *mut *mut Value,
                result: Pin<&mut Value>,
            ) -> Result<()>;

            unsafe fn ptr_eq(a: *const Value, b: *const Value) -> bool;
        }
    }
}
