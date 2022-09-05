#! /usr/bin/python3
#
#  -*- mode: python; -*-
#
# Given a source directory containing various scripts (.sh, .pl, .py, etc.) and
# a target directory, populate the target directory with symlinks to the scripts
# in the source directory. In most cases, the symlinks are the same as the script
# except that the extension is removed (e.g. foo -> ~/src/scripts/foo.pl). If
# there are multiple files sharing a basename (e.g. foo.sh, foo.pl), the
# unadorned link is created for the "highest" type and the remaining links
# have the extension (e.g. foo -> ~/scripts/foo.pl, foo.sh -> ~/scripts/foo.sh).
#

import os
import sys
from enum import Enum
from pathlib import PurePath, PurePosixPath
from typing import Dict, List, Tuple

# scripts: Dict[str,set] = {}

program: str = ""


def check_dir_exists(dir: str) -> int:
    if not os.path.exists(dir):
        print(f"{program}: {dir}: directory does not exist", file=sys.stderr)
        return 1
    if not os.path.isdir(dir):
        print(f"{program}: {dir}: not a directory", file=sys.stderr)
        return 1
    return 0


class ScriptType(Enum):
    """Enumeration for script 'types' based on the filename extension."""
    PYTHON = ".py"
    RUBY = ".rb"
    PERL = ".pl"
    ZSH = ".zsh"
    BASH = ".bash"
    KSH = ".ksh"
    SH = ".sh"
    CSH = ".csh"


script_type_preference_order = {
    ScriptType.PYTHON: 1,
    ScriptType.RUBY: 2,
    ScriptType.PERL: 3,
    ScriptType.ZSH: 4,
    ScriptType.BASH: 5,
    ScriptType.KSH: 6,
    ScriptType.SH: 7,
    ScriptType.CSH: 8,
}


def listdir_sorted(path: str) -> List[str]:
    files = os.listdir(path)
    files.sort()
    return files


def get_stem_and_suffix(file: str) -> Tuple[str, str]:
    return PurePath(file).stem, PurePath(file).suffix


def get_scripts(files: List[str]) -> Dict[str, set]:
    scripts: Dict[str, set] = {}

    for f in files:
        stem, suffix = get_stem_and_suffix(f)
        if len(suffix) == 0:
            continue  # "dot" files are all stem no suffix

        st = ScriptType(suffix)
        if stem in scripts:
            scripts[stem].add(st)
        else:
            scripts[stem] = {st}

    return scripts


def build_target(source_dir: str, target_dir: str, scripts: Dict[str, set]) -> int:
    try:
        os.makedirs(target_dir, mode=0o755, exist_ok=False)
    except FileExistsError:
        print(f"{program}: {dir}: file or directory already exists", file=sys.stderr)
        return 1

    for entry in scripts.items():
        basename = entry[0]
        script_types = entry[1]

        primary_link_established = False
        for st in script_types:
            extension = st.value

            source_file_path = f"{source_dir}/{basename}{extension}"
            target_file_path = f"{target_dir}/{basename}"
            if primary_link_established:
                target_file_path += f"{extension}"

            print(f"{target_file_path} -> {source_file_path}")
            primary_link_established = True

    return 0


def main() -> int:
    global program
    program = sys.argv[0].split("/")[-1]

    if len(sys.argv) != 3:
        print(
            f"{program}: usage: {program} <source directory> <target_directory>",
            file=sys.stderr,
        )
        return 1

    source_dir = sys.argv[1]
    target_dir = sys.argv[2]

    if status := check_dir_exists(source_dir):
        return status

    files = listdir_sorted(source_dir)
    scripts = get_scripts(files)
    # print(scripts)

    if status := build_target(source_dir, target_dir, scripts):
        return status


if __name__ == "__main__":
    status = main()
    os.sys.exit(status)
