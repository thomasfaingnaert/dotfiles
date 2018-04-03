import ycm_core
from pathlib import Path

# Flags to use if no compilation database is found
flags = [
        '-Wall',
        '-Wextra',
        '-Wpedantic'
        ]

def IsHeaderFile(filename):
    return Path(filename).suffix in [ '.h', '.hxx', '.hpp', '.hh' ]

def FindCorrespondingSourceFile(filename):
    if IsHeaderFile(filename):
        # Try finding source file in same directory
        for extension in [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]:
            source_file = Path(filename).with_suffix(extension)
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
    # If the file is a header, use corresponding source file
    source_file = FindCorrespondingSourceFile(Path(filename))

    # Try to find database using 'build-system/'
    while not source_file.exists() or not source_file.samefile(source_file.parent):
        source_file = source_file.parent

        for subitem in source_file.iterdir():
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
            'override_filename': str(source_file)
            }
