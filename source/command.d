module command;
import std.conv;

version(unittest)
{
  import test;
}

package const char[] gmxn = `alias GCodeArgument _gca;`;
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

/// GCodeLetterType what kinda letter is it?
enum GCodeLetterType
{
  FEEDRATE,
  XCOORD,
  YCOORD,
  ZCOORD,
  RADIUS
}

/// GCodeCommandType what kinda command is it?
enum GCodeCommandType
{
  RAPID,
  FEED,
  OFFSET_RIGHT,
  OFFSET_LEFT
}


/// currently only used for the float
union ValType
{
  int i;
  float f;
}

/// A single argument
/// LIKE THIS: X3.44 Y0.55 Z2 F60.0
class GCodeArgument
{
private:
  static string[GCodeLetterType] lcodes_;
  float holdval_;
  GCodeLetterType gclt_;
    
public:
  
  static this()
  {
    GCodeArgument.lcodes_ = [
      GCodeLetterType.FEEDRATE : "F",
      GCodeLetterType.RADIUS : "P",
      GCodeLetterType.XCOORD : "X",
      GCodeLetterType.YCOORD : "Y",
      GCodeLetterType.ZCOORD : "Z"
    ];
  }
  
  void Set(GCodeLetterType gcltin, float vtin)
  {
    this.holdval_ = vtin;
    this.gclt_ = gcltin;
  }
  
  this(GCodeLetterType gcltin, float vtin)
  {
    this.holdval_ = vtin;
    this.gclt_ = gcltin;
  }
  static GCodeArgument make(GCodeLetterType gcltin, float vtin)
  {
    GCodeArgument gcat = new GCodeArgument(gcltin, vtin);
    return gcat;
  }
  
  string GenerateGCode()
  {
    string tstr;
    tstr ~= this.lcodes_[this.gclt_];
    tstr ~= text(this.holdval_);
    return tstr;
  }
}

unittest
{
  mixin(test.testsay!`Doing GCodeArgument tests`);
  GCodeArgument gca1 = GCodeArgument.make(GCodeLetterType.XCOORD, 0f);
  mixin(test.dotest!(`gca1.GenerateGCode() == "X0"`));
  GCodeArgument gca2 = GCodeArgument.make(GCodeLetterType.YCOORD, 0.33f);
  mixin(test.dotest!`gca2.GenerateGCode() == "Y0.33"`);
  
}

class GCodeCommand
{
private:
  static string[GCodeCommandType] gcodes_;
  GCodeCommandType comtype_;
  
  /// each GCodeArgument[] is a new line of arguments
  GCodeArgument[][] arguments_;
  
public:

  static this()
  {
    GCodeCommand.gcodes_ = [
      GCodeCommandType.RAPID : "G00",
      GCodeCommandType.FEED : "G01",
      GCodeCommandType.OFFSET_RIGHT : "G42",
      GCodeCommandType.OFFSET_LEFT : "G41"
    ];
    
  }
  
  @property GCodeArgument[][] args() {return this.arguments_;}
  @property GCodeCommandType command() {return this.comtype_;}
  @property void command(GCodeCommandType gcin) {this.comtype_ = gcin;}
  
  void AddArgument(GCodeArgument gcain)
  {
    this.arguments_ ~= [gcain];
  }
  
  void AddArgument(GCodeArgument[] gcains)
  {
    this.arguments_ ~= gcains;
  }
  
  /// Generate the GCode for this command + arguments
  string GenerateGCode()
  {
    string tstring;
    tstring ~= this.gcodes_[this.command];
    
    foreach(GCodeArgument[] gca ; this.arguments_)
    {
      string dstr;
      dstr ~= " ";
      for (int i = 0; i < gca.length ; i++)
      {
        string dstr2;
        dstr2 = gca[i].GenerateGCode();
        if (i == gca.length-1) {dstr ~= dstr2 ~ "\n";} else {dstr ~= dstr2 ~ " ";}
      }
      //dstr = dstr[1..$-1] ~ '\n';
      tstring ~= dstr;
    }
    
    return tstring;
  }
  
}

unittest
{
  mixin(test.testsay!"GCodeArgument GCodeCommand tests");
  GCodeCommand gcc = new GCodeCommand();
  gcc.command = GCodeCommandType.RAPID;
  mixin(test.dotest!"gcc.command");
  mixin(test.wtest!("changed gcc.command to GCodeCommandType.FEED!"));
  gcc.command = GCodeCommandType.FEED;
  mixin(test.dotest!"gcc.command");
  alias GCodeArgument.make gmk;
  alias GCodeLetterType lt;
  gcc.AddArgument([gmk(lt.ZCOORD, 0.0f), gmk(lt.FEEDRATE, 20f)]);
  gcc.AddArgument(gmk(lt.XCOORD, 2.5f));
  gcc.AddArgument(gmk(lt.YCOORD, 2.5f));
  gcc.AddArgument([gmk(lt.XCOORD, 5f), gmk(lt.YCOORD, 5f)]);
  foreach(GCodeArgument[] g2; gcc.args)
  {
    mixin(test.wtest!("Line:"));
    foreach(GCodeArgument g; g2)
    {  
      mixin(test.dotest!(`g.GenerateGCode()`));
    }
  }
  mixin(test.testsay!("generating all gcode"));
  mixin(test.dotest!(`gcc.GenerateGCode()`, true));
}

struct Coordinate
{
public:
  float X;
  float Y;
  //float Z;

  this(float sx, float sy)
  {
    this.X = sx;
    this.Y = sy;
  }

  this(float[2] infs) 
  {
    this(infs[0], infs[1]);
  }

  @property float[2] tofloats() 
  {
    return [this.X,this.Y];
  }

  alias tofloats this;
 
}

static Coordinate dupcoord(ref Coordinate incoord)
{
  Coordinate c;
  c.X = incoord.X;
  c.Y = incoord.Y;
  //c.Z = incoord.Z;
  return c;
}

unittest
{
  Coordinate c1, c2;

  mixin( testsay!"coordinate test start");
  c1.X = 2.1f; c1.Y = 2.2f; // c1.Z = 2;
  c2 = c1;
  c2.X += 1.0f; c2.Y += 1.0f; // c2.Z = 3;

  mixin(dotest!`text(c1)`);
  mixin(dotest!`text(c2)`);

  assert(c2.X == 3.1f && c1.X == 2.1f);
  assert(c2.Y == 3.2f && c1.Y == 2.2f);
  
  //int ImplicitFloat(Coordinate inc){return -1;}
  mixin(testsay!"implicit/explicit cast test");
  float[2] cf1 = c1;
  float[2] cf2 = cast(float[2]) c2;
  mixin(dotest!`cast(float[2]) c2`);
  
  //ImplicitFloat([0f,1f]);

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
  float xbound_, ybound_, zbound_;

public:
  string GenerateGCode() {throw new Exception("DGOBJECT CANNOT BE INITIALIZED");}
  @property DGType dgtype() { return this.dgtype_;}
  @property void dgtype(DGType x) {this.dgtype_ = x;}

  @property float xbound() {return this.xbound_;}
  @property void xbound(float xb) { this.xbound_ = xb;}

  @property float ybound() {return this.ybound_;}
  @property void ybound(float xb) { this.ybound_ = xb;}

  @property float zbound() {return this.zbound_;}
  @property void zbound(float xb) { this.zbound_ = xb;}
  
}

unittest
{
  mixin (testsay!("DGObject tests"));
  DGObject dg1 = new DGObject();
  assertThrown(dg1.GenerateGCode());
  writeln("exception thrown when trying to run dg1.GenerateGCode()!");
}

class Hole : DGObject
{
protected:
  Coordinate holecoord_; /// XY coordinates
  float feedrate_;
public:
  this (Coordinate coordset, float feedrate = 30f) 
  {
    this.holecoord_ = coordset;
    this.feedrate_ = feedrate;
  }
  override string GenerateGCode()
  {
    alias GCodeArgument gca;
    alias GCodeLetterType gclt;
    string gcode;
    
    GCodeCommand gcc = new GCodeCommand;
    
    return gcode;
  }
}

class Line : DGObject
{
protected:
  Coordinate from_, to_; /// XY from and to
  CutMethod cutmethod_;
public:
  
  this() {}
  this(float[2] tfrom, float[2] tto) {this.from = tfrom; this.to = tto;}
  this(float tfromx, float tfromy, float ttox, float ttoy) {this([tfromx,tfromy], [ttox,ttoy]);}

  override string GenerateGCode()
  {
    string GCode = null;
    assert (this.cutmethod == CutMethod.ZIGZAG, "just zig zag for now"); // not an exception since it will be taken out eventually
    
    return GCode;
  }

  @property CutMethod cutmethod() {return this.cutmethod_;}
  @property void cutmethod(CutMethod x) {this.cutmethod_ = x;}

  @property void from(float[2] froms) {this.from_.X=froms[0];this.from_.Y=froms[1];}
  @property float[2] from() {return cast(float[2])[this.from_.X, this.from_.Y];}

  @property void to(float[2] tos) {this.to_.X=tos[0];this.to_.Y=tos[1];}
  @property float[2] to() {return cast(float[2])[this.to_.X, this.to_.Y];}

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
  mixin(testsay!("set all the from/to vars"));
  // writeln("showing data:");
  writeln("from (", l1.fromX, ",", l1.fromY, ") to (",l1.toX, ",", l1.toY, ")"); // holy god is this uglaaaay
  mixin (dotest!`[l1.fromX,l1.fromY],[l1.toX,l1.toY]`);
  assert(l1.fromX == 1.1f);
  assert(l1.fromY == 1.2f);
  assert(l1.toX == 2.1f);
  assert(l1.toY == 2.2f);
  mixin (testsay!("Variables all set correctly"));
  destroy (l1);
  
  writeln("Testing iffy properties now");
  Line l2 = new Line();
  l2.from = [3.1f, 3.2f];
  l2.to = [4.1f, 4.2f];

  assert (l2.from == [3.1f, 3.2f]);
  mixin( dotest!`l2.from, l2.to`);

  destroy(l2);

  Line l3 = new Line([0.0f,0.0f], [5.0f,5.0f]);
  
    
}

class OutLine : DGObject
{
protected:
  Coordinate[] coordinates_;
  Line[] outlines_;
  CutMethod cut_method_;
  float tool_radius_;
  bool use_offset_;
  OffsetSide side_to_use_;

public:
  @property void offsetside(OffsetSide x) {this.side_to_use_=x;}
  @property OffsetSide  offsetside() {return this.side_to_use_;}

  version (disable) {@property Line[] lines() {return this.outlines_;}}

  @property Coordinate[] coordinates() {return this.coordinates_;}
  void AddCoordinate(Coordinate toc)
  {
    this.coordinates_ ~= toc;
  }

  void AddCoordinate(Coordinate[] toadd...)
  {
    foreach (Coordinate C ; toadd)
    {
      this.AddCoordinate(C);
    }
  }
  
  version(disable)
  {
    void AddLine (Line toadd)
    {
      outlines_ ~= toadd;
    }
  }

  deprecated void AddPoint (Coordinate togoto)
  {
    if (coordinates_.length < 1)
      throw new Exception("NEED AN INITIAL COORDINATE TO START WITH");
    else
      this.AddCoordinate(togoto);
  }

  version(disable)
  {
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
}

unittest
{
  OutLine lshape = new OutLine();
  lshape.AddCoordinate(Coordinate(0f,0f));
  lshape.AddCoordinate(Coordinate([5f,5f]));
  
  // lshape.AddLine(new Line([0f, 0f] , [5f,0f]);
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
