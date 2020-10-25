module io;

import std.stdio;

@system:

void writeError(string error_msg){
    import termcolor;
    stderr.write(C.yellow.fg, "error : ", C.reset.fg, error_msg);
}

void writelnError(string error_msg){
    (error_msg ~ "\n").writeError;
}

void writeNotice(string notice_msg){
    import termcolor;
    write(C.cyan.fg, "notification : ", C.reset.fg, notice_msg);
}

void writelnNotice(string notice_msg){
    (notice_msg ~ "\n").writeNotice;
}
unittest{
    "THIS IS ERROR TEST!".writelnError;
    "THIS IS NOTICE TEST!".writelnNotice;
}
