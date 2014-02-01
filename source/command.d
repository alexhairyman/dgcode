version(unittest)
{
  import test;
}
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

struct Coordinate
{
public:
  float X;
  float Y;
  float Z;

  static Coordinate dupcoord(ref Coordinate incoord)
  {
    Coordinate c;
    c.X = incoord.X;
    c.Y = incoord.Y;
    c.Z = incoord.Z;
    return c;
  }

  unittest
  {
    Coordinate c1, c2;

    mixin( testsay!("coordinate test start"));
    c1.X = 2; c1.Y = 2; c1.Z = 2;
    c2 = c1;
    c2.X = 3; c2.Y = 3; c2.Z = 3;
    assert(c2.X == 3 && c1.X == 2);
    assert(c2.Y == 3 && c1.Y == 2);
    assert(c2.Z == 3 && c1.Z == 2);

    mixin( testsay!("coordinate test end"));
  }

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
  string GenerateGCode() {return "DO NOT USE DGObject";}
  @property DGType dgtype() { return this.dgtype_;}
  @property void dgtype(DGType x) {this.dgtype_ = x;}
  
}

class Hole : DGObject
{
protected:
  float[2] XY; /// XY coordinates
}

class Line : DGObject
{
protected:
  Coordinate from_, to_; /// XY from and to
  CutMethod cutmethod_;
public:
  @property CutMethod cutmethod() {return this.cutmethod_;}
  @property void cutmethod(CutMethod x) {this.cutmethod_ = x;}

  @property void fromX(float x) {this.from_.X = x;}
  @property float fromX() {return this.from_.X;}

  @property void toX(float x) {this.to_.X = x;}
  @property float toX() {return this.to_.X;}

  @property void fromY(float x) {this.from_.Y = x;}
  @property float fromY() {return this.from_.Y;}

  @property void toY(float x) {this.to_.Y = x;}
  @property float toY() {return this.to_.Y;}
}

unittest
{
  Line l1 = new Line();
  l1.fromX = 1.1f;
  l1.fromY = 1.2f;
  l1.toX = 2.1f;
  l1.toY = 2.2f;
  mixin(testsay!("set all the variables"));

  assert(l1.fromX == 1.1f);
  assert(l1.fromY == 1.2f);
  assert(l1.toX == 2.1f);
  assert(l1.toY == 2.2f);
  mixin (testsay!("Variables all set correctly"));
    
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
