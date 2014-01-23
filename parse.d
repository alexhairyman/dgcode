// just parse the file into our format
import std.stdio;
import std.json;

void main(){}

version (oldtest)
{
  void main()
  {
    stdout.writeln("thinking of you");
    string filename = "lcut.json";
    string data, tmpline;
    File infile = File(filename);
    while ((tmpline = infile.readln()) != null)
    {
      data ~= tmpline;
    }
    //stdout.writeln(data);
    JSONValue jv = parseJSON(data);
    stdout.writeln("name of cut: " ~ jv["name"].str);
    uint icount = 0;
    foreach (size_t index, JSONValue command; jv["command"].array)
    {
      stdout.writeln("command: " ~ command[0].str);
      stdout.writeln("parameters: ");
      foreach(size_t param, JSONValue pval; command[1].object)
      {
        stdout.writeln(param ~ " : " ~ toJSON(&pval));
      }
    }
    
    infile.close;
  }
}
