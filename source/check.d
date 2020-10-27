module check;

import std.algorithm;

import exception;
import parse;


void checkConfiguration(const Configuration conf,const string[ubyte][string] codes){
    if(!("Default" in codes))
        throw new SourceCodeSyntaxError("Tag 'Default' isn't defined in source code.");
    foreach(p; conf.patternOrder){
        if(!(p in codes))
            throw new SourceCodeSyntaxError("Tag '" ~ p ~ "' isn't defined in source code.");
    }
}
