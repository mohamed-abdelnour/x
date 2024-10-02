pub fn main() {
    let test_cases = ::trycmd::TestCases::new();

    {
        let bins = ["cxxrs_nix_derivation_env_vars", "nix"];
        test_cases.register_bins(bins.map(|bin| (bin, ::which::which(bin))));
    }

    {
        let mut args = ::std::env::args().skip(1).fuse();

        if let Some(arg) = args.next() {
            test_cases.case(arg);
        } else {
            // This is the default if no command-line arguments are provided; it may seem
            // strange for a default, but it caters to the most common use case—running from
            // the root of the repository with no command-line arguments.
            test_cases.case("packages/**/*.trycmd.toml");
        }

        for arg in args {
            test_cases.case(arg);
        }
    }
}
