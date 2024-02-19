#! /usr/bin/python3
#
#  -*- mode: python; -*-
#
"""
Given an artist directory containing albums and tracks, create a mirroring
hierarch of symlinks under the current directory, but where the track names
have been transformed.
"""

# import argparse
import logging
import os
import os.path
import sys
import re
from collections import namedtuple


def check_directory(directory_path: str) -> (bool, str):
    """
    Utility function to check to see if a specified directory exists.
    If it does, True is returned; otherwise, False is returned along
    with an appropriate error message.
    """
    if not os.path.exists(directory_path):
        return False, f"{directory_path}: directory does not exist"
    if not os.path.isdir(directory_path):
        return False, f"{directory_path}: not a directory"
    # I'll cross the "support symlinks to directories" bridge when I get to it

    return True, ""


# A bit convoluted so that I can define a docstring for the namedtuple.
# https://stackoverflow.com/questions/1606436/adding-docstrings-to-namedtuples
TrackInfoNT = namedtuple("TrackInfo", "disc_number, track_number, track_name")


class TrackInfo(TrackInfoNT):
    """
    The disc number, track number, and name for a particular track.
    """


def track_basename_for_plex(ti: TrackInfo) -> str:
    """
    Given track information, return a track file name approprate for Plex.
    https://support.plex.tv/articles/200265296-adding-music-media-from-folders/
    """
    number = f"{ti.track_number:02}"
    if ti.disc_number > 0:  # prepend disc number if defined
        number = f"{ti.disc_number}{number}"
    return f"{number} - {ti.track_name}"


TRACK_RE = re.compile(r"(?:([\d])-)?([\d]+)[\s-]+([\S]?.+)")


def extract_track_info(target_track_file_name) -> TrackInfo:
    """
    Given file name of target track, return the corresponding
    track number and track name.
    """
    m = TRACK_RE.match(target_track_file_name)
    disk_match = m.group(1)
    disk_number = int(disk_match) if disk_match is not None else 0
    track_number = int(m.group(2))
    track_name = m.group(3)

    logging.debug("disk_number=%d", disk_number)
    logging.debug("track_number=%d", track_number)
    logging.debug("track_name='%s'", track_name)

    return TrackInfo(disk_number, track_number, track_name)


def list_entries(directory: str):
    """
    Given a path to a directory, return a sorted list of entries
    (files, directories, etc.) within that directory.
    """
    filtered_files = [file for file in os.listdir(directory) if file != ".DS_Store"]
    return sorted(filtered_files)


def make_symlink(target_path, link_path: str) -> None:
    """
    Given the path to a symbolic link target, and a path specifying
    name and location of the symbolic link, write some informational
    messages to STDOUT and create the symlink.
    """
    info_link_path = f".../{os.path.basename(link_path)}"
    info_target_path = f"<ad>/.../{os.path.basename(target_path)}"
    print(f"    {info_link_path:36} -> {info_target_path:36}")
    os.symlink(target_path, link_path)


def symlink_album(target_dir, artist, album: str) -> None:
    """
    Given a symlink target directory, an artist, and an album subdirectory,
    return a list of SymlinkArgs corresponding to the tracks within that album.
    """
    print(f"linking  album: {album}")
    album_link_subdir = os.path.join(artist, album)
    os.makedirs(album_link_subdir, mode=0o755, exist_ok=False)

    album_target_subdir = os.path.join(target_dir, album)

    for target_track_basename in list_entries(album_target_subdir):
        ti = extract_track_info(target_track_basename)
        link_track_basename = track_basename_for_plex(ti)

        target_track_path = os.path.join(album_target_subdir, target_track_basename)
        link_track_path = os.path.join(artist, album, link_track_basename)

        make_symlink(target_track_path, link_track_path)


def main() -> int:
    """
    Main for this script.
    """
    logging.debug("TRACK_RE=%s", TRACK_RE)

    if len(sys.argv) != 2:
        print(
            f"{program}: usage: {program} <artist_directory>",
            file=sys.stderr,
        )
        return 1

    artist_target_dir = os.path.abspath(os.path.expanduser(sys.argv[1]))
    # target_dir = os.path.abspath(sys.argv[2])

    valid, error_message = check_directory(artist_target_dir)
    if not valid:
        print(f"{program}: {error_message}", file=sys.stderr)
        return 1

    artist = os.path.basename(artist_target_dir)
    print(f"linking artist: {artist}")
    try:
        os.makedirs(artist, mode=0o755, exist_ok=False)
    except FileExistsError:
        print(
            f"{program}: {artist}: "
            + "file or directory already exists as subdirectory of current directory",
            file=sys.stderr,
        )
        return 1

    for album in list_entries(artist_target_dir):
        symlink_album(artist_target_dir, artist, album)

    return 0


program: str = ""  # set in main()


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    program = sys.argv[0].rsplit("/", maxsplit=1)[-1]
    logging.debug("program=%s", program)

    sys.exit(main())
