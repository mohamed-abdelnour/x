fn main() -> impl ::std::process::Termination {
    #[cfg(all(debug_assertions, feature = "cxxrs_cxx_fail_fast"))]
    {
        let bridge = "src/lib.rs";
        let include = "../../../cxx/cxxrs/lto_2/include";

        println!("cargo:rerun-if-changed={bridge}");
        println!("cargo:rerun-if-changed={include}");

        ::cxx_build::bridge(bridge)
            .flag("-fcolor-diagnostics")
            .include(include)
            .std("c++23")
            .try_compile("cxxrs_lto_2_rs.cxx")
    }
}
