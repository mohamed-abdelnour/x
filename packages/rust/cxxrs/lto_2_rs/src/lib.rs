use r#impl::{add_to_fib_fst, succ};

fn fib(n: u16) -> u16 {
    (0..n).fold((1, 0), |(a, b), _| (b, a + b)).1
}

fn check_fib(m: u16) -> u16 {
    let n = succ(m);
    fib(succ(n)) - add_to_fib_fst(n, fib(m))
}

#[cxx::bridge(namespace = "cxxrs::lto_2")]
mod r#impl {
    unsafe extern "C++" {
        include!(<cxxrs/lto_2/lib.hxx>);

        fn succ(n: u16) -> u16;
        fn add_to_fib_fst(m: u16, n: u16) -> u16;
    }

    extern "Rust" {
        fn check_fib(m: u16) -> u16;
        fn fib(n: u16) -> u16;
    }
}
