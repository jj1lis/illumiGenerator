module exception;

class ArgumentException : Exception{
    this(string msg){
        super(msg);
    }
}

class SourceCodeSyntaxError : Exception{
    string tag;
    this(string msg){
        super(msg);
    }
    this(string msg, string tag){
        super(msg);
        this.tag = tag;
    }
}
