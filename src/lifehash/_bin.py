from __future__ import annotations

import argparse
import sys

import numpy as np

import lifehash.ffi


def main() -> None:
    cli = argparse.ArgumentParser("lifehash")
    cli.add_argument("-ha", "--has-alpha", type=bool, default=False)
    cli.add_argument("-it", "--input-type", choices=("data", "digest", "utf8"), default="digest")
    cli.add_argument("-lv", "--lifehash-version", type=int, default=1)
    cli.add_argument("-ms", "--module-size", type=int, default=0)
    cli.add_argument("-of", "--output-format", default="svg")
    cli = cli.parse_args()

    cli.lifehash_version = lifehash.ffi.Version(cli.lifehash_version % 5)
    cli.module_size = 1 << cli.module_size

    with open(0) as _input:
        match cli.input_type:
            case "data":
                _input = lifehash.ffi.make_from_data(
                    bytearray(_input.buffer.read()),
                    cli.lifehash_version,
                    cli.module_size,
                    cli.has_alpha,
                )
            case "digest":
                _input = lifehash.ffi.make_from_digest(
                    bytearray(_input.buffer.read()),
                    cli.lifehash_version,
                    cli.module_size,
                    cli.has_alpha,
                )
            case "utf8":
                _input = lifehash.ffi.make_from_utf8(
                    _input.read(),
                    cli.lifehash_version,
                    cli.module_size,
                    cli.has_alpha,
                )

    pixels = np.asarray(_input.colors, dtype=np.uint8)
    pixels = np.reshape(pixels, (_input.height, _input.width, 3))

    match cli.output_format:
        case "svg":
            import xml.etree.ElementTree as ET

            svg = {
                "xmlns": "http://www.w3.org/2000/svg",
                "viewBox": f"0 0 {_input.width} {_input.height}",
            }
            svg = ET.Element("svg", svg)

            pixel = {"width": "1", "height": "1"}
            for y, x in np.ndindex(pixels.shape[:2]):
                r, g, b = pixels[y, x]
                pixel["fill"] = f"rgb({r}, {g}, {b})"
                pixel["x"] = f"{x}"
                pixel["y"] = f"{y}"
                ET.SubElement(svg, "rect", pixel)

            ET.ElementTree(svg).write(sys.stdout.buffer)

        case _:
            from PIL import Image

            Image.fromarray(pixels).save(
                sys.stdout.buffer,
                format=cli.output_format,
                lossless=True,
                method=6,
                optimize=True,
            )
