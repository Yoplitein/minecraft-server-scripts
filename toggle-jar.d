#!/usr/bin/env rdmd

module toggle_jar;

import std.file;
import std.path;
import std.stdio;

int main(string[] args)
{
    if(args.length < 2)
    {
        stderr.writeln("toggle-jar.d <file.jar>");
        
        return 1;
    }
    
    string target = args[1];
    string newName;
    
    if(target.extension == ".disabled")
        newName = target.setExtension("");
    else
        newName = target.setExtension("jar.disabled");
    
    try
        rename(target, newName);
    catch(Exception err)
    {
        stderr.writeln(err.msg);
        
        return 1;
    }
    
    return 0;
}
