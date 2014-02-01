import command;
import parse;
//import std.stdio;

version(unittest)
{
  public import std.stdio;
  template testsay(string say) {const char[] testsay = "writeln (\"Unit test: " ~ say ~ "\");";}
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
