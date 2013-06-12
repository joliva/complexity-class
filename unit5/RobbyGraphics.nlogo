globals [NumCans Score WallPenalty CanReward PickUpPenalty StateVar CurrentAction 
  NORTHBASE SOUTHBASE EASTBASE WESTBASE CENTERBASE
  MOVENORTH MOVESOUTH MOVEEAST MOVEWEST STAYPUT PICKUP MOVERANDOM
  WALL HAS_CAN EMPTY]
breed [robots robot]
breed [cans can]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  
  initialize-parameters
  initialize-globals
  draw-grid
  initialize-cans  
  initialize-robby
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
 ask robots [calculate-state]
 lookup-action 
 ask robots [perform-action]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-state
  
  set StateVar 0
  
  ; North
  set heading 0 ; Face north
  ifelse (pycor = 9) ; North is a wall
  [
    set StateVar StateVar + NORTHBASE * WALL
  ]
  [ 
    ifelse (any? cans-on patch-ahead 1) [
      set StateVar StateVar + NORTHBASE * HAS_CAN
    ]
    [
      set StateVar StateVar + NORTHBASE * EMPTY
    ]
    
  ]
  
  ; South
  set heading 180 ; Face south
  ifelse (pycor = 0) ; South is a wall
  [
    set StateVar StateVar + SOUTHBASE * WALL
  ]
  [ 
    ifelse (any? cans-on patch-ahead 1) [
      set StateVar StateVar + SOUTHBASE * HAS_CAN
    ]
    [
      set StateVar StateVar + SOUTHBASE * EMPTY
    ]
  ]
  
  ; East
  set heading 90 ; Face east
  ifelse (pxcor = 9) ; East is a wall
  [
    set StateVar StateVar + EASTBASE * WALL
  ]
  [ 
    ifelse (any? cans-on patch-ahead 1) [
      set StateVar StateVar + EASTBASE * HAS_CAN
    ]
    [
      set StateVar StateVar + EASTBASE * EMPTY
    ]
  ]
  
  ; West
  set heading 270 ; Face west
  ifelse (pxcor = 0) ; West is a wall
  [
    set StateVar StateVar + WESTBASE * WALL
  ]
  [ 
    ifelse (any? cans-on patch-ahead 1) [
      set StateVar StateVar + WESTBASE * HAS_CAN
    ]
    [
      set StateVar StateVar + WESTBASE * EMPTY
    ]
  ]
  
  ; Center
  ; Skip test for wall, since center cell is not a wall
  ifelse (any? cans-on patch-here) [
    set StateVar StateVar + CENTERBASE * HAS_CAN
  ]
  [
    set StateVar StateVar + CENTERBASE * EMPTY
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to lookup-action
  set CurrentAction (item StateVar strategy)
  if (CurrentAction = MOVENORTH) [output-print "Move North"]
  if (CurrentAction = MOVESOUTH) [output-print "Move South"]
  if (CurrentAction = MOVEEAST) [output-print "Move East"]
  if (CurrentAction = MOVEWEST) [output-print "Move West"]
  if (CurrentAction = STAYPUT) [output-print "Stay Put"]
  if (CurrentAction = MOVERANDOM) [output-print "Move Random"]
  if (CurrentAction = PICKUP) [output-print "Pick Up"] 
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to perform-action
 if (CurrentAction = MOVENORTH) [move-north]
 if (CurrentAction = MOVESOUTH) [move-south]
 if (CurrentAction = MOVEEAST) [move-east]
 if (CurrentAction = MOVEWEST)[move-west]
 if (CurrentAction = MOVERANDOM) [move-random]
 if (CurrentAction = STAYPUT) [stay-put]
 if (CurrentAction = PICKUP) [pick-up-can]
end
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to initialize-parameters
  set NumCans 50
  set Score 0 
  set WallPenalty 5
  set CanReward 10
  set PickUpPenalty 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to initialize-globals
  ; Bases for determining state integer
  set NORTHBASE 81
  set SOUTHBASE 27
  set EASTBASE 9
  set WESTBASE 3
  set CENTERBASE 1
  
  ; Action codes
  set MOVENORTH "0"
  set MOVESOUTH "1"
  set MOVEEAST "2"
  set MOVEWEST "3"
  set STAYPUT "4"
  set PICKUP "5"
  set MOVERANDOM "6"
  
  ; Cell contents codes
  SET EMPTY 0
  set HAS_CAN 1
  set WALL 2
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to draw-grid
  let xp 0
  let yp 0
  while [yp < 10] [
    while [xp < 10] [
      ask patch xp yp
      [set pcolor white
        sprout 1]
      set xp xp + 1
    ]
    set xp 0
    set yp yp + 1
  ]
 ask turtles [
  set xcor (pxcor - .5)
  set ycor (pycor - .5)
  set heading 0
  set color black
  pen-down
  fd 1
  pen-up
  set heading 90
  pen-down
  fd 1
  pen-up
  set heading 180
  pen-down
  fd 1
  pen-up
  set heading 270
  pen-down
  fd 1
  pen-up
  die
 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to initialize-cans
  ask n-of NumCans patches with [(pxcor < 10) and (pycor < 10)] [ sprout-cans 1 ]
  ask cans [set shape "circle"]
  ask cans [set color red]
  ask cans [set size .3]
  ask cans [set ycor (pycor - .33)]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to initialize-robby
  create-robots 1
  ask robots [set shape "person"]
  ask robots [move-to (patch 0 9)]
  ask robots [set color green]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-north
  set CurrentAction "Move north"
; if wall, bounce back
  set heading 0

  ifelse (pycor = 9) 
  [
    set Score (Score - WallPenalty)
  ]
  [
    set ycor (pycor + 1)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-south
   set CurrentAction "Move south"
; if wall, bounce back
  set heading 180

  ifelse (pycor = 0) 
  [
    set Score (Score - WallPenalty)
  ]
  [
    set ycor (pycor - 1)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-east
   set CurrentAction "Move east"
; if wall, bounce back
  set heading 90

  ifelse (pxcor = 9) 
  [
    set Score (Score - WallPenalty)
  ]
  [
    set xcor (pxcor + 1)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-west
   set CurrentAction "Move west"
; if wall, bounce back
  
  set heading 90

  ifelse (pxcor = 0) 
  [
    set Score (Score - WallPenalty)
  ]
  [
    set xcor (pxcor - 1)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-random
  ; choose a direction to move in
  let neighbor-list ["N" "S" "E" "W"]
  let direction one-of neighbor-list
  if (direction = "N") [
    ask self [move-north]]
  if (direction = "S") [
    ask self [move-south]]
  if (direction = "E") [
    ask self [move-east]]
  if (direction = "W") [
    ask self [move-west]]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to stay-put
  ; Do nothing
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to pick-up-can
  ifelse (any? cans-on patch-here)
  [ ; Can here
    ask cans-here [die]
    set Score (Score + CanReward)
  ]
  [ ; No can here
    set Score (Score - PickUpPenalty)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
302
10
642
371
-1
-1
30.0
1
10
1
1
1
0
0
0
1
0
10
0
10
0
0
1
ticks

BUTTON
7
91
84
124
Initialize
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

INPUTBOX
5
16
236
76
strategy
null
1
0
String

BUTTON
171
93
234
126
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
207
155
279
200
Score
Score
17
1
11

OUTPUT
4
154
193
253
12

@#$#@#$#@
WHAT IS IT?
-----------
This program displays the actions of a strategy for Robby the Robot.  Strategies are represented as 243-digit strings.   This program is meant to be used in conjunction with the "Robby the Robot Genetic Algorithm in C" program, written by Melanie Mitchell. 

HOW IT WORKS
------------


HOW TO USE IT
-------------
Input a 243-digit string (representing a strategy for Robby the Robot).  The easiest way to do this is to cut from the output from the GA program and paste the strategy into the "Strategy" box.  (The word "null" should be cut from the strategy box before inputting a new strategy.)  Make sure there are no line breaks in the 243-digit string.  

To run Robby on a randomly-generated environment, click on the "Initialize" button, and then click on the "Go" button each time you want Robby to take the next action.  In this version, there is no way to have Robby act "continuously"; instead you need to click the "Go" button for each action.  The current action and score will be displayed in the boxes below the "Initialize" and "Go" buttons.   


THINGS TO NOTICE
----------------



THINGS TO TRY
-------------


EXTENDING THE MODEL
-------------------


NETLOGO FEATURES
----------------


RELATED MODELS
--------------


CREDITS AND REFERENCES
----------------------
Written by Melanie Mitchell. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
