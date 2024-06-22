#! /usr/bin/env python3
"""
Unzips a Bandcamp ZIP file, and then processes the files to to place them
under the current directory in this format:

    <artist>/<album>/<track#> - <track name>.<extension>
"""

import argparse
import logging
import os.path
import re
import sys
import zipfile
from dataclasses import dataclass

program: str = ""


def parse_args(argv: list[str]) -> str:
    """
    Given command-line arguments, return a str that names a ZIP file.
    """
    parser = argparse.ArgumentParser(
        description="""\
            Given the name of a Bandcamp ZIP file, unwrap that file by
            unzipping it and renaming moving the moving the unzipped files
            under the current directory in the format
            <artist>/<album>/<track#> - <track name>.<extension>
            """,
        epilog="""\
            For example: %(prog)s DIIV - Oshin - 10th Anniversary Reissue.zip""",
    )
    parser.add_argument(
        "zipfile",
        help="""\
            zipfile is the path to a ZIP file downloaded from Bandcamp.""",
    )

    args = parser.parse_args(argv)
    logging.debug("args=%s", args)

    # extract required zipfile argument
    zipfile_arg = args.zipfile
    logging.debug("zipfile=%s", zipfile_arg)
    return zipfile_arg


CHOP_MARKER = "..."
CHOP_MARKER_LEN = len(CHOP_MARKER)


def shorten_info_string(info: str, max_len: int) -> str:
    """
    Shorten informational string to specified maximum length,
    inserting an ellipsis to indicated elided characters.
    """

    info_len = len(info)

    if not info_len > max_len:
        return info

    # handle degenerate case where shortened string won't
    # have at least two characters before the CHOP_MARKER
    # and one character after the CHOP_MARKER
    if info_len < CHOP_MARKER_LEN + 3:
        return info

    prefix_len = (info_len // 2) - 2
    suffix_len = info_len - (prefix_len + CHOP_MARKER_LEN)

    prefix = info[: prefix_len + 1]
    suffix = info[info_len - suffix_len + 1 :]

    return prefix + CHOP_MARKER + suffix


@dataclass
class ZipFileComponents:
    """Small class to hold results of parsing ZIP file name."""

    basename: str
    artist: str
    album: str


NAME_COMPONENT_SEPARATOR = " - "


def parse_zip_filename(zip_filename: str) -> ZipFileComponents:
    """Given the name of a ZIP file, extract the basename, artist name, and album name."""
    # NB: this breaks if the artist name has an embedded " - " string
    artist_album_regexp = r"^((.+?)" + NAME_COMPONENT_SEPARATOR + r"(.+))\.zip$"
    zf_parts_re = re.compile(artist_album_regexp, re.IGNORECASE)
    zf_parts_m = zf_parts_re.match(zip_filename)
    if not zf_parts_m:
        print(
            f"{program}: could not match artist / album in '{zip_filename}'",
            file=sys.stderr,
        )
        return 1

    zfc = ZipFileComponents(
        basename=zf_parts_m.group(1) + NAME_COMPONENT_SEPARATOR,
        artist=zf_parts_m.group(2),
        album=zf_parts_m.group(3),
    )
    logging.debug("zfc='%s'", zfc)

    return zfc


def make_music_file_re():
    """Return a RE matching music files."""
    music_file_regexp = r".*(\d\d) (.+\.m4a)"
    music_file_re = re.compile(music_file_regexp, re.IGNORECASE)
    logging.debug("music_file_re=%s", music_file_re)
    return music_file_re


def main() -> int:
    """Simple main()"""

    zip_filename = parse_args(sys.argv[1:])
    if not os.path.isfile(zip_filename):
        print(
            f"{program}: ZIP file argument '{zip_filename}' is not a file",
            file=sys.stderr,
        )
        return 1

    zfc = parse_zip_filename(zip_filename)

    subdir = os.path.join(zfc.artist, zfc.album)
    logging.debug("subdir='%s'", subdir)

    os.makedirs(subdir, exist_ok=True)
    logging.debug("os.makedirs() for '%s' successful", subdir)

    if len(os.listdir(subdir)) > 0:
        print(f"{program}: found pre-existing files in '{subdir}'", file=sys.stderr)
        return 1

    with zipfile.ZipFile(zip_filename) as zf:
        zf.extractall(subdir)

    music_file_re = make_music_file_re()

    for filename in os.listdir(subdir):
        logging.debug("filename=%s", filename)

        if not os.path.isfile(os.path.join(subdir, filename)):
            print(f"{filename}: not a file", file=sys.stderr)
            continue

        unprefixed_filename = filename.removeprefix(zfc.basename)
        logging.debug("unprefixed_filename=%s", unprefixed_filename)

        music_file_match = music_file_re.match(unprefixed_filename)
        if not music_file_match:
            print(f"{filename}: not a music file", file=sys.stderr)
            continue

        # new filename removes the prefix and puts a name component
        # separator between the track number and track name
        track_number = music_file_match.group(1)
        track_name = music_file_match.group(2)
        new_filename = f"{track_number}{NAME_COMPONENT_SEPARATOR}{track_name}"

        print(f"{shorten_info_string(filename, 56):<58} -> {new_filename}")

        old_path = os.path.join(subdir, filename)
        new_path = os.path.join(subdir, new_filename)
        os.rename(old_path, new_path)

    return 0


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    program = sys.argv[0].rsplit("/", maxsplit=1)[-1]
    logging.debug("program=%s", program)

    sys.exit(main())
