#! /usr/bin/env python3
#
#  -*- mode: python; -*-
#
"""
Given a number of options specifying id3v2 tags, process a specified
audio file and store the result in a file of the same name with
"_tagged" appended.
"""

import argparse
import logging
import sys
import re
import subprocess
from datetime import date
from dataclasses import dataclass


@dataclass(frozen=True)
class CommandArgs:
    """Class to represent the results of parsing the command line arguments."""

    input_file: str
    id3v2_tags: dict[str, str]


ARTIST = "artist"
ARTIST_OPT = f"--{ARTIST}"
ALBUM = "album"
ALBUM_OPT = f"--{ALBUM}"
TITLE = "title"
TITLE_OPT = f"--{TITLE}"
DATE = "date"
DATE_OPT = f"--{DATE}"
TRACK = "track"
TRACK_OPT = f"--{TRACK}"
DISC = "disc"
DISC_OPT = f"--{DISC}"
ALBUM_ARTIST = "album_artist"
ALBUM_ARTIST_OPT = f"--{ALBUM_ARTIST}"
SORT_ARTIST = "sort_artist"
SORT_ARTIST_OPT = f"--{SORT_ARTIST}"
SORT_ALBUM = "sort_album"
SORT_ALBUM_OPT = f"--{SORT_ALBUM}"
SORT_NAME = "sort_name"
SORT_NAME_OPT = f"--{SORT_NAME}"
COMPILATION = "compilation"
COMPILATION_OPT = f"--{COMPILATION}"
FILE_ARG = "FILE"
VERSION_OPT = "-v"
VERSION_OPT_LONG = "--version"


def parse_args(argv: list[str]) -> CommandArgs:
    """
    Given command-line arguments, return a map representing id3v2 tags.
    """
    parser = argparse.ArgumentParser(
        description="""\
            A simple program that, given an input audio file and information
            relevant to id3v2 tags, invoke 'ffmpeg' to create an output audio
            file that contains the corresponding id3v2 tags. The output audio
            file will have the same name as the input audio file, but with
            '_tagged' added the end (but before the file extension).

            Note that any arguments with embedded spaces or shell
            metacharacters need to be appropriately quoted.
            """,
        epilog=f"""\
            For example: %(prog)s {ARTIST_OPT} 'Beach House' {ALBUM_OPT} Bloom
            {TITLE_OPT} Myth {DATE_OPT} 2012 {TRACK_OPT} 1/10 Myth.m4a""",
    )

    parser.add_argument(
        ARTIST_OPT, required=False, help="""specify the artist of the track"""
    )
    parser.add_argument(
        ALBUM_OPT,
        required=False,
        help="""specify the containing album of the track""",
    )
    parser.add_argument(
        TITLE_OPT, required=False, help="""specify the title of the track"""
    )
    parser.add_argument(
        DATE_OPT,
        required=True,
        help="""specify the release date of the track. The format can be in
        either YYYY or YYYY-mm-dd format; in the former case, the date will be
        YYYY-01-01.""",
    )
    parser.add_argument(
        TRACK_OPT,
        required=False,
        help="""specify the track number within the containing disc. The format
        can either be 'n' or 'n/m', where 'n' is the track number and 'm' is the
        total number of tracks on the disc.""",
    )
    parser.add_argument(
        DISC_OPT,
        required=False,
        help="""specify the disc number within the containing album.
        The format should be 'n/m', where 'n' is the disc number and 'm' is the
        total number of discs in the album.""",
    )
    parser.add_argument(
        ALBUM_ARTIST_OPT,
        required=False,
        help="""specify the artist of the containing album of the track.""",
    )
    parser.add_argument(
        SORT_ARTIST_OPT,
        required=False,
        help="""specify the artist of the track for sorting purposes.""",
    )
    parser.add_argument(
        SORT_ALBUM_OPT,
        required=False,
        help="""specify the containing album of the track for sorting purposes.""",
    )
    parser.add_argument(
        SORT_NAME_OPT,
        required=False,
        help="""specify the title of the track for sorting purposes.""",
    )
    parser.add_argument(
        COMPILATION_OPT,
        required=False,
        dest="compilation",
        action="store_true",
        help="""if specified, indicates the track is part of a compilation.""",
    )

    parser.add_argument(
        FILE_ARG, nargs=1, help="""specify the name of the audio file."""
    )

    parser.add_argument(
        VERSION_OPT_LONG,
        action="version",
        version="%(prog)s 0.2",
    )

    if len(sys.argv) == 1:
        parser.print_help()
        return None

    args = parser.parse_args(argv)
    ns_dict = vars(args)

    logging.debug("args=%s", args)

    tags: dict[str, str] = {}

    for tag in [
        ARTIST,
        ALBUM,
        TITLE,
        TRACK,
        DATE,
        DISC,
        ALBUM_ARTIST,
        SORT_ARTIST,
        SORT_ALBUM,
        SORT_NAME,
    ]:
        opt_value = ns_dict[tag]
        if not opt_value is None:
            tags[tag] = ns_dict[tag]

    track_date: date
    date_str = ns_dict[DATE]
    if len(date_str) == 4:
        year = int(date_str)
        track_date = date(year, 1, 1)
    else:
        track_date = date.fromtimestamp(date_str)
    tags[DATE] = track_date.isoformat()

    logging.debug("tags=%s", tags)

    if len(tags) == 0:
        print(f"{program}: no tags specified", file=sys.stderr)
        return None

    return CommandArgs(
        input_file=ns_dict[FILE_ARG][0],
        id3v2_tags=tags,
    )


def main() -> int:
    """Simple main()"""
    args = parse_args(sys.argv[1:])
    if args is None:
        return 1

    logging.debug("args=%s", args)

    # Build a set of arguments to pass to subprocess.run(). The arguments
    # follow the example given at:
    #   https://blog.1a23.com/2020/03/16/read-and-write-tags-of-music-files-with-ffmpeg/
    # Start with basic arguments
    run_args: list[str] = [
        "ffmpeg",
        "-i",
        args.input_file,
        "-map",
        "0",
        "-y",
        "-codec",
        "copy",
        "-write_id3v2",
        "1",
    ]

    # append all the id3v2 tag values (using -metadata option)
    for tag, value in args.id3v2_tags.items():
        run_args.append("-metadata")
        run_args.append(f"{tag}={value}")

    # append the output file
    match = re.match(r"(.*)\.([^.]+)$", args.input_file)
    base = match.group(1)
    ext = match.group(2)
    output_file = f"{base}_tagged.{ext}"
    logging.debug("output_file=%s", output_file)

    run_args.append(output_file)

    logging.debug("run_args=%s", run_args)
    subprocess.run(run_args, check=True, capture_output=True)

    return 0


program: str

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    program = sys.argv[0].rsplit("/", maxsplit=1)[-1]
    logging.debug("program=%s", program)

    sys.exit(main())
