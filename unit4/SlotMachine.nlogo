globals [reel-1 reel-2 reel-3 all-reels goal-macrostate non-macrostate]

to startup
  setup
end 

to setup
  ca
  paint-slot-machine
  ask patch -7 5 [sprout 1 [set reel-1 self set shape one-of ["lemon" "orange" "apple" "cherry" "pear"] set size 8 ]]
  ask patch -1 5 [sprout 1 [set reel-2 self set shape one-of ["lemon" "orange" "apple" "cherry" "pear"] set size 8 ]]
  ask patch 5 5  [sprout 1 [set reel-3 self set shape one-of ["lemon" "orange" "apple" "cherry" "pear"] set size 8 ]]
  set all-reels (turtle-set reel-1 reel-2 reel-3) ;create patchset to make it easy to refer to reels below
end 

to go
  clear-all-plots
  reset-ticks
  set goal-macrostate 0 set non-macrostate 0 
  animate-pull
  repeat NumberOfPulls [ 
    ask all-reels [set shape one-of ["lemon" "orange" "apple" "cherry" "pear"] ]
    
    if macrostates = "Three of the same kind" [
      ifelse (         
        [shape] of all-reels = ["cherry" "cherry" "cherry"] or 
        [shape] of all-reels = ["pear" "pear" "pear"] or 
        [shape] of all-reels = ["apple" "apple" "apple"] or 
        [shape] of all-reels = ["orange" "orange" "orange"] or 
        [shape] of all-reels = ["lemon" "lemon" "lemon"] 
        )
      ;A more compact (and obscure) way to accomplish the above:
      ; if length remove-duplicates [shape] of all-reels = 1 and macrostates = "Three of the same kind"
      ; This code eliminates the duplicate values and inspects to see how much the list was shortened.
      ; This has the advantage of drawing our attention to an important connection between compression and macrostates.
      ; We will use this technique below
      
      [wait .01 set goal-macrostate goal-macrostate + 1] [wait .01 set non-macrostate non-macrostate + 1]
   ]
    
    
  if macrostates = "At least two of the same kind" [
      ifelse length remove-duplicates [shape] of all-reels < 3
        [wait .01 set goal-macrostate goal-macrostate + 1] [wait .01 set non-macrostate non-macrostate + 1]
  ]
  
  
  if macrostates = "Exactly two pears"  [   
      ifelse length remove "pear" [shape] of all-reels = 1   
        [wait .01 set goal-macrostate goal-macrostate + 1] [wait .01 set non-macrostate non-macrostate + 1]
   ]
   
  if macrostates = "One orange and one cherry" [
    ifelse length remove "orange" [shape] of all-reels = 2 and length remove "cherry" [shape] of all-reels  = 2  
       [wait .04 set goal-macrostate goal-macrostate + 1] [wait .02 set non-macrostate non-macrostate + 1]
   ]
  
  if macrostates = "No apples or cherries" [
     ifelse  (member? "apple" [shape] of all-reels) or (member? "cherry" [shape] of all-reels)
        [wait .01 set non-macrostate non-macrostate + 1] [wait .01 set goal-macrostate goal-macrostate + 1] 
  ]
  
    if macrostates = "At least one lemon" [
     ifelse  (member? "lemon" [shape] of all-reels) 
        [wait .01 set goal-macrostate goal-macrostate + 1] [wait .01 set non-macrostate non-macrostate + 1] 
  ]
    
    tick
    
  ] ;end repeat
 
end 























;procedures to paint background animate the pull

to paint-slot-machine
  let n 0
  let background-image [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 0 33 33 33 33 33 33 33 33 33 33 33 33 33 33 0 33 33 0 0 0 0 0 33 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 33 33 0 0 0 0 0 0 0 0 33 33 0 0 0 33 33 0 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 0 0 33 33 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 0 33 33 33 0 0 0 0 33 0 0 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 0 0 0 0 0 33 0 0 0 0 0 33 0 0 0 0 33 33 0 0 33 0 33 33 0 0 0 0 0 33 0 0 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 33 0 33 33 0 0 0 0 0 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 0 33 33 0 0 0 0 0 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 33 33 0 0 0 0 0 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 33 0 0 0 0 0 33 0 33 33 33 33 0 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 33 0 0 33 33 33 0 0 0 0 0 33 0 0 0 0 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 0 33 33 33 0 0 0 0 0 33 0 33 33 0 0 0 0 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 0 33 33 33 33 0 0 0 0 0 33 0 0 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 0 33 0 0 0 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 33 33 0 33 33 0 0 0 0 0 0 0 33 0 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 33 0 33 33 0 0 0 0 0 0 0 33 0 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 0 0 33 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 0 0 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 33 0 0 0 0 0 0 0 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 33 33 0 0 0 0 0 0 0 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
  foreach sort patches [ask ? [set pcolor item n background-image] set n  n + 1]
end

to animate-pull 
   ask patches with [pxcor > 12] [set pcolor black]
   ask patches with [pxcor > 12 and pxcor < 16 and pycor < 4 and pycor > -3] [set pcolor brown - 1] wait .4
   ask patches with [pxcor > 12 and pxcor < 16 and pycor < 7 and pycor > -3] [set pcolor brown - 1] wait .2
   paint-slot-machine
end


to win
  ;cycles through color to indicate win
  repeat 4 [ ask patches [set pcolor pcolor + 35 ] wait .4 ]
end


















; these procedures helped me to create the list of pcolors that I used as a background
to temp
  while [mouse-down?] [ask patch mouse-xcor mouse-ycor [set pcolor brown - 2]]
end 

to save-image 
let saved []
foreach sort patches [ set saved lput [pcolor] of ? saved]
show saved  ;which I then cut and pasted into the setup procedure
end
@#$#@#$#@
GRAPHICS-WINDOW
20
48
471
520
16
16
13.364
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
561
77
701
136
Pull Lever N times
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1133
655
1196
688
NIL
temp
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
25
11
367
37
Microstate Macrostate Slot Machine
18
0.0
1

CHOOSER
493
149
769
194
Macrostates
Macrostates
"Three of the same kind" "Exactly two pears" "At least two of the same kind" "One orange and one cherry" "No apples or cherries" "At least one lemon"
5

PLOT
483
201
891
502
Relative Counts of Macrostates
NIL
Frequency
0.0
10.0
0.0
10.0
true
true
"set-plot-x-range 0 4\nset-plot-y-range  0 205" ""
PENS
"goal-macrostate" 1.0 1 -15390905 true "" "plotxy  1 goal-macrostate"
"non-macrostate" 1.0 1 -6995700 true "" "plotxy  2 non-macrostate"

BUTTON
493
78
556
135
Reset
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
546
485
655
530
Goal Macrostate
goal-macrostate
17
1
11

MONITOR
653
485
775
530
Non-Macrostate
non-macrostate
17
1
11

SLIDER
494
38
667
71
NumberOfPulls
NumberOfPulls
1
1000
1000
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

apple
false
0
Circle -2674135 true false 86 117 128
Rectangle -16777216 true false 120 109 195 124
Polygon -10899396 true false 150 120 180 105 210 120 180 120 150 120 180 105 180 120 180 105
Line -6459832 false 132 109 127 79
Line -6459832 false 135 105 120 75
Line -6459832 false 120 75 135 75
Rectangle -1 true false 172 147 179 153
Polygon -16777216 true false 85 196 117 241 116 245 84 197 114 256 104 238 116 243 119 242
Polygon -16777216 true false 112 237 180 239 177 251 113 255 111 238 124 230

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

cherry
false
0
Circle -2674135 true false 84 159 42
Circle -2674135 true false 129 174 42
Circle -2674135 true false 179 163 42
Polygon -10899396 true false 103 162 134 128 156 110 177 105 198 102 235 98 234 108 193 108 162 112 141 124 130 140 114 156 102 160 109 150
Polygon -13840069 true false 147 172 151 145 163 129 196 111 224 103 231 106 230 109 206 114 178 124 160 137 155 149 152 170 152 175 152 179 145 173 148 167
Polygon -13840069 true false 193 164 201 134 213 117 224 105 212 128 203 141 199 157 200 166 193 167 193 161
Rectangle -1 true false 200 179 203 181
Rectangle -1 true false 149 190 156 197

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

lemon
false
0
Circle -1184463 true false 90 90 120
Polygon -1184463 true false 165 90 210 105 210 150 180 90 165 90 180 135
Polygon -1184463 true false 90 150 90 195 135 210 90 165
Rectangle -1 true false 165 135 180 150

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

orange
false
0
Circle -955883 true false 83 114 134
Rectangle -955883 true false 180 195 210 210
Rectangle -1 true false 168 143 177 151
Rectangle -16777216 true false 150 113 159 117

pear
false
0
Circle -1184463 true false 92 136 114
Circle -1184463 true false 151 107 58
Polygon -1184463 true false 160 115 148 129 131 139 153 147 165 126 155 123
Polygon -1184463 true false 209 142 203 158 206 167 209 183 205 187 198 179 196 159 199 150 202 150 204 156 204 160 204 158 204 162
Rectangle -1 true false 143 156 150 165
Rectangle -955883 true false 142 171 149 180
Rectangle -955883 true false 154 158 161 167
Rectangle -955883 true false 130 173 137 182
Polygon -955883 true false 193 108 216 83 224 86 226 90 218 89 211 96 204 101 198 108

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

spin-1
true
0
Line -7500403 true 75 60 75 195
Rectangle -1184463 true false 75 60 90 105
Rectangle -1184463 true false 120 165 135 210
Rectangle -1184463 true false 180 75 195 120
Rectangle -2674135 true false 150 15 165 60
Rectangle -955883 true false 105 90 120 135
Rectangle -955883 true false 105 90 120 135
Rectangle -2674135 true false 180 135 195 180
Rectangle -2674135 true false 90 150 105 195
Rectangle -955883 true false 120 210 135 255
Rectangle -955883 true false 150 60 165 105
Rectangle -955883 true false 180 165 195 210
Rectangle -955883 true false 75 195 90 240
Rectangle -955883 true false 75 105 90 150
Rectangle -10899396 true false 150 120 165 165
Rectangle -10899396 true false 180 30 195 75
Rectangle -2674135 true false 180 45 195 90

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

strawberry
false
0
Circle -5825686 true false 108 124 92

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

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
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
