#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

_watch() {
    watchman watch .
    watchman -- trigger . /README.adoc README.adoc -- \
        asciidoctor \
        --verbose \
        --failure-level=INFO \
        --attribute=_cxxrs \
        --out-file=.cxxrs.README.html \
        README.adoc
}

lto_0() {
    cd "$(nix build --no-link --print-out-paths "$1")"
    rg --heading --line-number 'call\s+' dump | expand --tabs=4
    printf '========================================\n'
    readelf --string-dump=.comment bin/rs.const
} 2>/dev/null

lto_1() {
    cd "$(nix build --no-link --print-out-paths "$1")"
    objdump -Mintel --disassemble-symbols=main bin/cxxrs_lto_1 | expand --tabs=4
} 2>/dev/null

lto_2() {
    cd "$(nix build --no-link --print-out-paths "$1")"
    objdump -Mintel --disassemble-symbols=main bin/cxxrs_lto_2 | expand --tabs=4
} 2>/dev/null

lto_2_without_hacks() {
    cd "$(nix build --no-link --print-out-paths "$2")"
    objdump -Mintel --disassemble-symbols=main bin/cxxrs_lto_2 | expand --tabs=4 | rg "$1\s+"
} 2>/dev/null

"$@"
