module parse;

import exception;
import io;


class Configuration{
    import std.json;
    private:
    ubyte pin_max;
    ubyte pin_min;
    string pin_sw;
    uint flush_cycle;
    float duty_ratio;
    string[] _sources;
    string[] pattern_order;

    public:
    invariant(0 <= duty_ratio && duty_ratio <= 1);
    this(JSONValue json){
        import std.conv : to;
        import std.algorithm : map;
        import std.array : join, array;
        import std.file : readText;
        pin_max = json["pinMax"].integer.to!ubyte;
        pin_min = json["pinMin"].integer.to!ubyte;
        pin_sw  = json["pinSW"].str;
        flush_cycle = json["flushCycle"].integer.to!uint;
        duty_ratio    = json["dutyRatio"].floating.to!float;
        _sources = json["functionSources"].array.map!(v => v.str).array;
        pattern_order = json["patternOrder"].array.map!(p => p.str).array;
    }

    @property @safe{
        auto pinMax(){ return this.pin_max; }
        auto pinMax(ubyte pin_max){
            this.pin_max = pin_max;
        }

        auto pinMin(){ return this.pin_min; }
        auto pinMin(ubyte pin_min){
            this.pin_min = pin_min;
        }

        auto pinSW(){ return this.pin_sw; }
        auto pinSW(string pin_sw){
            this.pin_sw = pin_sw;
        }

        auto flushCycle(){ return this.flush_cycle; }
        auto flushCycle(uint flush_cycle){
            this.flush_cycle = flush_cycle;
        }

        auto dutyRatio(){ return this.duty_ratio; }
        auto dutyRatio(float duty_ratio){
            this.duty_ratio = duty_ratio;
        }

        auto sources(){ return _sources; }

        auto patternOrder(){ return pattern_order; }

        auto pinInterval(){
            import std.range : iota;
            import std.algorithm : map;
            import std.conv : to;
            return iota(pinMin, pinMax + 1).map!(p => p.to!ubyte);
        }
    }
}


class ControlCode{
    private:
        string _tag;
        string[ubyte] _pinfunctions;

    public:
        this(string _tag, string[ubyte] _pinfunctions){
            this._tag = _tag;
            this._pinfunctions = _pinfunctions;
        }

        @property @safe{
            string tag(){ return this._tag; }
            string[ubyte] pinfunctions(){ return this._pinfunctions; }
        }
}


auto parseCode(string rawcode){

    auto code = (string code){
        import std.string : strip, splitLines;
        import std.algorithm : map;
        import std.array : join;
        return code.splitLines.map!(l => l.strip).join;
    }(rawcode);

    string[ubyte][string] codes;
    {
        char[] queue;
        size_t depth;
        string tag;
        ubyte[] pins;

        try{
            foreach(c; code){
                switch(c){
                    case '{':
                        switch(depth){
                            case 0:
                                tag = queue.dup;
                                queue.length = 0;
                                break;
                            case 1:
                                pins = queue.dup.parsePins;
                                queue.length = 0;
                                break;
                            default:
                                queue ~= c;
                        }
                        depth++;
                        break;
                    case '}':
                        depth--;
                        if(depth == 1){
                            import std.algorithm : each;
                            pins.each!(p => codes[tag][p] = queue.dup);
                            pins.length = 0;
                            queue.length = 0;
                        }else if(depth != 0)
                            queue ~= '}';
                        break;
                    default:
                        queue ~= c;
                }
            }
        }catch(SourceCodeSyntaxError scse){
            throw new SourceCodeSyntaxError(scse.msg, tag);
        }
    }

    return codes;
    //import std.algorithm : map;
    //import std.array : array;
    //return codes.keys.map!(tag =>new ControlCode(tag, codes[tag])).array;
}


ubyte[] parsePins(const string str){
    ubyte[] pins;
    {
        bool interval_flag;
        ubyte prev;
        char[] queue;
        import std.array : split, array;
        import std.conv : to;
        import std.range : iota;
        foreach(c; str.split("pin_")[1]){
            switch(c){
                case ',':
                    if(interval_flag){
                        pins ~= iota(prev, queue.to!ubyte + 1).array.to!(ubyte[]);
                        interval_flag = false;
                    }else
                        pins ~= queue.to!ubyte;
                    queue.length = 0;
                    break;
                case '-':
                    if(interval_flag)
                        throw new SourceCodeSyntaxError("There are some errors in the notation of the function name.");
                    else{
                        prev = queue.to!ubyte;
                        interval_flag = true;
                        queue.length = 0;
                    }
                    break; 
                default:
                    queue ~= c;
            }
        }
        if(interval_flag)
            pins ~= iota(prev, queue.to!ubyte + 1).array.to!(ubyte[]);
        else
            pins ~= queue.to!ubyte;
    }
    return pins;
}
