extern "C" {
    fn succ(n: u16) -> u16;
    fn add_to_fib_fst(m: u16, n: u16) -> u16;
}

#[no_mangle]
pub extern "C" fn fib(n: u16) -> u16 {
    (0..n).fold((1, 0), |(a, b), _| (b, a + b)).1
}

#[no_mangle]
pub extern "C" fn check_fib(m: u16) -> u16 {
    unsafe {
        let n = succ(m);
        fib(succ(n)) - add_to_fib_fst(n, fib(m))
    }
}
