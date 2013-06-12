globals 
 [divisions fractal-dim initial-length
  len walk-count old-box-count 
  new-box-count x-axis-list y-axis-list
  box-size explore? iteration
  iterations-to-go slope lin-reg-eq
  any-new-boxes? x-cor y-cor
  ]
 
turtles-own   ;used only for making fractal examples and custom frctals if you choose.
  [new?]
  
breed         ;used only for taking box counting dimension of fractal examples.
 [boxes box]
 
boxes-own 
  [past? present? future?]
  
patches-own [fractal?]

to startup
   setup
end

to setup
 clear-all
 
 ask patches [set pcolor black]
 set explore? false
 set x-axis-list [ ]
 set y-axis-list [ ]
 ask turtles [die]
 ask boxes [die] 
 set box-size 10
 set iteration 0
 output-print (word   "log 1/r  " "log Nboxes"  )  ; 1/r is the box size for any particular iteration, e.g. scale.

if fractal-example = "cantor-dust"
[
  set x-cor -140
  set y-cor 0
  make-turtle]

 if fractal-example = "koch-curve"
  [
  set x-cor -160
  set y-cor 0
  make-turtle]

if fractal-example = "dragon-curve"
  [set x-cor -80
  set y-cor 0
  make-turtle]
  
  if fractal-example = "sierpinski-triangle"
  [
  set x-cor 0
  set y-cor 100
  make-turtle]
  
 reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Box-Counting-Dim;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to bcd-go
   set initial-length 100
   set len initial-length   
  bcd-begin
end

to bcd-begin
   ask boxes ; clears screen in case there are any old boxes
   [die]
   
   if automatic-bcd?
    [
    if box-size >= initial-length 
     [ set automatic-bcd? false]
    ]
    
ifelse ticks = 0 
       [set box-size box-size
       set iteration iteration]
       [set box-size box-size + 1 
       set iteration iteration + 1
       set iterations-to-go 91 - iteration
       ]
    set old-box-count 0
    set new-box-count 1    ;eliminates an error for first round
    make-initial-box
    make-neighbors-count-patches
    
end

 ;makes a starter box at the beginning of each run with present? = true. 
 ;This box will then be used to make boxes with future? = true 
 ;which will be used for the next run.
to make-initial-box 
    create-boxes 1
  ask boxes [
    set shape "square"
    set size box-size
    setxy  x-cor y-cor
    set heading 90
    set color red
    set past? false
    set present? true
    set future? false
    ]
end

 ;makes a Moore neighborhood around the starter box and counts patches below each new box (exploit).
 ;If there are no new boxes with patches under them for a given run a box is sent outside the neighborhhod
 ;to cover non-contiguous patches (explore). If this box finds no new patches the run is complete.
 
to make-neighbors-count-patches
    ask boxes with [present? = true ] 
    [make-neighbors]
     
    ask boxes with [future?  = true]
       [exploit]
       count-new-boxes
      if any-new-boxes?     = false
       [explore]
       
      if any-new-boxes? = false
       [calculate-box-counting-dimension]
      if any-new-boxes? = false and automatic-bcd? [
       bcd-begin
       stop ]
      update-past-present-future-states
      tick
      if any-new-boxes? = true
      [make-neighbors-count-patches]
end

to make-neighbors
     hatch 1 [fd box-size rt 90 
      set present? false set future? true
      hatch 1 [fd box-size rt 90 
      set present? false set future? true
      hatch 1 [fd box-size
      set present? false set future? true
      hatch 1 [fd box-size rt 90
      set present? false set future? true
      hatch 1 [fd box-size 
      set present? false set future? true 
      hatch 1 [fd box-size rt 90
      set present? false set future? true
      hatch 1 [fd box-size
      set present? false set future? true 
      hatch 1 [fd box-size 
      set present? false set future? true
       ]]]]]]]]
end
      
to exploit
   if count boxes-here  > 1  ; eliminates duplicates
   [die]
   
   if count patches-under-me = 0
   [ die ]
end
   
to-report patches-under-me 
     report  patches in-radius  ( (1.4 * size ) / 2 )  with [pcolor = white]
;   [let my-n-edge ycor + (0.5 * size)  ;; if my shape is a square
;   let my-s-edge ycor - (0.5 * size)
;   let my-w-edge xcor - (0.5 * size)
;   let my-e-edge xcor + (0.5 * size)
;   report patches with [pcolor = white and 
;   (pycor - 0.5 < my-n-edge) and (pycor + 0.5 > my-s-edge) and
;   (pxcor + 0.5 > my-w-edge) and (pxcor - 0.5 < my-e-edge) 
;   ]
;  ]
end
     
to explore
 if count boxes with [present? = true] > 0 [
   ask patches with [pcolor = white] [
 ifelse count boxes in-radius  (  box-size ) = 0 
  [set explore? true]    
  [stop]
  ]
 ]
  
 if explore? [
 ask one-of boxes with [present? = true] [
  hatch 1 [
  set present? false set future? true
  move-to min-one-of patches with [pcolor = white and count boxes in-radius  ( box-size ) = 0 ]  
  [distance myself]]
  ]
 ]
 count-new-boxes
 set explore? false
end

to count-new-boxes
 set old-box-count new-box-count
 set new-box-count count boxes 
 ifelse old-box-count = new-box-count 
 [set any-new-boxes? false]
 [set any-new-boxes?  true]
end 
  
to update-past-present-future-states
 ask boxes [
  if present? = true
  [set past? true set present? false]
  if future?   = true
  [set future? false set present? true]
  ]
end
   
to calculate-box-counting-dimension
 
  if count boxes >= 1 [     ; eliminates potential error message if setup is pressed during a box-counting procedure
   set-current-plot "scatter-plot"
   set-current-plot-pen "default"
   let no-boxes log (count boxes ) 10
   let scale (log ( 1 / box-size ) 10 )
   plotxy scale no-boxes
   output-print (word  precision(scale)2 "     " precision (no-boxes)2)
   set x-axis-list lput scale x-axis-list
   set y-axis-list lput no-boxes y-axis-list
   ]
 
 stop
end

to fractal-dimension
 if ticks = 0 [
  if divisions > 0 [ ; eliminates potential error message 
  let line-segments count turtles  
  set fractal-dim precision(( log  line-segments  10 / log  divisions 10 ))3
  show line-segments
  show divisions
  show fractal-dim
  ]
 ]
 stop
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;fractals;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;These next procedures make various fractals which can be measured with 
 ;fractal dimension (Hausdorff) and box counting dimension.
 ;These two measures would ideally be the same.
to iterate-example  

if fractal-example = "cantor-dust"
[
  ask patches [set pcolor black] ; clears screen
  ask turtles [set new? false]
   t walk
   skip len
   t walk
   d
  set divisions 3
  set len (len / divisions)
  fractal-dimension
  tick
]


if fractal-example = "koch-curve"
  [
  ask patches [set pcolor black] ; clears screen
  ask turtles [
  set new? false ]
  t  walk l 60 t  walk r 120 t  walk l 60 t walk d 
  set divisions 3
  set len (len / divisions)
  fractal-dimension  
  tick
]

if fractal-example = "sierpinski-triangle"
[
  ask patches [set pcolor black] ; clears screen
  ask turtles [set new? false ]
   t r 60
    walk  l 60 t r 60 walk 
    r 120
    walk walk
    r 120
    walk  r 60 t l 60 walk 
  d
  set divisions 2
  set len (len / divisions)
  fractal-dimension
  tick
]

  if fractal-example = "dragon-curve"
  [
  ask patches [set pcolor black] ; clears screen
  ask turtles [
    set new? false]
    r 45 t walk l 90  walk l 180 t d
    set divisions  sqrt 2
    set len (len / divisions)
    fractal-dimension 
  tick
  ]

;if fractal-example = "random-koch-curve"
;[
;  set x-cor -140
;  set y-cor 0
;  make-turtle
;  ask boxes [
;  set new? false setxy x-cor y-cor] ; eliminates potential error message if a fractal button is pressed during a box-counting procedure 
;  ask patches [set pcolor black] ; clears screen
;  ask turtles [
;  set new? false 
;  let q random 2
;  ifelse q = 0 [
;    t  walk l 60  t  walk r 120 t  walk l 60 t walk d  ]
;  [ t  walk r 60  t  walk l 120 t  walk r 60 t walk d  ]] 
;  set divisions 3
;  set len (len / divisions)
;  fractal-dimension
; tick
;]
;

;if fractal-example = "twin-dragon-curve"
;  [
;  set x-cor -140
;  set y-cor 0
;  ask patches [set pcolor black] ; clears screen
;  if ticks = 0 [
;  ask turtles [hatch 1 lt 180 ]]
;  ask turtles [
;   set new? false setxy x-cor y-cor]
;   r 45 t walk l 90  walk l 180 t d
;   set divisions  sqrt 2
;   set len (len / divisions)
; tick
;]
;
;end


;if fractal-example = "koch-island"
;  [
;  ask patches [set pcolor black] ; clears screen
;  ask turtles [
;  set new? false 
;  ]
;  ifelse ticks = 0
;    [repeat 3 [ t  walk l 60 t  walk r 120 t  walk l 60 t walk  
;    r 120] d]
;    [t  walk l 60 t  walk r 120 t  walk l 60 t walk d 
;    ]
;  set divisions 3
;  set len (len / divisions)
;  fractal-dimension  
;  tick
;  ]
end

to make-turtle
   crt 1
 ask turtles [
   setxy x-cor y-cor
    set new? false
    set shape "circle"
    set size 1
    set color white 
    set heading 90
    set initial-length 100
    set len initial-length
     ] 
end


to c   ;color-patches
  let my-n-edge ycor + (0.5 * size)  ;; if my shape is a square
  let my-s-edge ycor - (0.5 * size)
  let my-w-edge xcor - (0.5 * size)
  let my-e-edge xcor + (0.5 * size)
  ask patches with [ 
      (pycor - 0.5 < my-n-edge) and (pycor + 0.5 > my-s-edge) and
       (pxcor + 0.5 > my-w-edge) and (pxcor - 0.5 < my-e-edge) ]
  [set pcolor  white]
     
end

; walk moves a turtle forward by a length (len) and leaves a trail of white patches.

to walk
    ask turtles with [not new?]
    [
    set pcolor white
    set walk-count .1
    while [walk-count <= len]
    [ 
    fd .1
    set pcolor white
    set fractal? true
    set walk-count ( walk-count + .1)  ]
    ]
    stop
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;fractal controls;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;hatch a new turtle for all the turtles that are not new to the current iteration and set new? to be true

to t
  ask turtles with [not new?] [hatch 1 [set new? true]]
end

;turn each turtle that wasn't created during the current iteration to the right by degree degrees
to r [degree]
  ask turtles with [not new?] [rt degree]
end

;turn each turtle that wasn't created during the current iteration to the left by degree degrees
to l [degree]
  ask turtles with [not new?] [lt degree]
end

;move each turtle that wasn't created during the current iteration forward by steps but do not leave trail of white patches.
to skip [steps]
  ask turtles with [not new?] [ fd steps ]
end

;all non-new turtles die
to d
  ask turtles with [not new?] [die]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;Linear Reg;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;Linear regression is used to find the 'best-fit' line
 ;through all the tuples (box-size,number of boxes) plotted in the scatter plot.
 ;The slope of the line is the box counting dimension. 

to linear-regression

  if count boxes >= 1 [  ; eliminates potential error message if setup is pressed during a box-counting procedure [
  let sum-x sum x-axis-list
  let sum-y sum y-axis-list
  let # length x-axis-list
  
  let ave-x sum-x / #
  let ave-y sum-y / #
  let sum-xy sum ( map  [ ?1 * ?2 ] x-axis-list y-axis-list ) 

  let sum-x-square sum  ( map  [ ? * ? ] x-axis-list ) 

  let sum-y-square sum  ( map [ ? * ? ] y-axis-list )

  ; compute and store the denominator for the slope and y-intercept 
  let denominator ( sum-x-square - # * ( ave-x ^ 2 ) )

  ; if the denominator = 0 or the min of xcors = the max of xcors, the turtles are in a vertical line
  ; thus, the line of regression will be undefined and have a r^2 value of 1.0
  ifelse ( denominator = 0 ) 
  [
    set slope "Undefined"
    let y-intercept "Undefined"
    
  ]
  [
   ; otherwise, there is some other type of line.  Find the y-intercept and slope of the line

    let y-intercept ( ( ave-y * sum-x-square ) - ( ave-x * sum-xy ) ) / denominator
    set slope precision (( sum-xy - # * ave-x * ave-y ) / denominator)3

    ;; compute the value of r^2
    ifelse ( ( sum-y-square - # * ( ave-y ^ 2 ) ) = 0 ) 
    [ let r-square 1 ]
    [
      let r-square precision (( ( sum-xy - # * ave-x * ave-y ) ^ 2 ) /
        ( ( sum-x-square - # * ( ave-x ^ 2 ) ) * ( sum-y-square - # * ( ave-y ^ 2 ) ) )) 3
   ]

 ; set the equation to the appropriate string
 set lin-reg-eq (word (precision slope 3) " * x + " (precision y-intercept 3))

 set-current-plot "scatter-plot"
 set-current-plot-pen "pen-4"
 plotxy .1 .1 * slope + y-intercept
 plotxy -2 -2 * slope + y-intercept
    ]
   ]
end
@#$#@#$#@
GRAPHICS-WINDOW
165
48
696
600
260
260
1.0
1
10
1
1
1
0
1
1
1
-260
260
-260
260
1
1
1
ticks
30.0

BUTTON
4
85
153
138
NIL
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

PLOT
709
48
976
303
scatter-plot
log [1 / r]
log Nboxes 
-2.0
-1.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"pen-4" 1.0 0 -2674135 true "" ""

MONITOR
711
443
776
488
Nboxes
count boxes with [color = red]
17
1
11

MONITOR
709
347
976
392
Fractal Dimension (Hausdorff)
fractal-dim
17
1
11

BUTTON
3
312
152
369
bcd-go
bcd-go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
3
281
152
314
automatic-bcd?
automatic-bcd?
1
1
-1000

BUTTON
3
368
152
401
NIL
linear-regression
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
709
303
823
348
box-counting-dim
slope
17
1
11

MONITOR
775
443
832
488
r
precision(box-size)2
17
1
11

TEXTBOX
8
247
144
269
BCD Controls
18
0.0
1

MONITOR
823
303
976
348
NIL
lin-reg-eq
17
1
11

TEXTBOX
10
49
160
71
Fractal Examples
18
0.0
1

TEXTBOX
7
10
347
38
Box-Counting Dimension
24
0.0
1

CHOOSER
4
137
153
182
fractal-example
fractal-example
"cantor-dust" "koch-curve" "sierpinski-triangle" "dragon-curve"
1

BUTTON
4
181
153
235
NIL
iterate-example
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
988
49
1138
488
10

TEXTBOX
945
499
1347
567
r = length of side of box\nNboxes = number of boxes
14
0.0
1

@#$#@#$#@
## WHAT IS IT?
Fractal and fractal box-counting dimension (intermediate-bcd.nlogo) is a model that illustrates how the dimensionality of various fractal shapes can be understood and measured. Fractal dimension is a general tool for understanding and measuring complex forms.  This model investigates the fractal dimension and fractal box-counting dimension for a variety of fractals and custom L-system fractals.

## HOW IT WORKS

Fractal dimension is based on Hausdorff dimension developed by the German mathematician Felix Hausdorff. A line segment or initiator with divisions r in one dimension, D = 1, has a partitioning of N where N = r.  In two dimensions the number of partitions increases to N 2 or 4, this second order operation is termed the generator.  Likewise in three dimensions, D = 3, the number of partitions increases to N 3 or 8.  This relationship is generalized to any geometric condition where N = r D.   

## HOW TO USE IT

This model investigates the fractal dimension and fractal box-counting dimension of some common fractals. The interface provides the basic procedures in three blocks: Fractal Examples, Box-Counting Controls and Plot Controls. Clear all and begin a new count by pressing setup in the upper left hand corner. Do not press setup again unless you want to begin a new count. Try pressing the koch-curve button 3 or 4 times. A Koch curve fractal should appear in the view. Notice at the first iteration the fractal dimension of 1.262 appears in the Command Center as well as in the fractal-dimension monitor. Under Plot Controls set automatic-box-count? to On and plot-box-count? to On. Next, under Box-Counting Controls, set the scaling-factor to 0.20 and the  increment  to 0.50. You are now ready to do a run. Begin a run by pressing box-counting-dimension-setup, this can be used at anytime to adjust a count without clearing the scatter plot. Now press box-counting-dimension-go and you should see small red boxes covering the Koch curve. Individual runs are plotted as points in the scatter-plot. Automatic-box-count continues to increase the size of the boxes by increment after each run until it reaches the maximum box size. You probably don’t want to wait that long so just press box-counting-dimension-go again at any time to stop the runs and then press the linear-regression button under Plot Controls to find the ‘best-fit’ line in the Scatter-Plot. The slope of this line is the fractal dimension of your runs and appears in the monitor box-counting-dim —1.268 for the runs below. Try experimenting with different examples. 

## THINGS TO NOTICE
The box-counting dimension is more accurate (equivalent to the fractal dimension) if the initial fractal is iterated more. However, you have probably noticed the fractal taking longer and longer to generate at each successive iteration?  This is because the number of line segments is increasing exponentially.  The Koch curve, for instance, begins with 4 line segments but has over a million line segments after ten iterations.

## HOW TO MAKE A CUSTOM FRACTAL

To make a fractal of your own design, go to the code window and scroll down to: to design-your-own-fractal. Design a fractal here using the fractal commands: t for hatch turtle, r for turn right by degree amount, l to turn left by degree amount, walk to move forward by a length (len), s to skip forward by a length  and d to die. Length is set to 100 by default.
To set the amount subsequent iterations will scale, set divisions to the desired magnitude, i.e. 2 or 3 or whatever.
Here is the procedure to make the Koch curve:

to koch-curve
  ask patches [set pcolor black] ; clears screen
  ask turtles [
  set new? false ]
  t  walk l 60 t  walk r 120 t  walk l 60 t walk d 
  set divisions 3
  set len (len / divisions)
  fractal-dimension  
  tick
end
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

square
false
0
Rectangle -7500403 true true -16 -9 310 311
Rectangle -7500403 true true 15 45 15 60
Rectangle -7500403 true true 46 0 300 242

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
NetLogo 5.0.3
@#$#@#$#@
ballSetup
repeat 14 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
