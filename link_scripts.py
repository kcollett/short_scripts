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


FileComponents = namedtuple("FileComponents", ["stem", "suffix"])


def makeFileComponents(path: str) -> FileComponents:
    return FileComponents(PurePath(path).stem, PurePath(path).suffix)


def find_scripts(files: List[str]) -> Dict[str, set]:
    components = [makeFileComponents(f) for f in files]
    # filter out "dot" files (which are all stem no suffix)
    components = [fc for fc in components if len(fc.suffix) > 0]

    scripts = defaultdict(set)

    for fc in components:
        scripts[fc.stem].add(ScriptType(fc.suffix))

    return scripts


SymlinkArgs = namedtuple("SymlinkArgs", ["source_path", "target_path"])


def makeSymlinkArgs(source_path: str, target_path: str) -> SymlinkArgs:
    return SymlinkArgs(source_path, target_path)


def build_symlink_list(
    source_dir: str, target_dir: str, scripts: Dict[str, set]
) -> List[SymlinkArgs]:
    symlinks: List[SymlinkArgs] = []

    for basename, script_types in scripts.items():
        ordered_script_types = sorted(
            list(script_types),
            key=lambda script_type: script_type_preference_order[script_type]
        )

        primary_link_found = False
        for st in ordered_script_types:
            suffix = st.value

            source_file_path = os.path.join(source_dir, f"{basename}{suffix}")
            source_file_path = os.path.relpath(source_file_path, start=target_dir)
            target_file_path = os.path.join(target_dir, basename)
            if primary_link_found:
                target_file_path = str(PurePath(target_file_path).with_suffix(suffix))

            symlinks.append(SymlinkArgs(source_file_path, target_file_path))
            # print(f"{target_file_path} -> {source_file_path}")

            primary_link_found = True

    return symlinks


def make_symlinks(symlinks: List[SymlinkArgs]) -> None:
    for symlink in symlinks:
        print(f"{symlink.target_path:35} -> {symlink.source_path:35}")
        os.symlink(symlink.source_path, symlink.target_path)


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

    files = sorted(os.listdir(source_dir))
    scripts = find_scripts(files)
    symlinks = build_symlink_list(source_dir, target_dir, scripts)
    # print(symlinks)
    make_symlinks(symlinks)

    return 0


if __name__ == "__main__":
    status = main()
    sys.exit(status)
