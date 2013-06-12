breed [cells cell]

to setup
  no-display clear-all 
  set-default-shape cells "circle" 
  ask patches
    [set pcolor 6.7
     sprout-cells 1 [set size 0.8 set color white set label-color green]]
  reset-ticks display
end

to randomize
  no-display reset-ticks
  ask cells [set color white set label ""]
  ask n-of round (count cells * percent-black / 100)
      cells [set color black]
  display
end

to edit 
  if ticks != int ticks [go]  ;; start on a whole step
  if mouse-inside? and mouse-down?              ;; when clicked,
    [ask cells-on patch mouse-xcor mouse-ycor   ;; toggle color
        [set color ifelse-value (color = black) [white] [black]]
     wait 0.16 display]
end

to go
  no-display
  ifelse ticks = int ticks          ;; go in half-steps:
    [ask cells [count-black-nbrs]]  ;; first all cells count neighbors,
    [ask cells [change-color]]      ;; and only then do they change color.
  tick-advance 0.5 display     ;; tick counter on display only shows integers
end

to count-black-nbrs             ;; mark only the cells with 'just enough' neighbors
  let n count (cells-on neighbors) with [color = black]
  if (n = 3 or (color = black and n = 2)) [set label "•"] ;; 'live' next generation
end

to change-color
  set color ifelse-value (label = "•") [black] [white]
  set label ""
end
     
@#$#@#$#@
GRAPHICS-WINDOW
162
10
568
437
16
16
12.0
1
16
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
generations
30.0

BUTTON
13
116
145
149
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

BUTTON
14
303
146
336
NIL
edit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
403
80
436
NIL
go
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

BUTTON
86
403
149
436
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

TEXTBOX
15
17
106
43
Mini-Life
18
0.0
1

SLIDER
13
183
145
216
percent-black
percent-black
0
100
12
1
1
%
HORIZONTAL

BUTTON
14
222
146
255
NIL
randomize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
14
45
145
73
Conway's Game of Life on a finite grid.
11
5.0
1

TEXTBOX
21
96
140
114
Turn all cells white:
11
5.0
1

TEXTBOX
20
161
148
179
Turn some cells black:
11
5.0
1

TEXTBOX
21
272
150
300
Click cells to toggle\nbetween white & black:
11
5.0
1

TEXTBOX
22
354
153
396
Compute new 'generations' of cell color patterns:
11
5.0
1

@#$#@#$#@
## Conway's Game of Life, only smaller
This is a simplified version of what is probably the most famous cellular automaton, invented by Cambridge mathematician John H. Conway around 1970. Unlike the _real_ Game of Life, which takes place on an infinite plane, this version only supports a fixed number of cells. By default, the 'world' grid is wrapped into a torus shape.

## How it works
An _additive_ cellular automaton rule counts the number of neighborhood cells in a particular state. The rule which Conway defined is an additive rule for cells with two states (here, "black" and "white", or "live" and "dead"). These cells inhabit a square grid, where a cell's neighborhood includes its eight horizontal, vertical, and diagonal neighbors.

> Where _n_ is the **number of black cells** in the cell's outer 8-neighborhood,
> 
>  * A black cell remains black on the next step
>    only if _n_ = 2 or _n_ = 3, otherwise becoming white, and
>     * A white cell becomes black on the next step
>       only if _n_ = 3, otherwise remaining white

This model is a fairly simple and direct implementation in NetLogo, using round turtles for cells. It includes rudimentary pattern editing and randomization features, but it is mostly intended to be easy to use and easy to understand, rather than fast or featureful.

We compute a new generation of cells in two "half-steps". First, for each cell (black or white), we count _n_: how many of the neighboring cells are colored black. If _n_ is just the right amount, the cell is tagged with a green dot ("•"). Then, only after all cells have been counted and tagged in this way, all tagged cells turn black and others turn white.

## Some basic questions to get started:
Try a few simple initial patterns of cells. How many generations does it take before they stabilize into a 'still life'? Are there any initial patterns which never become stable or settle into an oscillating _cycle_? Can you find a cyclic pattern which moves across the grid? Can you find a small initial pattern which grows to fill the entire space? Why do we need two half-steps to compute one generation --- what would happen if cells changed their colors immediately upon counting their neighbors?

## Need more room?
You can increase the NetLogo 'world size', and the model will still work without being wrapped around at the edges. But Complexity Explorer also provides a full-sized Game of Life implementation, with more features and more background information. You'll probably want to move up to that model when you feel like you understand this one.

## Due credit:
Developed by Max Orhai for the Santa Fe Institute's massive open on-line course **Exploring Complexity**, under the direction of Melanie Mitchell, 2013.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

outlined circle
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 false false 0 0 300

@#$#@#$#@
NetLogo 5.0.1
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
