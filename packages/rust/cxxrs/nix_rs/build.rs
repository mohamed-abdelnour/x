fn main() -> Result<(), Box<dyn ::std::error::Error>> {
    #[cfg(all(debug_assertions, feature = "cxxrs_cxx_fail_fast"))]
    {
        let bridge = "src/lib.rs";
        let include = "../../../cxx/cxxrs/nix/include";

        println!("cargo:rerun-if-changed={bridge}");
        println!("cargo:rerun-if-changed={include}");

        let mut cc = ::cxx_build::bridge(bridge);

        ::std::str::from_utf8(
            &::std::process::Command::new("pkg-config")
                .args(["--cflags", "nix-expr"])
                .output()?
                .stdout,
        )?
        .split_whitespace()
        .fold(&mut cc, |cc, flag| cc.flag(flag));

        cc.flag("-fcolor-diagnostics")
            .include(include)
            .try_compile("cxxrs_nix_rs.cxx")?;
    }
    Ok(())
}
