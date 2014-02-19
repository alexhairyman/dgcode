//import command;
//import parse;
module test;
//import std.stdio;

//version(unittest)
//{

  int x(){return -3;}
  public import std.stdio, std.conv, std.exception, std.traits;
  template testsay(string say)
  {
    const char[] testsay = `writeln (q"<---Unit test: ` ~ say ~ ` --->");`;
  }

//  template dotest_(string tdo, bool newline=false)
//  {
//    static char[] yup()
//    {
//      const char[] dotest;
//      if(newline == true){
//        dotest = `writeln(q"<    ` ~ tdo ~ `: >","\n", text(` ~ tdo ~ `));`;}
//      else{
//        dotest = `writeln(q"<    ` ~ tdo ~ `: >", text(` ~ tdo ~ `));`;}
//      return dotest;
//    }
//  }
  string dotest_(string tdo, bool newline=true)
  {
    string dotest;
    if(newline == true)
      dotest = `writeln(q"<    ` ~ tdo ~ `: >","\n", text(` ~ tdo ~ `));`;
    else
      dotest = `writeln(q"<    ` ~ tdo ~ `: >", text(` ~ tdo ~ `));`;
    
    return dotest;
  }
  template dotest(string tdo, bool newline=true)
  {
    const char[] dotest = dotest_(tdo,newline);
  }
  
  template wtest(string tdo)
  {
    const char[] wtest = `writeln("  ` ~ tdo ~ `");`;
  }
  
  unittest
  {
    mixin(testsay!"HOLA");
    mixin(dotest!`x()`);
  }
//}
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
