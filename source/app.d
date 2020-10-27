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
        if(args.length < 3)
            throw new ArgumentException("too few argument.");
        if(args.length > 3)
            throw new ArgumentException("too many arguments.");

        import std.array : join;
        auto config = new Configuration(args[1].readText.parseJSON);
        auto codes = config.sources.map!(path => path.readText).join.parseCode;
        auto filename = args[2];

        config.checkConfiguration(codes);
        //auto inocode = generateArduinoCode(config, codes);
        generateArduinoCode(config, codes).outputFile(filename);

    }catch(ArgumentException ae){
        ae.msg.writelnError;
        writelnNotice("./illumiGenerator <jsonfile> <outputname>");
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
