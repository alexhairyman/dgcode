## this is a basic overview of how the JSON should be formatted to make a cut
see the lcut.json file for an overview of basic format

settings documentation:
+ hoverheight : height at which the router should hover when moving quickly
+ cutheight : height at which router should be for cutting
+ feedrate : the default feedrate for cutting

command documentation:

+ drillhole
  + drills a single hole to height 0, simple right? Returns drill bit to top when done
  + parameters
    + F : feedrate, otherwise use default
    + Z : Z height to go to (optional)
+ hoverto
  + brings bit above the wood to move to a given position
  + parameters
    + X : x position
    + Y : Y position
    + Z : z position (optional, before anything happens the router is brought up to the hoverheight)
+ cutto
  + will cut from current position, so hoverto to go from a position
  + parameters are same for hoverto, with one extra:
    + F : feedrate (optional, will use default if not set)

