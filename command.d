enum CommandType
{
  HOVERTO,
  CUTTO,
  DRILLHOLE
}

abstract class Command
{
  protected:
    string command_;
    string[string][] param_list_;
  public:
    //string GetGcode();
}

class CutTo : Command
{
  void SetCommands(string[string][] plist)
  {
    foreach(string[string] element; plist)
    {
      foreach(string key, string value; element)
      {

      }
    }
  }
  
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
