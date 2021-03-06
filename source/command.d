module command;
import std.conv;

version(unittest)
{
  import test;
  import std.stdio;
  public enum usedebug = 1;
//  debug = 2;
}

debug import std.stdio;
debug import test;
debug debug = 1;
unittest
{  
  writeln("unittests enabled");
  string dbgstring;
  debug dbgstring = "debug enabled";
  writeln(dbgstring);
}


version(noconfig) {enum NOCONFIG =  true  ;}
else              {enum NOCONFIG =  false ;}

static if(!NOCONFIG) 
{
  package enum float defhoverheight = 0.2f; /// $(RED this is bad mkay)
  package enum float defcutheight = 0.81f; /// $(RED this is bad mkay)
}

enum GCODE = 0x01;

package 
{
  alias GCodeArgument _gca;
  alias GCodeLetterType _gclt;
  alias GCodeCommandType _gcct;
}

deprecated package const char[] gmxn = `alias GCodeArgument _gca;`;
deprecated enum CommandType
{
  HOVERTO,
  CUTTO,
  DRILLHOLE
}

/// the Type of object
enum DGType
{
  HOLE = 1,
  LINE,
  OUTLINE  
}

/// the method for cutting  
/// $(RED only use layer for now)
enum CutMethod
{
  LIGHTNING = 1,
  ZIGZAG,
  LAYER
}

/// lolnope, not used right now
deprecated enum OffsetSide
{
  LEFT,
  RIGHT
}

/// GCodeLetterType what kinda letter is it?
enum GCodeLetterType
{
  FEEDRATE = 1,
  XCOORD,
  YCOORD,
  ZCOORD,
  RADIUS
}

/// GCodeCommandType what kinda command is it?
enum GCodeCommandType
{
  RAPID = 1,
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
  
  /// set the letter type and the float value
  void Set(GCodeLetterType gcltin, float vtin)
  {
    this.holdval_ = vtin;
    this.gclt_ = gcltin;
  }
  
  static typeof(this) make(GCodeLetterType gcltin, float vtin)
  {
    return gmake(gcltin, vtin);
  }
  /// initialize this GCodeArgument with initial values
  this(GCodeLetterType gcltin, float vtin)
  {
    this.Set(gcltin, vtin);
  }
  
  /// Generate the GCode and return it
  string GenerateGCode()
  {
    string tstr;
    tstr ~= this.lcodes_[this.gclt_];
    tstr ~= text(this.holdval_);
    return tstr;
  }
}

/// helper function to generate a GCodeArgument
static GCodeArgument gmake(GCodeLetterType gcltin, float vtin)
{
  GCodeArgument gcat = new GCodeArgument(gcltin, vtin);
  return gcat;
}

unittest
{
  mixin(test.testsay!`Doing GCodeArgument tests`);
  GCodeArgument gca1 = GCodeArgument.make(GCodeLetterType.XCOORD, 0f);
  mixin(test.dotest!(`gca1.GenerateGCode() == "X0"`));
  GCodeArgument gca2 = GCodeArgument.make(GCodeLetterType.YCOORD, 0.33f);
  mixin(test.dotest!`gca2.GenerateGCode() == "Y0.33"`);
  
}

/// A GCodeCommand
/// contains the command type, and also a multi dimensional array of GCodeArguments, an array of arrays,
/// with each array being another line to be added to the array

class GCodeCommand
{
private:
  static string[GCodeCommandType] gcodes_;
  GCodeCommandType comtype_;
  
  /// each GCodeArgument[] is a new line of arguments
  GCodeArgument[][] arguments_;
  
public:
  /// initializes the array of command types
  static this()
  {
    GCodeCommand.gcodes_ = [
      GCodeCommandType.RAPID : "G00",
      GCodeCommandType.FEED : "G01",
      GCodeCommandType.OFFSET_RIGHT : "G42",
      GCodeCommandType.OFFSET_LEFT : "G41"
    ];
  }
  
  /// empty constructor
  this(){}
  /// create a GCodeCommand with everything already set up
  this(GCodeArgument[][] argsin, GCodeCommandType comin)
  {
    this.arguments_ = argsin.dup;
    this.comtype_ = comin;
  }
  
  /// return the array of arrays of arguments
  @property GCodeArgument[][] args() {return this.arguments_;}
  /// return the command type
  @property GCodeCommandType command() {return this.comtype_;}
  /// set the command type
  @property void command(GCodeCommandType gcin) {this.comtype_ = gcin;}
  
  /// add a single argument, creates an array literal with the argument input
  /// and calls the real ($D_CODE AddArgument)
  void AddArgument(GCodeArgument gcain)
  {
    this.AddArgument([gcain]);
  }
  
  /// adds a new array to the array of arrays
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
  
  mixin(test.wtest!`creating a GCodeCommand with constructor`);
  GCodeCommand gcc2 = new GCodeCommand([
    [gmake(_gclt.XCOORD, 3f), gmake(_gclt.YCOORD, 4f)],
    [gmake(_gclt.ZCOORD, defcutheight)]
  ], _gcct.FEED);
  
  mixin(test.dotest_("gcc2.GenerateGCode()"));
}

/// Just an X/Y coordinate
struct Coordinate
{
public:
  /// X value
  float X;
  /// Y value
  float Y;
  //float Z;

  /// construct from 2 floats
  this(float sx, float sy)
  {
    this.X = sx;
    this.Y = sy;
  }

  /// construct from float[2]
  this(float[2] infs) 
  {
    this(infs[0], infs[1]);
  }

  /// implicitly convert to float[2]
  @property float[2] tofloats() 
  {
    return [this.X,this.Y];
  }
  /// ditto
  alias tofloats this;
 
}

/// useless, Do Not Use
deprecated static Coordinate dupcoord(ref Coordinate incoord)
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

/// A DGcode Object
class DGObject
{
private:
  DGType dgtype_;
  deprecated float xbound_, ybound_, zbound_;

public:
  string GenerateGCode() {throw new Exception("DGOBJECT CANNOT BE INITIALIZED");}
  @property DGType dgtype() { return this.dgtype_;}
  @property void dgtype(DGType x) {this.dgtype_ = x;}

deprecated:
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

/// A hole
///
/// goes to the point, and drills down... simple

class Hole : DGObject
{
protected:
  Coordinate holecoord_; /// XY coordinates
  float feedrate_;
public:

  /// empty constructor
  this(){};
  /// build with a specific coordinate in mind
  ///
  /// $(RED the feedrate is set to 30, I need to implement the standard way of generating this)
  this (Coordinate coordset, float feedrate = 30f) 
  {
    this.holecoord_ = coordset;
    this.feedrate_ = feedrate;
  }
  
  /// set the variables, as straightforward as it sounds
  void Set(Coordinate coordset, float feedrate = 30f)
  {
    this.holecoord_ = coordset;
    this.feedrate_ = feedrate;
  }
  /// Generate GCode... duh
  /// First go up to hover height, move to point and then drop and cut, raise back up to cut height
  ///
  /// WARNING:
  /// tentatively ready
  ///
  override string GenerateGCode()
  {
    string gcode;
    GCodeCommand[3] commands;
    commands[0] = new GCodeCommand();
    commands[0].command = _gcct.RAPID;
    commands[0].AddArgument(_gca.make(_gclt.ZCOORD, defhoverheight));
    commands[0].AddArgument([_gca.make(_gclt.XCOORD, this.holecoord_.X), _gca.make(_gclt.YCOORD,
      this.holecoord_.Y)]);
    
    commands[1] = new GCodeCommand();
    commands[1].command = _gcct.FEED;
    commands[1].AddArgument(_gca.make(_gclt.FEEDRATE, this.feedrate_));
    commands[1].AddArgument(_gca.make(_gclt.ZCOORD, defcutheight));
    
    commands[2] = new GCodeCommand();
    commands[2].command = _gcct.RAPID;
    commands[2].AddArgument(_gca.make(_gclt.ZCOORD, defhoverheight));
    
    // I didn't think it would work that quickly
    foreach(GCodeCommand tgcc_; commands)
    {
      gcode ~= tgcc_.GenerateGCode();
    }
    
    scope(exit)
    {
      for(ushort i = 0; i < commands.length; i++)
      {
        destroy(commands[i]);
      }
    }
    return gcode;
  }
}

unittest
{
  mixin(test.testsay!"Hole test");
  
  Hole h1 = new Hole();
  scope(exit) destroy(h1);
  
  h1.Set(Coordinate(3f, 4.5f));
  
  mixin(test.dotest!`h1.GenerateGCode()`);
  
}
/// Just a line
///
/// $(RED MIGHT GET TAKEN OUT)
class Line : DGObject
{
protected:
  Coordinate from_, to_; /// XY from and to
  CutMethod cutmethod_;
public:
  
  this() {}
  this(float[2] tfrom, float[2] tto) {this.from = tfrom; this.to = tto;}
  this(float tfromx, float tfromy, float ttox, float ttoy) {this([tfromx,tfromy], [ttox,ttoy]);}

  /// Generate GCode
  /// WARNING: NOT READY YET
  override string GenerateGCode()
  {
    string GCode = null;
    assert (this.cutmethod == CutMethod.LAYER, "JUST LAYER NOW");
    
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

/// contains a series of points
class OutLine : DGObject
{
protected:
  Coordinate[] coordinates_; /// big list of coordinates
  
  float cutheight_; /// height to cut at $(RED unnecessary with cutlayers_? Could just be cutlayers_[0])
  float[] cutlayers_; /// the ZCoord layers to decrement by
  float hoverheight_; /// the height to hover at when moving
  CutMethod cut_method_; /// which cutmethod to use
  float tool_radius_;
  float cutspeed_;
  
  deprecated bool use_offset_;
  deprecated Line[] outlines_;
  deprecated OffsetSide side_to_use_;

public:

  deprecated @property void offsetside(OffsetSide x) {this.side_to_use_=x;}
  deprecated @property OffsetSide offsetside() {return this.side_to_use_;}

  version (disable) {@property Line[] lines() {return this.outlines_;}}
  
  @property CutMethod cutmethod() {return this.cut_method_;}
  @property void cutmethod(CutMethod cmin) {this.cut_method_ = cmin;}
  
  @property float cutspeed() {return this.cutspeed_;}
  @property void cutspeed(float cmin) {this.cutspeed_ = cmin;}
  
  @property float[] cutlayers() {return this.cutlayers_;}
  @property void cutlayers (float[] inlyr) {this.cutlayers_ = inlyr;}
  
  @property float hoverheight(){return this.hoverheight_;}
  @property void hoverheight(float inht){this.hoverheight_ = inht;}
  /// return the coordinates
  @property Coordinate[] coordinates() {return this.coordinates_;}
  
  /// add a single coordinate
  void AddCoordinate(Coordinate toc)
  {
    this.coordinates_ ~= toc;
  }

  /// multiple coordinates
  ///
  /// calls original AddCoordinate foreach Coordinate in toadd
  void AddCoordinate(Coordinate[] toadd...)
  {
    foreach (Coordinate C ; toadd)
    {
      this.AddCoordinate(C);
    }
  }
  //alias AddCoordinates AddCoordinate; /// $(RED ERMMMM USE?)
  
  /// This is really logic heavy, mind you
  override string GenerateGCode()
  {
    assert(cutspeed_ != float.nan, "want cutspeed");
    assert(cutlayers_.length != 0, "want cutlayers");
    assert(cut_method_ != 0 && cut_method_ == CutMethod.LAYER, "want cut method");
    string gcode;
    
    if(this.cut_method_ == CutMethod.LAYER)
    {
      GCodeCommand[] tgcoms;
      debug mixin(test.dotest!`this.coordinates_.length`);
      debug mixin(test.dotest!`this.cutlayers_.length`);
      for(ubyte lyr = 0; lyr < this.cutlayers_.length; lyr++)
      {
        float clayer = this.cutlayers_[lyr];
        for(uint crd = 0; crd < this.coordinates_.length; crd++)
        {
          debug(2) mixin(test.dotest!(`lyr`, false));
          debug(2) mixin(test.dotest!(`crd`, false));
          if(crd == 0)
          {
            debug(2) mixin(test.wtest!`0`);
            tgcoms ~= new GCodeCommand([
              [gmake(_gclt.ZCOORD, clayer), gmake(_gclt.FEEDRATE, this.cutspeed_)],
              [gmake(_gclt.XCOORD, this.coordinates_[crd].X), gmake(_gclt.YCOORD, this.coordinates_[crd].Y)]], _gcct.FEED);
          }
          else
          {
            debug(2) mixin(test.wtest!`!0`);
//            tgcoms[lyr].AddArgument(gmake(_gclt.FEEDRATE, this.cutspeed_));
            tgcoms[lyr].AddArgument([gmake(_gclt.XCOORD, this.coordinates_[crd].X), gmake(_gclt.YCOORD, this.coordinates_[crd].Y)]);
          }
          debug(2) writeln();
        }
      }
      foreach(GCodeCommand gcc; tgcoms)
      {
        gcode ~= gcc.GenerateGCode();
      }
    }
    
    return gcode;
  }
  
  /// $(RED dun broke)
  deprecated void AddLine (Line toadd)
  {
    outlines_ ~= toadd;
  }
  
  /// ditto
  deprecated void AddPoint (Coordinate togoto)
  {
    if (coordinates_.length < 1)
      throw new Exception("NEED AN INITIAL COORDINATE TO START WITH");
    else
      this.AddCoordinate(togoto);
  }
  
  /// ditto
  deprecated Line GetLine (int arrindex)
  {
    Line toreturn = null;
    if(arrindex < outlines_.length) 
      toreturn = outlines_[arrindex];
    else
      throw new Exception("array index out of bounds");
    return toreturn;
  }
}

unittest
{
  mixin(test.testsay!"Outline tests");
  OutLine lshape = new OutLine();
  lshape.cutspeed = 30f;
  lshape.cutmethod = CutMethod.LAYER;
  lshape.cutlayers = [-0.1f,-0.2f,-0.3f,-0.4f,-0.51f];
  mixin(test.dotest!`lshape.cutlayers`);
  lshape.AddCoordinate(Coordinate(0f,0f));
  lshape.AddCoordinate(Coordinate(5f,0f));
  lshape.AddCoordinate(Coordinate(5f,1f));
  lshape.AddCoordinate(Coordinate(1f,1f));
  lshape.AddCoordinate(Coordinate(1f,5f));
  lshape.AddCoordinate(Coordinate(0f,5f));
  lshape.AddCoordinate(Coordinate(0f,0f));
  mixin(test.dotest!"lshape.GenerateGCode()");
  // WOW! THIS IS VERY VERY GOOD
  
  // lshape.AddLine(new Line([0f, 0f] , [5f,0f]);
}

/// holds a whole lotta(' shakin going on) DGObjects
@disable class Document
{
private:
  DGObject[] dgobjects_;

    
}

/// $(RED $(B $(U $(I $(BIG DEPRECATED))))) $(BR)
/// Yeah no
///
/// All of these are deprecated
///
/// BUGS:
/// Just don't use okay
///
deprecated abstract class _Command
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

/// ditto
deprecated class Command : _Command {}

/// ditto
deprecated class CutTo : Command
{}

/// ditto
deprecated class CommandSet
{
  private Command[] commands;
  void AddCommand(ref Command commandin)
  {
    commands ~= commandin;
  }
}

/// ditto
deprecated class GCodeObject
{
  private CommandSet command_set;
}
