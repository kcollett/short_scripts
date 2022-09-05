#! /usr/bin/python3
#
#  -*- mode: python; -*-
#
# script to set up basic shell environment in current directory
# typically this should be the home directory (but can another for testing)
# git must be in your path for this to work
#

import os
import sys
from enum import Enum, IntEnum
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
    PYTHON = "py"
    RUBY = "rb"
    PERL = "pl"
    ZSH = "zsh"
    BASH = "bash"
    KSH = "ksh"
    SH = "sh"
    CSH = "csh"


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

def get_basename_and_extension(file: str) -> Tuple[str, str]:
    components = file.split(".")
    return ".".join(components[:-1]), components[-1]


def get_scripts(files: List[str]) -> Dict[str, set]:
    scripts: Dict[str, set] = {}

    for f in files:
        basename, extension = get_basename_and_extension(f)
        if len(basename) == 0:  # skip "dot" files
            continue
        st = ScriptType(extension)
        if basename in scripts:
            scripts[basename].add(st)
        else:
            scripts[basename] = {st}

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
        # print(basename)
        # print(extensions)

        # if len(script_types) == 1:
        #     # file that doesn't have multiple versions (e.g. foo.sh, foo.pl);
        #     # leave extension out of symlink
        #     extension = list(script_types)[0].value
        #     source_file_path = f"{source_dir}/{basename}.{extension}"
        #     target_file_path = f"{target_dir}/{basename}"
        #     print(f"{target_file_path} -> {source_file_path}")
        # else:
        main_link_established = False
        for script_type in script_types:
            extension = script_type.value
            source_file_path = f"{source_dir}/{basename}.{extension}"
            target_file_path = f"{target_dir}/{basename}"
            if main_link_established:
                target_file_path += f".{extension}"
            print(f"{target_file_path} -> {source_file_path}")
            main_link_established = True

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
