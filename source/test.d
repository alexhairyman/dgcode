import command;
import parse;
//import std.stdio;

version(unittest)
{

  int x(){return -3;}
  public import std.stdio, std.conv, std.exception, std.traits;
  template testsay(string say)
  {
    const char[] testsay = "writeln (\"\\n---Unit test: " ~ say ~ " ---\");";
  }

  template dotest(string tdo)
  {
    const char[] dotest = `writeln("    ` ~ tdo ~ `: ", text(` ~ tdo ~ `));`;
  }
  
  unittest
  {
    mixin(testsay!"HOLA");
    mixin(dotest!`x()`);
  }
}
version(testmain) 
{
  void main()
  {
    // Command notgood = new Command();
    // notgood.SetParams([["X" : "5"], ["Y" : "5"]]);
    
    writeln("HOLA");
    //notgood.SetParams([["S" : "SHEET"]]);
    // destroy (notgood);
  }
}
