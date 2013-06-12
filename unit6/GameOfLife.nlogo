extensions [table]
globals [cells pattern         ;; these are 'xys': lists of pairs
         pattern-state         ;; a [string number bool bool] tuple, as a list
                    ;; = [pattern-name rotate flip-horizontal? flip-vertical?]
         x-offset y-offset  mouse-pxcor mouse-pycor       ;; integers
         counters patterns saved-universes]  ;; key-value hash tables

  ;;;;;;;;;;;;;;   Some helpful command lines:    ;;;;;;;;;;;;;;;
  to save [name]     table:put saved-universes name cells     end
  to restore [name]  set cells table:get saved-universes name
                     update-plots depict cells display        end
  to-report saved    report table:keys saved-universes        end
  
  to pan-to [x y]    set x-offset x set y-offset y
                     update-plots depict cells                end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to startup setup end
to setup
  no-display clear-all  setup-patches  
  set patterns table:from-list pattern-list  set cells []
  set counters table:make  set saved-universes table:make
  set-pattern pattern-name  display  reset-ticks
end

to setup-patches
  recolor-patches  ask patches [sprout 1 [set color 0 hide-turtle]]
end                             ;; turtles' default shape is a circle

to recolor-patches
  ask patches [set pcolor 9.9] ask patch 0 0 [set pcolor 88]
end

to go
  set cells new cells 
  ifelse update-displays? [depict cells] [no-display]  tick
end

to-report new [xys]  ;; calculate new generation using counter table
  table:clear counters  let x 0 let y 0 let c 0 ;; reuse these variables
  foreach xys [table:put counters ? 0] ;; so we can tell new from old
  foreach xys       
    [set x first ? set y last ? ;; cache local values
     foreach [[-1  1] [0  1] [1  1]  ;; count up the eight neighbors
              [-1  0]        [1  0]  ;; of each 'live' cell
              [-1 -1] [0 -1] [1 -1]]
         [set c list (x + first ?) (y + last ?)  ;; c for "cell", here
          ifelse table:has-key? counters c
            [table:put counters c (1 + table:get counters c)]
            [table:put counters c  1.1]]] ;; the extra 0.1 tags new cells
  set xys []  ;; reuse input list for output
  foreach table:to-list counters  ;; filter out 'dead' cells
     [set c last ?  ;; reuse "c" for "count"
      if c = 2 or c = 3 or c = 3.1 [set xys lput (first ?) xys]]
  report xys
end

to depict [xys] ;; assuming the patches have been set up
  no-display ask turtles [hide-turtle]  foreach visible offset xys
    [ask patch (first ?) (last ?) [ask turtles-here [show-turtle]]] display
end

to edit
  no-display ifelse mouse-inside?
    [ifelse insert-pattern? [insert-pattern] [toggle-cell]]
    [recolor-patches display]
end

to toggle-cell
  no-display recolor-patches 
  ask patch mouse-xcor mouse-ycor
     [set pcolor gray + 2 display
      if mouse-down?
        [set cells toggle (list (pxcor + x-offset) (pycor + y-offset)) cells
         ask turtles-here [set hidden? not hidden?]
         display update-plots wait 0.16]]
end

to-report toggle [x xs]  ;; remove an item from or add it to a duplicate-free
  let p position x xs    ;; list, depending on whether or not it's already there
  report ifelse-value is-number? p [remove-item p xs] [fput x xs]
end

to insert-pattern
  if round mouse-xcor != mouse-pxcor or round mouse-ycor != mouse-pycor
    [set mouse-pxcor round mouse-xcor  set mouse-pycor round mouse-ycor
     let ps' (list pattern-name rotate flip-horizontal? flip-vertical?)
     if pattern-state != ps' [set-pattern pattern-name  set pattern-state ps']
     preview at-mouse pattern  display]
  if mouse-down?
    [set cells remove-duplicates sentence
               (translated-by x-offset y-offset at-mouse pattern) cells
     update-plots depict cells  wait 0.16]
end

to-report at-mouse [xys] report translated-by mouse-pxcor mouse-pycor xys end

to preview [xys]  recolor-patches
  foreach visible xys [ask patch (first ?) (last ?) [set pcolor gray + 2]]
end

to pan if mouse-inside? and mouse-down?
  [set x-offset (round mouse-xcor) + x-offset
   set y-offset (round mouse-ycor) + y-offset
   pan-to x-offset y-offset wait 0.16]
end

to zoom-to [height] ;; assuming a square world
  no-display set-patch-size world-height * patch-size / (height + 0.5)
  let r floor (height / 2) resize-world 0 - r r 0 - r r
  setup-patches depict cells
end

to trim set cells visible offset cells
        set x-offset 0 set y-offset 0
        update-plots depict cells
end

to-report offset [xys]  ;; recenter to "apparent" local coordinates
  report translated-by (0 - x-offset) (0 - y-offset) xys
end

to-report visible [xys] report filter
  [min-pxcor <= first ? and first ? <= max-pxcor and
   min-pycor <= last  ? and last  ? <= max-pycor] xys
end


;;;;;;;     Geometric transformations on xys lists:     ;;;;;;;;;

to-report translated-by [d-x d-y xys]
  report map [list (d-x + first ?) (d-y + last ?)] xys
end

to-report centered [xys]  ;; center around 'average' location
  let sums reduce [list (first ?1 + first ?2) (last ?1 + last ?2)] xys
  let d-x round (first sums / length xys)
  let d-y round (last  sums / length xys)
  report translated-by (0 - d-x) (0 - d-y) xys
end

to-report x-flipped [xys] report map [list (0 - first ?) (last ?)] xys end
to-report y-flipped [xys] report map [list (first ?) (0 - last ?)] xys end
to-report transpose [xys] report map reverse xys end

to-report rotated-by [degrees xys]  ;; flips compose to rotations in D8
  if degrees =  90 [report transpose x-flipped xys]
  if degrees = 180 [report x-flipped y-flipped xys]
  if degrees = 270 [report transpose y-flipped xys]
end


;;;;;;;       Add your own named patterns here!       ;;;;;;;;;
;; You can isolate and center new patterns with the 'trim' command.
;; Then type "print cells" at the Command Center to see the 'xys'.

;; I'd like to list pattern names in the interface automatically.
;; But, as of NetLogo 5.0.1, the option list of a "chooser" menu is not
;; programmatically accessible. Use `pattern-names` to see the names,
;; which can then be copied into the pattern-name chooser options.

to-report pattern-names report table:keys patterns end

to set-pattern [name]
  set pattern table:get patterns name 
  if rotate > 0       [set pattern rotated-by rotate pattern]
  if flip-horizontal? [set pattern x-flipped pattern]
  if flip-vertical?   [set pattern y-flipped pattern]
end

;;;;;;;;;;;   xys list pattern data goes here!   ;;;;;;;;;;;;;
to-report pattern-list report [ ;; begin list ...
[ "---"                    [                  ]] ;; (separator)
 ;; the smallest oscillator (period two)
["blinker"                 [[-1 0] [0 0] [1 0]]]

 ;; small stable "still lives" (period one):
["block"                   [[-1 0] [0 0] [-1 -1] [0 -1]]]
["boat"                    [[-1 1] [0 1] [-1 0] [1 0] [0 -1]]]
["beehive"                 [[-1 1] [0 1] [-2 0] [1 0] [-1 -1] [0 -1]]]
["fishhook"                [[-1 1] [0 1] [-1 0] [1 0] [1 -1] [1 -2] [2 -2]]]

 ;; small patterns which move ("particles"):
["glider"                  [[0 -2] [0 -1] [-2 -1] [0 0] [-1 0]]]
["light-weight spaceship"  [[-1 -4] [0 -3] [0 -2] [0 -1] [-3 -1] [0 0] [-1 0] [-2 0]]]
["medium-weight spaceship" [[-4 -3] [-3 -1] [-3 -5] [-2 0] [-1 0] [-1 -5] [0 0] [0 -1] [0 -2] [0 -3] [0 -4]]]
["heavy-weight spaceship"  [[-4 -3] [-4 -4] [-3 -1] [-3 -6] [-2 0] [-1 0] [-1 -6] [0 0] [0 -1] [0 -2] [0 -3] [0 -4] [0 -5]]]

 ;; some basic period-30 glider technology:
["glider gun"              [[-22 -4] [-22 -5] [13 -6] [13 -7] [12 -7] [12 -6] [-17 -3] [-13 -1] [-13 -7] [-13 -2] [-13 -6] [-16 -4] [-12 -1] [-12 -7] [0 -2] [6 7] [8 -5] [8 -7] [0 -1] [7 7] [9 -6] [2 -6] [-21 -5] [-12 -2] [-12 -6] [-1 0] [8 6] [4 -3] [3 -4] [3 -8] [4 -9] [8 -6] [-10 -3] [-8 -4] [-10 -5] [2 -5] [2 -7] [-17 -2] [0 0] [-2 -1] [8 7] [7 5] [-11 -2] [-11 -6] [4 -4] [4 -8] [9 -5] [9 -7] [-8 -3] [-8 -5] [-21 -2] [3 -5] [1 -6] [3 -6] [3 -7] [-19 -1] [-11 -3] [-11 -5] [-11 -4]]]
 ;;            (Bill Gosper)
["buckaroo"                [[0 -2] [-2 -1] [0 -1] [-1 0] [0 0] [9 1] [7 2] [9 2] [6 3] [8 3] [5 4] [8 4] [20 4] [21 4] [6 5] [8 5] [20 5] [21 5] [1 6] [2 6] [7 6] [9 6] [0 7] [2 7] [9 7] [0 8] [-1 9] [0 9]]]
 ;;        (Dave Buckingham)
["glider duplicator"       [[2 -10] [3 -10] [8 -10] [2 -9] [3 -9] [-2 -8] [2 -1] [-10 1] [-8 1] [-22 3] [-21 3] [-22 4] [-21 4] [-10 5] [-8 5] [10 7] [11 7] [10 8] [12 8] [12 9] [12 10] [13 10] [9 -10] [-2 -7] [2 -2] [-9 0] [-9 6] [10 -9] [-3 -6] [1 -3] [-11 2] [-6 2] [3 3] [3 2] [-6 4] [-11 4] [-1 6] [-1 4] [3 8] [3 7] [-11 3] [9 -8] [10 -10] [-2 -6] [-4 -7] [0 -2] [2 -3] [-10 2] [-9 1] [-8 2] [-7 1] [-8 3] [-5 3] [-7 5] [-8 4] [-9 5] [-10 4] [-2 5] [1 2] [-1 3] [-1 7] [1 8] [-12 3] [-10 3] [3 5]]]
 ;;        (Dieter Leithner)
["inline glider inverter"  [[-2 -1] [-1 0] [0 -2] [0 -1] [0 0] [2 6] [2 8] [3 4] [3 8] [4 -4] [4 4] [5 -5] [5 -4] [5 -3] [5 -2] [5 3] [5 8] [5 17] [5 18] [6 -6] [6 -5] [6 -3] [6 -1] [6 4] [6 17] [6 18] [7 -17] [7 -16] [7 -7] [7 -6] [7 -5] [7 -3] [7 0] [7 4] [7 8] [8 -17] [8 -16] [8 -6] [8 -5] [8 -3] [8 -1] [8 6] [8 8] [9 -5] [9 -4] [9 -3] [9 -2] [10 -4]]]
["glider-->LWSS converter" [[-4 -8] [-4 -7] [17 -2] [16 -2] [17 -1] [16 -1] [1 7] [4 10] [-2 10] [4 11] [3 11] [-1 11] [-2 11] [1 14] [2 15] [0 15] [0 16] [2 20] [1 20] [-5 -6] [7 -3] [7 -4] [3 -2] [3 0] [7 2] [7 1] [0 7] [2 7] [0 17] [0 18] [0 19] [-4 -6] [-6 -7] [5 -4] [3 -3] [2 -1] [3 1] [5 2] [0 8] [1 8] [2 8] [1 6] [3 10] [-1 10] [-1 16] [-1 17] [2 19] [7 -1] [-1 18] [1 18]]]
["space rake"              [[-2 8] [-1 8] [5 8] [6 8] [7 8] [8 8] [-4 7] [-3 7] [-1 7] [0 7] [4 7] [8 7] [-4 6] [-3 6] [-2 6] [-1 6] [8 6] [-3 5] [-2 5] [4 5] [7 5] [-5 3] [-6 2] [-5 2] [4 2] [5 2] [-7 1] [3 1] [6 1] [-6 0] [-5 0] [-4 0] [-3 0] [-2 0] [3 0] [6 0] [-5 -1] [-4 -1] [-3 -1] [-2 -1] [2 -1] [3 -1] [5 -1] [6 -1] [-2 -2] [3 -2] [4 -2] [5 -6] [6 -6] [7 -6] [8 -6] [-13 -7] [-10 -7] [4 -7] [8 -7] [-9 -8] [8 -8] [-13 -9] [-9 -9] [4 -9] [7 -9] [-12 -10] [-11 -10] [-10 -10] [-9 -10]]]
 
 ;;  ... and plenty of room for more!
 ;;     (If you add more patterns here, don't forget to also add the pattern
 ;;      names to the 'chooser' pop-up menu, back on the Interface tab.)
    
] end ;; ... end list.

;; The following command reads and converts text files containing patterns in
;; ".cells" format,  which is very common and looks somewhat like this:
;;
;; 4 boats
;;          ...*....
;;          ..*.*...
;;          .*.**...
;;          *.*..**.
;;          .**..*.*
;;          ...**.*.
;;          ...*.*..
;;          ....*...
;;
;; The asterisks can just as well be any character other than "." Tabs and
;; spaces are ignored. The patterns should be immediately preceded by their
;; names on a separate line (and without quotes), with one or more newlines
;; in-between multiple patterns.

to read-new-patterns [filename] ;; or just use "read-new-patterns user-file"
  file-open filename let line "" let xys [] let name "" let x 0 let y 0
  while [not file-at-end?]
    [set line file-read-line
     if not empty? line
       [set name line  set xys []  set y 0
        while [not empty? line]
           [set line remove "\t" remove " " file-read-line  set x 0
            repeat length line
              [if item x line != "." [set xys lput (list x y) xys]
               set x x + 1]
            set y y - 1]
        set xys centered xys
        print list (word "\"" name "\"") xys ]]
  file-close
end

  
@#$#@#$#@
GRAPHICS-WINDOW
359
44
920
626
30
30
9.033
1
10
1
1
1
0
0
0
1
-30
30
-30
30
0
0
1
generations
30.0

BUTTON
224
85
287
119
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
292
44
353
81
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

BUTTON
151
44
219
81
NIL
edit
T
1
T
OBSERVER
NIL
E
NIL
NIL
1

PLOT
151
478
352
626
live cell count
generations
live cells
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot length cells"

MONITOR
151
344
249
401
NIL
x-offset
0
1
14

MONITOR
254
344
352
401
NIL
y-offset
0
1
14

BUTTON
224
44
287
81
NIL
pan
T
1
T
OBSERVER
NIL
P
NIL
NIL
1

PLOT
151
160
353
340
map of the universe
NIL
NIL
-10.0
10.0
-10.0
10.0
false
false
"set-plot-pen-mode 2 ;; to plot points" ""
PENS
"cells" 1.0 2 -16777216 true "" "if update-displays?\n  [let x-min x-offset let x-max x-offset  clear-plot\n   foreach cells\n    [let x (first ?)               let y (last ?)\n     if (x < x-min) [set x-min x]  if (y < x-min) [set x-min y]\n     if (x > x-max) [set x-max x]  if (y > x-max) [set x-max y]\n     plotxy x y ]\n   set x-min x-min - 10\n   set x-max x-max + 10\n   set-plot-x-range x-min x-max\n   set-plot-y-range x-min x-max] ;; keep things square"
"world-bounds" 1.0 0 -4539718 true "" "if update-displays?\n  [plotxy x-offset + min-pxcor  y-offset + max-pycor\n   plotxy x-offset + max-pxcor  y-offset + max-pycor\n   plotxy x-offset + max-pxcor  y-offset + min-pycor\n   plotxy x-offset + min-pxcor  y-offset + min-pycor\n   plotxy x-offset + min-pxcor  y-offset + max-pycor]"

SLIDER
151
404
352
437
display-scale
display-scale
30
300
60
5
1
cells wide
HORIZONTAL

BUTTON
151
440
352
473
NIL
zoom-to display-scale
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
128
145
161
rotate
rotate
0
270
0
90
1
degrees cw
HORIZONTAL

SWITCH
7
164
145
197
flip-horizontal?
flip-horizontal?
1
1
-1000

SWITCH
7
200
145
233
flip-vertical?
flip-vertical?
1
1
-1000

SWITCH
7
44
145
77
insert-pattern?
insert-pattern?
0
1
-1000

CHOOSER
7
80
145
125
pattern-name
pattern-name
"blinker" "block" "boat" "beehive" "fishhook" "---" "glider" "light-weight spaceship" "medium-weight spaceship" "heavy-weight spaceship" "---" "glider gun" "buckaroo" "glider duplicator" "inline glider inverter" "glider-->LWSS converter" "space rake"
6

BUTTON
151
85
219
119
NIL
trim
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
151
124
353
157
update-displays?
update-displays?
0
1
-1000

TEXTBOX
10
14
398
38
Conway's Game of Life cellular automaton
18
0.0
1

TEXTBOX
13
247
145
597
When 'insert-pattern?' is On, the 'edit' button lets you place an entire pattern with one click, instead of toggling individual cells. The above controls select that pattern and its orientation.\n\nThe 'pan' button, when active, lets you click in the display to move around the 'universe'. The light blue square at the center of the display shows the 'offset' distance from the universe origin.\n\nCommands:\n   saved\n   save \"name\" \n   restore \"name\"\n   pan-to X Y
11
5.0
1

BUTTON
292
85
353
119
go 1
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

@#$#@#$#@
## Conway's Game of Life

At the Los Alamos National Laboratory in the late 1940s, the extremely prolific and influential mathematician John von Neumann worked on developing self-reproducing abstract machines or _automata_. Inspired by Alan Turing's _universal computing_ machine and the contemporary work of his colleague Stanislaw Ulam on crystal lattice structures, von Neumann invented a system of 29 symbols, together with rules governing the simultaneous interactions between adjacent symbols in an infinite square grid, which could support a "_universal constructor_". This was a configuration of symbols which worked together under the interaction rules as a machine capable of building any other configuration of symbols, when given a description in the form of a linear string or "tape" of symbolic instructions. Although von Neumann never quite finished his constructor, it is generally regarded as one of the original cellular automata.

A little over twenty years later, and shortly after the posthumous publication in 1966 of most of von Neumann's known work on the subject, John H. Conway developed this "Game of Life" as an extreme simplification of certain aspects of von Neumann's system, using only two symbols (or _states_) per square grid cell, and a simple, symmetrical rule which (unlike von Neumann's) also takes into account the diagonal neighbors of each cell, a neighborhood system usually attributed to Edward F. Moore, who who worked on abstract machine models of biological reproduction in the early 1960s. Rather than carefully arranging patterns of symbols in pursuit of a particular purpose, Conway was interested in how arbitrary configurations could evolve in unpredictable ways. The "Life" rule is designed to fulfill the following three criteria:

> 1. There should be no initial pattern for which there is a simple proof that the population can grow without limit.
> 2. There should be initial patterns that apparently do grow without limit.
> 3. There should be simple initial patterns that grow and change for a considerable period of time before coming to end in three possible ways: fading away completely (from overcrowding or becoming too sparse), settling into a stable configuration that remains unchanged thereafter, or entering an oscillating phase in which they repeat an endless cycle of two or more periods.
> 
> In brief, the rules should be such as to make the behavior of the population unpredictable. --- [Gardner 1970]

The simple CA rule which Conway defined is an _additive_ rule for cells with two states (here, "black" and "white", or "live" and "dead") on an infinite square grid, where a cell's neighborhood includes its four 'diagonal' neighbors:

> Where _n_ is the number of black cells in the cell's outer 8-neighborhood,
> 
>  * A black cell remains black on the next step
>    only if _n_ = 2 or _n_ = 3, otherwise becoming white, and
>     * A white cell becomes black on the next step
>       only if _n_ = 3, otherwise remaining white

Although Conway first developed his "zero-player game" by hand using graph paper or a Go board, it was soon implemented for him on the PDP-7 minicomputer, a relatively affordable machine which was then becoming available at many universities. In October 1970, Scientific American columnist Martin Gardner published a description of Conway's Life in his widely read column _Mathematical Games_, sparking what would become a thriving hobbyist culture of Life pattern engineering and discovery, as well as serious research into the computational capabilities of cellular automata. Conway's Game of Life has since been implemented in many ways, in many different computing environments. Two different NetLogo implementations are available in the Models Library. Their code is simpler, more direct, and much easier to understand than that of this one!

The present model is relatively complicated in part because it supports an "infinite board" --- it doesn't wrap or otherwise arbitrarily bound the cell grid. This is an essential feature of Life as Conway defined it: fixed-size cellular automata have less computational power than unbounded CAs. The other feature that makes this model more complicated is the ability to save pattern templates and compose new patterns from them. This makes experimenting with coordinated structures much easier. This model is intended to be a step toward more "serious" optimized and full-featured Life programs like [Golly](http://golly.sourceforge.net/), while still providing a relatively simple and accessible implementation for those who'd like to read the code.


## How to use this model
Clicking the **setup** button presents you with a blank white 'empty universe'. You can think of this as an infinite square grid of white cells. Because the model doesn't represent 'dead' white cells explicitly, we may just as well think of them as 'holes' or 'empty cells'. The 'universe' is represented in the program as list of `[X Y]` pairs standing for locations of black cells. The name of this (initially empty) list is `cells`.

To add "live" black cells to the world display, click to activate the **edit** button. When **edit** is active, the **insert-pattern?** switch gives you two options: when 'Off' you can click anywhere in the display to toggle an individual cell state between black and white, and when 'On' you can insert (but not remove) an entire pattern, such as a glider. This pattern is specified by the parameters on the left side of the Interface tab: the controls allow you to select a stored pattern from a 'chooser' list, and change its orientation by any combination of reflections or rotations. Place the pattern directly into the display with a click. A few basic stable patterns and mobile 'particles' are provided, as well as some more complex ones which can be used for creating and manipulating streams of gliders.

The **go 1** and **go** buttons, as you may expect, advance the cellular automaton one or more steps through time by calculating and displaying a new "generation" of cell states. A plot labelled **live cell count** charts the "population" of black cells over time. Patterns may grow beyond the bounds of the world display, while remaining in NetLogo's memory. A small additional display (really another plot), titled **map of the universe**, shows the entire 'universe' of live cells, with the borders of the visible 'world' outlined by a light grey frame. As the 'universe' expands, the 'map' shrinks. Both these displays can be temporarily disabled (for extra speed) by switching **update-displays?** 'Off'.

To navigate the main 'world' display around the infinite 'universe', a few additional controls are provided. The 'universe location' of the light blue patch at the very center of the display is given by the **x-offset** and **y-offset** monitors, and is measured relative to the universe 'origin' point (0,0). The **display-scale** slider and **zoom-to display-scale** button change the resolution of the world display without changing the location of its center point. The **pan** button, when active, lets you move that center point by clicking any visible cell in the display. You can also 'pan' to a new location in a single step by typing (for example) "`pan-to 123 -456`" in the Command Center.

In experimenting with Life, you'll often want to try different things but be able to return to a saved state. You can always use NetLogo's built-in "Export World" and "Import World" commands, which write and read external files. Or, you could just print out the universe cell list by typing `print cells`, and copy and paste the output into a text file. But, much faster and easier temporary storage is provided in the form of three commands:

    save "pattern name"          restore "pattern name"             saved

... where `saved` returns a list of saved pattern names, in case you forget them. You can also just use numbers, if you don't want to bother typing a full name in quotes.

Finally, the **trim** button discards all cells which aren't visible in the main display, and re-centers the remaining ones so that the central light blue patch is now located at (0,0). This is most useful for isolating new sub-patterns which you'd like to save for later re-insertion: just trim away any excess cells and type `print centered cells` to get a cell list which you can then paste into the pattern list at the end of the code.

You won't have any trouble finding interesting Life patterns on the web. As of this writing, two of the largest repositories are Stephen Silver's [Life Lexicon](http://www.argentum.freeserve.co.uk/lex.htm) and Nathaniel Johnston's [LifeWiki](http://conwaylife.com/wiki/Main_Page). You can import any patterns in the standard text-based format for small Life pattern exchange (a sort of picture made with "`.`" and "`*`" or "`o`" characters) using the command `read-new-patterns` ; see the end of the Code tab for detailed instructions.


## How it works
The basic idea of this model's approach is simply to _not represent_ white cells, but rather keep track of all the 'live' black cells by their locations. Under the assumption that all but finitely many cells are white, this works pretty well for Life: the amount of computation we do in calculating a new step depends only on the _number_ of live cells, rather than the square _area_ we see them span. We calculate CA steps (or 'generations') by using a look-up table, indexed by cell location, with a counter (plus a 'newness' tag) for each cell location with a live neighbor. We run down the list of current live cells, for each one incrementing all neighboring cells' counters. Then we just go through all the locations in the table and discard those with too few or too many live neighbors. Using a hash table data structure, provided by NetLogo's `table` extension, gives us fast _O_(log _n_) out-of-order access to the counters, which is important because we must process the cells in some linear order. The table extension also makes it easy to add pattern storage facilities.


## Credit and references:
Von Neumann, J. _Theory of Self-Reproducing Automata_: edited and completed by Arthur W. Barks. University of Illinois Press, 1966

Moore, Edward F. "Machine models of self-reproduction," _Proceedings of Symposia in Applied Mathematics_, volume 14, pages 17–33. The American Mathematical Society, 1962.

Gardner, M. "The fantastic combinations of John Conway's new solitaire game 'life'". _Scientific American_, October 1970.

This model was developed for the **Complexity Explorer** website by Max Orhai at Portland State University in 2012 and 2013, under the direction of Melanie Mitchell. NetLogo is copyright Uri Wilensky and the Center for Connected Learning at Northwestern University.
@#$#@#$#@
default
true
0
Circle -7500403 true true 30 30 240

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
