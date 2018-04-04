import os
import ycm_core
from pathlib import Path

# Flags to use if no compilation database is found
flags = [
        '-Wall',
        '-Wextra',
        '-Wpedantic'
        ]

def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

def FindCorrespondingSourceFile(filename):
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]:
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                return replacement_file
    return filename

def LoadCompilationDb(path, filename):
    database = ycm_core.CompilationDatabase(path)
    compilation_info = database.GetCompilationInfoForFile(filename)

    if not compilation_info.compiler_flags_:
        return None

    final_flags = list(compilation_info.compiler_flags_)

    return {
            'flags': final_flags,
            'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
            'override_filename': filename
            }

def FlagsForFile(filename, **kwargs):
    # If the file is a header, use corresponding source file
    filename = FindCorrespondingSourceFile(filename)

    # Try to find database using 'build-system/'
    directory = Path(filename)
    while not directory.exists() or not directory.samefile(directory.parent):
        directory = directory.parent

        for subitem in directory.iterdir():
            if subitem.is_dir() and subitem.name == 'build-system':
                for subsubitem in subitem.iterdir():
                    if subsubitem.is_file() and subsubitem.name == 'compilation-database.txt':
                        config_file = open(str(subsubitem), 'r')
                        compilation_db_path = subitem.joinpath(config_file.readline()).resolve()

                        if compilation_db_path.exists():
                            return LoadCompilationDb(compilation_db_path, filename)

    # Use default flags as fallback
    return {
            'flags': flags,
            'include_paths_relative_to_dir': os.path.dirname(os.path.abspath(__file__)),
            'override_filename': filename
            }
