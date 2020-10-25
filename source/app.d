import std.stdio;
import std.file: readText, FileException;
import std.json;
import std.algorithm;

import exception;
import io;
import parse;
import check;
import generate;

@system:

void main(string[] args){
    try{
        if(args.length == 1)
            throw new ArgumentException("specify argument.");
        if(args.length > 2)
            throw new ArgumentException("too many arguments.");

        import std.array : join;
        auto config = new Configuration(args[1].readText.parseJSON);
        auto codes = config.sources.map!(path => path.readText).join.parseCode;

        config.checkConfiguration(codes);
        //auto inocode = generateArduinoCode(config, codes);
        generateArduinoCode(config, codes).writeln;

    }catch(ArgumentException ae){
        ae.msg.writelnError;
        return;
    }catch(FileException fe){
        fe.msg.writelnError;
        return;
    }catch(JSONException je){
        je.msg.writelnError;
        return;
    }catch(SourceCodeSyntaxError scse){
        ((scse.tag == "" ? "" : "Tag '" ~ scse.tag ~ "' : ") ~ scse.msg).writelnError;
        return;
    }
}
