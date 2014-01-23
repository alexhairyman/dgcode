enum CommandType
{
  HOVERTO,
  CUTTO,
  DRILLHOLE
}

abstract class _Command
{
  protected:
    string command_;
    string[string][] param_list_;
  public:
  void SetParams(string[string][] plist)
  {
    foreach(string[string] element; plist)
    {
      foreach(string key, string value; element)
      {
        assert(key == "X" || key == "Y" || key == "Z" || key == "F");
      }
    }
  }
}

class Command : _Command {}

class CutTo : Command
{
  
}

class CommandSet
{
  private Command[] commands;
  void AddCommand(ref Command commandin)
  {
    commands ~= commandin;
  }
}

class GCodeObject
{
  private CommandSet command_set;
}
