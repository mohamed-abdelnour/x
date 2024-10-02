extern "C" {
    pub fn cxx_succ(n: u16) -> u16;
}

#[no_mangle]
pub extern "C" fn rs_fib(n: u16) -> u16 {
    (0..n).fold((1, 0), |(a, b), _| (b, a + b)).1
}

#[no_mangle]
pub extern "C" fn rs(n: u16) -> u16 {
    rs_fib(unsafe { cxx_succ(n) })
}
