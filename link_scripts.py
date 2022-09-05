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
import os.path
import sys
from collections import defaultdict, namedtuple
from enum import Enum
from pathlib import PurePath
from typing import Dict, List, Tuple

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
    """Enumeration for script 'types' based on the filename suffix."""

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


FileComponents = namedtuple("FileComponents", ["stem", "suffix"])


def makeFileComponents(path: str) -> FileComponents:
    return FileComponents(PurePath(path).stem, PurePath(path).suffix)


def get_scripts(files: List[str]) -> Dict[str, set]:
    components = [makeFileComponents(f) for f in files]
    # filter out "dot" files (which are all stem no suffix)
    components = filter(lambda fc: len(fc.suffix) > 0, components)

    scripts = defaultdict(set)

    for fc in components:
        scripts[fc.stem].add(ScriptType(fc.suffix))

    return scripts


def build_target(source_dir: str, target_dir: str, scripts: Dict[str, set]) -> int:
    for basename, script_types in scripts.items():
        primary_link_established = False
        for st in script_types:
            suffix = st.value

            source_file_path = os.path.join(source_dir, f"{basename}{suffix}")
            source_file_path = os.path.relpath(source_file_path, start=target_dir)
            target_file_path = os.path.join(target_dir, basename)
            if primary_link_established:
                target_file_path = str(PurePath(target_file_path).with_suffix(suffix))

            print(f"{target_file_path} -> {source_file_path}")
            os.symlink(source_file_path, target_file_path)

            primary_link_established = True

    return 0


def main() -> int:
    global program
    program = sys.argv[0].split("/")[-1]

    if len(sys.argv) != 3:
        print(
            f"{program}: usage: {program} <source_directory> <target_directory>",
            file=sys.stderr,
        )
        return 1

    source_dir = os.path.abspath(sys.argv[1])
    target_dir = os.path.abspath(sys.argv[2])

    if status := check_dir_exists(source_dir):
        return status

    try:
        os.makedirs(target_dir, mode=0o755, exist_ok=False)
    except FileExistsError:
        print(
            f"{program}: {target_dir}: file or directory already exists",
            file=sys.stderr,
        )
        return 1

    files = listdir_sorted(source_dir)
    scripts = get_scripts(files)
    # print(scripts)

    if status := build_target(source_dir, target_dir, scripts):
        return status

    return 0


if __name__ == "__main__":
    status = main()
    sys.exit(status)
