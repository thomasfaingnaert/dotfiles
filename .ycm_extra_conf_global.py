import os
import ycm_core
from pathlib import Path

# Flags to use if no compilation database is found
flags = [
        '-Wall',
        '-Wextra',
        '-Wpedantic'
        ]

log = open('C:/Users/Thomas/ycm.log', 'w')

def IsHeaderFile(filename):
    return Path(filename).suffix in [ '.h', '.hxx', '.hpp', '.hh' ]

def FindCorrespondingSourceFile(filename):
    if IsHeaderFile(filename):
        # Extensions for source files
        extensions = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]
        # Try finding source file in same directory
        for extension in extensions:
            source_file = filename.with_suffix(extension)
            if source_file.exists():
                return source_file

        # Try finding source file in ../src
        for extension in extensions:
            source_file = filename.parent.with_name('src').joinpath(filename.name).with_suffix(extension)
            if source_file.exists():
                return source_file

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
    log.write(filename)
    log.write('\n')

    # If the file is a header, use corresponding source file
    source_file = FindCorrespondingSourceFile(Path(filename))
    directory = source_file

    log.write(str(source_file))
    log.write('\n')

    # Try to find database using 'build-system/'
    while not directory.exists() or not directory.samefile(directory.parent):
        directory = directory.parent

        for subitem in directory.iterdir():
            if subitem.is_dir() and subitem.name == 'build-system':
                for subsubitem in subitem.iterdir():
                    if subsubitem.is_file() and subsubitem.name == 'compilation-database.txt':
                        config_file = open(str(subsubitem), 'r')
                        compilation_db_path = subitem.joinpath(config_file.readline()).resolve()

                        if compilation_db_path.exists():
                            log.write('Loaded from compilation db\n')
                            return LoadCompilationDb(compilation_db_path, str(source_file))

    # Use default flags as fallback
    log.write('Fallback\n')
    return {
            'flags': flags,
            'include_paths_relative_to_dir': os.path.dirname(os.path.abspath(__file__)),
            'override_filename': str(source_file)
            }
