module generate;


import std.format : format;
import exception;
import parse;

string generateArduinoCode(const Configuration config, const string[ubyte][string] codes){
    string code;

    code ~= generatePresettings(config);
    code ~= generateMode(config);
    code ~= generatePinFunctions(config, codes);
    code ~= generateFunctionArrays(config, codes);
    code ~= generateGetFunctions(config);

    code ~= "void reset(){\n\twdt_dusable();\n\twdt_enable(WDTO_15MS);\n\twhile(1);\n}\n\n";
    code ~= "void setup(){\n\tfor(unsigned byte cnt = OUT_MIN; cnt <= OUT_MAX; cnt++){\n\t\tpinMode(cnt, OUTPUT);\n\t}\n\tdelay(1000);\n}\n\n";

    code ~= generateLoop(config);

    return code;
}

string generatePresettings(const Configuration config){
    import std.conv : to;
    string code;
    code = "#include <EEPROM.h>\n#include <avr/wdt.h>\n\nconst int ADDR_MODE = 0;\n";
    code ~= format("const unsigned int FLASH_CYCLE = %s;\n", config.flushCycle);
    code ~= "const unsigned byte DUTY_MAX = 100;\n";
    code ~= format("const unsigned byte DUTY_RATIO = %s;\n", (100*config.dutyRatio).to!ubyte);
    code ~= format("const unsigned byte OUT_MIN = %s\n", config.pinMin);
    code ~= format("const unsigned byte OUT_MAX = %s\n", config.pinMax);
    code ~= format("const char SW_MODE = %s\n\n",config.pinSW);
    return code;
}

string generateMode(const Configuration config){
    string code = "typedef enum{\n";
    foreach(i; 0..config.patternOrder.length){
        code ~= format("\t%s = %s;\n", config.patternOrder[i], i);
    }
    code ~= "}Mode;\n\n";
    return code;
}

string generatePinFunctions(const Configuration config, const string[ubyte][string] codes){
    string code;
    foreach(tag; "Default" ~ config.patternOrder){
        import std.range : iota;
        import std.conv : to;
        import std.algorithm : map;
        foreach(pin; config.pinInterval){
            code ~= format("float %s_pin%s(float phase){\n", tag, pin);
            if(pin in codes[tag])
                code ~= format("\t%s\n",codes[tag][pin]);
            else if(pin in codes["Default"])
                code ~= format("\t%s\n",codes["Default"][pin]);
            else
                code ~= "\treturn 0;\n";
            code ~= "}\n\n";
        }
    }
    return code;
}

string generateFunctionArrays(const Configuration config, const string[ubyte][string] codes){
    string code;
    foreach(tag; codes.keys){
        import std.algorithm : map;
        code ~= format("float (*%sFunctions[])(float) = { ", tag);
        import std.range : popBack;
        auto interval = config.pinInterval;
        interval.popBack;
        foreach(pin; interval){
            code ~= format("%s_pin%s, ", tag, pin);
        }
        code ~= format("%s_pin%s };\n", tag, config.pinMax);
    }
    code ~= "\n";
    return code;
}

string generateGetFunctions(const Configuration config){
    string code;
    {
        code ~= "float (*getFunctions(Mode mode, unsigned byte index))(float){\n";
        scope(exit) code ~= "}\n\n";
        {
            code ~= "\tswitch(mode){\n";
            scope(exit) code ~= "\t}\n";
            foreach(tag; config.patternOrder){
                code ~= format("\t\tcase %s:\n", tag);
                code ~= format("\t\t\treturn %sFunctions[index];\n", tag);
            }
            code ~= "\t\tdefault:\n\t\t\treturn NULL;\n";
        }
    }
    return code;
}

string generateLoop(const Configuration config){
    string code;
    {
        code ~= "void loop(){\n";
        scope(exit) code ~= "}";
        code ~= "\tMode mode = (Mode)EEPROM.read(ADDR_MODE);\n\n";
        code ~= format("\tif(mode > %s)\n\t\tmode = %s;\n\n", config.patternOrder[$-1], config.patternOrder[0]);
        code ~= "\tfloat phase_now = 0;\n\n";
        {
            code ~= "\twhile(1){\n";
            scope(exit) code ~= "\t}\n";
            {
                code ~= "\t\tif(digitalRead(SW_MODE) == HIGH){\n";
                scope(exit) code ~= "\t\t}\n\n";
                code ~= "\t\t\tEEPROM.write(ADDR_MODE, mode + 1);\n";
                code ~= "\t\t\treset();\n";
            }
            code ~= "\t\tpahse_now = (float)(mills() % FLASH_CYCLE)/(float)FLASH_CYCLE * 2. * PI;\n\n";
            {
                code ~= "\t\tfor(unsigned byte pwm_count = 0; pwm_count <= DUTY_MAX; pwm_count++){\n";
                scope(exit) code ~= "\t\t}\n";
                {
                    code ~= "\t\t\tfor(unsigned byte pin = OUT_MIN; pin <= OUT_MAX; pin++){\n";
                    scope(exit) code ~= "\t\t\t}\n";
                    code ~= "\t\t\t\tif(pwm_count > DUTY_RATIO)\n";
                    code ~= "\t\t\t\t\tdigitalWrite(pin, LOW);\n";
                    {
                        code ~= "\t\t\t\telse{\n";
                        scope(exit) code ~= "\t\t\t\t}\n";
                        code ~= "\t\t\t\t\tif((float)pwm_count <= (float)DUTY_RATIO*getFunctions(mode, pin-OUT_MIN)(phase_now))\n";
                        code ~= "\t\t\t\t\t\tdigitalWrite(pin + OUT_MIN, HIGH);\n";
                        code ~= "\t\t\t\t\telse\n";
                        code ~= "\t\t\t\t\t\tdigitalWrite(pin + OUT_MIN, LOW);\n";
                    }
                }
            }
        }
    }

    return code;
}
