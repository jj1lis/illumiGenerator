module io;

import std.stdio;

@system:

void writeError(const string error_msg){
    import termcolor;
    stderr.write(C.yellow.fg, "error : ", C.reset.fg, error_msg);
}

void writelnError(const string error_msg){
    (error_msg ~ "\n").writeError;
}

void writeNotice(const string notice_msg){
    import termcolor;
    write(C.cyan.fg, "notification : ", C.reset.fg, notice_msg);
}

void writelnNotice(const string notice_msg){
    (notice_msg ~ "\n").writeNotice;
}

void outputFile(const string sourcecode, const string filename){
    import std.file :append;
    append(filename.initFile, sourcecode);
}

string initFile(const string filename){
    import std.file : exists, isFile;
    import std.format : format;
    if(filename.exists && filename.isFile){
        format("File '%s' already exists. Generate %s.ov .", filename).writelnNotice;
        return filename ~ ".ov";
    }else
        return filename;
}
