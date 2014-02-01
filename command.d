enum CommandType
{
  HOVERTO,
  CUTTO,
  DRILLHOLE
}

enum DGType
{
  HOLE,
  LINE,
  OUTLINE  
}

enum CutMethod
{
  LIGHTNING,
  ZIGZAG,
  LAYER
}

enum OffsetSide
{
  LEFT,
  RIGHT
}

version (commandmain) {
  import std.typecons;
  
  void main()
  {
    alias Tuple!(float, "X", float, "Y") XYcoord;
    XYcoord c1,c2,c3;
  }
}

class DGObject
{
private:
  DGType dgtype_;

public:
  abstract string GenerateGCode();
  
}

class Hole : DGObject
{
protected:
  float[2] XY; /// XY coordinates
}

class Line : DGObject
{
protected:
  float[2] XYFrom, XYTo; /// XY from and to
  CutMethod cutmethod_;
public:
  this() {}
  @property CutMethod cutmethod() {return this.cutmethod_;}
  @property void cutmethod(CutMethod x) {this.cutmethod_ = x;}

  @property void fromX(float x) {this.XYFrom[0] = x;}
  @property float fromX() {return this.XYFrom[0];}

  @property void toX(float x) {this.XYTo[0] = x;}
  @property float toX() {return this.XYTo[0];}

  @property void fromY(float x) {this.XYFrom[1] = x;}
  @property float fromY() {return this.XYFrom[1];}

  @property void toY(float x) {this.XYTo[1] = x;}
  @property float toY() {return this.XYTo[1];}
}

class Outline : DGObject
{
protected:
  Line[] outlines_;
  CutMethod cut_method_;
  float tool_radius_;
  bool use_offset_;
  OffsetSide side_to_use_;

public:
  @property void offsetside(OffsetSide x) {this.side_to_use_=x;}
  @property OffsetSide  offsetside() {return this.side_to_use_;}

  @property Line[] lines() {return this.outlines_;}

  void AddLine (Line toadd)
  {
    // add some kind of error handling
    outlines_ ~= toadd;
  }

  Line GetLine (int arrindex)
  {
    Line toreturn = null;
    if(arrindex < outlines_.length) 
      toreturn = outlines_[arrindex];
    else
      throw new Exception("array index out of bounds");
    return toreturn;
  }

  

}



class Document
{
private:
  DGObject[] dgobjects_;

    
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
{}

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
