import command;
import parse;
import std.stdio;

version(testmain) 
{
  void main()
  {
    Command notgood = new Command();
    notgood.SetParams([["X" : "5"], ["Y" : "5"]]);
    
    writeln("HOLA");
    //notgood.SetParams([["S" : "SHEET"]]);
    destroy (notgood);
  }
}
