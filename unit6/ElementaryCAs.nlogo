breed   [cells cell]
globals [rule          ;;  a list of booleans   
         history  ]    ;;  a list of lists of booleans

to startup setup end
to setup
  resize-world 0 (visible-size - 1) 0 (world-height - 1)
  clear-all set-rule  set-default-shape cells "square"
  set history (list initial-condition)
  ask patches [set plabel-color lime]
  ask patches with [pycor = min-pycor]
    [set pcolor 8 sprout-cells 1 [set color grey]]
  setup-table display-history reset-ticks
end

to set-rule
  set rule-code max list 0 (min list rule-code 255)
  set rule encode 3 rule-code
end

to-report initial-condition report
  ifelse-value random-start?
    [n-values world-width [1 = random 2]]
    [n-values world-width [? = min-pxcor + floor (world-width / 2)]]
end
  
to go
  ifelse edit? [edit]
    [if [pcolor] of patch 0 30 = 7 [hide-table]
     step display-history tick]
end

to step set history lput new-state history end

to go-steps [n] repeat n [step tick] display-history end 

to-report new-state       ;; with appropriate padding at ends
  let these last history  ;; for calculating the new middle
  set these ifelse-value circular?
     [(sentence  (last these) these (first these))]
     [(sentence (first these) these  (last these))]
  let n length these - 2    let i 0   let next []
  while [i < n]
    [set next lput (eval-bfn rule (sublist these i (i + 3))) next
     set i i + 1]
  ifelse circular? [report next]  ;; otherwise make the list bigger
                   [report (sentence (first next) next (last next))]
end

;;;;;;;;;;;  displaying the space-time diagram  ;;;;;;;;;;;;;

to display-history
  let n (length history) - 1 
  ask patches [set pcolor grey + 2]
  foreach n-values min list n world-height [min-pycor + 1 + ?]
    [display-row ? (item (n - ?) history)]
  ask cells with [pycor = min-pycor]
    [let offset floor ((length (last history) - world-width) / 2)
     set color ifelse-value (item (pxcor + offset) (last history))
                            [black] [white]]
  ask patches [set plabel ifelse-value (pcolor != grey + 2 and
                             pxcor = max-pxcor and 0 = (1 + ticks -  pycor) mod 5)
                         [1 + ticks - pycor] [""]]
  display
end

to display-row [row-ycor values]
  let offset floor ((length values - world-width) / 2)
  ask patches with [pycor = row-ycor]
    [set pcolor ifelse-value (item (pxcor + offset) values)
                             [black] [white]]
end

;;;;;;;;;;;  text representation of current state  ;;;;;;;;;;;;;
;;              ... as a list, e.g. [1 0 1 0 0 1]

to-report current-state report to-binary last history end

to set-state [state]
  set state (map [? = 1] state)
  while [length state < visible-size] ;; pad both sides
    [set state fput false lput false state]
  set state sublist state 0 visible-size
  set history lput state history
  display-history
end

;; These two reporters are just conveniences for display alignment.
;; Use them like "set-state on-right [1]", from the command line.

to-report on-left [state]
  while [length state < visible-size]
        [set state lput 0 state] ;; pad right
  report state
end

to-report on-right [state]
  while [length state < visible-size]
        [set state fput 0 state] ;; pad left
  report state
end

;;;;;;;;;;;  editing the cell states  ;;;;;;;;;;;;;

to edit
  if rule-code != decode rule [set-rule update-rule-table display]
  if length history < 31 or [pcolor] of patch 0 30 != 7 [show-table]
  if mouse-down?
    [ifelse round mouse-ycor = 35
       [let m round mouse-xcor
         if 2 < m and m < 34 and odd? m
          [let i (m - 3) / 2
           set rule replace-item i rule (not item i rule)
           set rule-code decode rule]]
       [if round mouse-ycor = 0 
          [ask cells-on patch mouse-xcor mouse-ycor [toggle]]]
     update-rule-table display wait 0.2]
end

to toggle
  let offset floor ((length (last history) - world-width) / 2)
  set color ifelse-value (color = black) [white] [black]
  set history lput (replace-item (offset + pxcor)
                    (last history) (color = black))
              butlast history
end

;;;;;;;;;;;  displaying and editing the rule table  ;;;;;;;;;;;;;

to-report cell-at [d-x d-y] report one-of cells-on patch-at d-x d-y end
to-report nbhd report (list (cell-at 1 0) self (cell-at -1 0)) end

to-report table-patches ;; in order!
  report map [patch (first ?) (last ?)]
    [[ 3 43] [ 5 41] [ 7 39] [ 9 37] [11 43] [13 41] [15 39] [17 37]]
end

to setup-table
  ask patch-set table-patches
    [ask (patch-set patch-at -1 0 self patch-at 1 0)
         [sprout-cells 1 [hide-turtle]]]
  foreach n-values 8 [?]
    [ask patch (3 + 2 * ?) 35 [sprout-cells 1 [hide-turtle]]
     ask cells-on item ? table-patches [make-index-label (15 - ?)]]
end

to make-index-label [index]
  let bits reverse encode 2 index ;; reverse to read left-to-right
  foreach [0 1 2] [ask item ? nbhd
                      [set color ifelse-value (item ? bits) [black] [white]]]
  create-links-to turtles-on patch pxcor 35 [set color yellow hide-link]
end

to show-table
  ask patches with [pycor > 29]
    [set pcolor grey + 2 set plabel ""
     ask cells-here [show-turtle ask my-out-links [show-link]]
     set plabel-color ifelse-value (pycor = 35) [black] [white]]
  update-rule-table  display
end

to hide-table
  ask patches with [pycor > 29]
   [ask cells-here [hide-turtle ask my-out-links [hide-link]]
    set plabel-color lime set plabel ""]
  display-history
end

to update-rule-table
  foreach n-values 8 [?]
   [ask cells-on patch (3 + 2 * ?) 35
     [set color ifelse-value (item ? rule) [black] [white]]
    ask patch (3 + 2 * ?) 33
     [set plabel ifelse-value (item ? rule) [1] [0]]]
  ask patch 17 31
   [set plabel-color black
    set plabel (word "= " rule-code " in base 10")]
end

;;;;;;;;;;;  the rule coding and evaluation machinery  ;;;;;;;;;;;;;

to-report eval-bfn [fn-code args]
  let l length fn-code
  report ifelse-value (l = 1)
     [last fn-code]
     [ifelse-value first args
       [eval-bfn (sublist fn-code 0 (l / 2)) (butfirst args)]
       [eval-bfn (sublist fn-code (l / 2) l) (butfirst args)]]
end

to-report encode [r n] ;; 'r' for arity
  report pad-to-length (2 ^ r) binary-list n
end

to-report binary-list [n] report
;; integer n represented as a list of booleans, where item i is the (2^i)'s bit.
;; to read the list as a 'normal' binary number (with the low bit on the right)
;; replace true by 1, false by 0
  ifelse-value (n < 1)
    [ [] ]  [lput (odd? n) binary-list (floor (n / 2))]
end

to-report pad-to-length [n a-list]
  if length a-list > n [error "list too long!"]
  report ifelse-value (length a-list >= n)
           [a-list]  [pad-to-length n (fput false a-list)]
end

to-report decode [a-bool-list] ;; decimal representation
  report ifelse-value (empty? a-bool-list) [0]
           [2 ^ (length a-bool-list - 1)
              * ifelse-value (first a-bool-list) [1] [0]
            + decode butfirst a-bool-list]
end

to-report to-binary [a-bool-list]  ;; true/false --> 1/0
  report map [ifelse-value ? [1] [0]] a-bool-list end

to-report from-binary [a-number-list] ;; 1/0 --> true/false
  report map [? = 1] a-number-list end

to-report even? [n] report n mod 2 = 0 end
to-report odd?  [n] report n mod 2 = 1 end
@#$#@#$#@
GRAPHICS-WINDOW
171
64
951
590
-1
-1
11.0
1
12
1
1
1
0
1
1
1
0
69
0
44
1
1
1
Current time step
30.0

BUTTON
13
350
162
390
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

SLIDER
13
201
163
234
rule-code
rule-code
0
255
110
1
1
NIL
HORIZONTAL

BUTTON
106
395
162
434
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

BUTTON
14
395
100
434
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

SWITCH
12
103
162
136
circular?
circular?
0
1
-1000

SWITCH
13
273
163
306
random-start?
random-start?
1
1
-1000

SLIDER
12
64
162
97
visible-size
visible-size
0
100
70
1
1
cells
HORIZONTAL

TEXTBOX
15
10
360
41
Elementary Cellular Automata
18
0.0
1

TEXTBOX
28
36
541
56
One dimension, two cell states, three neighbors
13
0.0
1

TEXTBOX
15
138
159
194
If On, the visible cell lattice wraps around left to right. If Off, the lattice extends infinitely off-screen.
11
4.0
1

TEXTBOX
17
311
163
339
Random initial conditions, or a single black cell?
11
4.0
1

TEXTBOX
17
475
164
559
If On, click 'go' to toggle the bits of the rule (above), or the cells' current states (below). If Off, 'go' steps the CA through time.
11
4.0
1

TEXTBOX
8
558
177
586
  Past states, older further up:\nCurrent states of visible cells:
11
0.0
1

SWITCH
14
438
162
471
edit?
edit?
1
1
-1000

TEXTBOX
17
238
142
266
Wolfram code of the CA update function.
11
4.0
1

@#$#@#$#@
## Elementary Cellular Automata
This model presents one-dimensional CAs with two-state cells in three-cell neighborhoods. Following Stephen Wolfram, who invented them in the early 1980s, these are called _elementary_ CAs (ECAs).

This model shows how to assign _Wolfram code_ numbers to all 256 possible cellular automaton rules for discrete one-dimensional spaces (a horizontal row or _lattice_) of two-state (black/white) cells, each with three neighbors: nearest left, self, and nearest right. (Our convention is that each cell is its own 'middle neighbor' -- this may seem awkward at first, but it makes the description of a CA much simpler overall.)   Using this model, you can experiment with these systems by interactively editing the state of each cell, as well as the ECA rule itself.

An ECA _rule_ is a finite function. It can be thought of as a look-up table, consistently assigning a single 'output' -- one of the two possible Boolean values -- to each of the eight possible 'inputs', which are ordered combinations (_permutations_) of three Boolean values. These Boolean values are, depending on context, either called `true` and `false`, black and white, or 1 and 0. For each cell, on each time step, the inputs to the rule are the Boolean-valued _states_ of the cells in that cell's neighborhood. The rule's output becomes the cell's new state on the next step. All cells' states are updated simultaneously. By convention, the older states are displayed above the newer ones, with the current lattice shown at the bottom of the display. This makes a picture called a _space-time diagram_, where time runs down the vertical axis of the display.

## How to use the model
The family of elementary cellular automata is conceptually quite simple. The only parameters are the rule, the initial conditions, and the size of the space. All of these parameters are accessible from the Interface tab.

The **visible-size** slider sets the number of cells shown in the display. The position of the **circular?** switch determines whether or not this visible lattice is wrapped around into a circle, making the rightmost visible cell the left neighbor of the leftmost visible cell. If **circular?** is set **On**, then **visible-size** is the total size of the lattice. On the other hand, if **circular?** is set **Off**, then the lattice extends infinitely to the left and right. In this case, you can't actually see the 'invisible' cells off-screen, but they really are there in NetLogo's memory, and will affect the patterns produced by the CA.

The **rule-code** slider lets you choose an ECA rule by its Wolfram code number, from 0 to 255. Alternatively, you can edit the individual bits of the rule table directly, as described below.

The **random-start?** switch, when set **On**, causes a random initial state to be chosen for all the visible cells, essentially by flipping a coin for each cell, when the system is reset by clicking the **setup** button. If **random-start?** is **Off**, then the initial condition will be a single black cell in the center of an otherwise all-white cell lattice.

The **go** button lets you edit the rule and cell states with the mouse, or simply steps the CA system though time, depending on the position of the **edit?** switch.  When **edit?** is **On** and the **go** button is active, you can click on the current cells at the bottom of the display to toggle their states. You can similarly toggle the output bits of the rule table: the resulting binary number is translated into a decimal Wolfram code, and is also used directly (by the `eval-bfn` procedure) to calculate new cell states. Alternatively, if **edit?** is set **Off**, then **go** just advances the ECA through time, repeatedly calculating new lattice states and displaying them in the space-time diagram. The **go 1** button does the same thing as **go**, but only for a single step -- it is only really useful when the **edit?** switch is **Off**.

The current time step is shown at the top of the display. In the space-time diagram, every fifth row of cells is numbered (in bright green) with its corresponding time step. You can 'run' the CA system for a specific number of steps without the (relatively slow) animation by turning up the speed slider in the toolbar and typing, for example, 

     go-steps 999

into the input line of the Command Center. Other commands are provided too. If you want to see the current lattice state as a list of 0s and 1s, just type 

     show current-state

To set the system state from the Command Center, type (for example)

     set-state [1 0 1 0 1]

If you give a list with fewer bits than the cycle length, both ends will be padded with (`false`, white) zeros to fit the width of the display. To pad only one end, so that the new pattern is aligned to the left or right of the lattice, use a command like

     set-state on-right [1]

## NetLogo tricks
Although patches and turtles are used for display and input, all the CA computation for this model is done indirectly, with list structures containing native Boolean values. Although this approach complicates the code somewhat, it has a few important advantages: it lets us show the rule editor or resize the display without destroying the patterns, it is considerably faster (especially for large systems), and  it lets us work with infinite lattices. If you'd like to see a simpler and more direct implementation, one (titled **CA 1D Elementary**) is available in the Models Library.

If you're wondering how we can represent an infinite lattice in our finite computers, the essential assumption is that, at any particular time step, all cells in the lattice except for a central segment of finite size (the 'interesting' part) are uniformly either black or white, so we need not represent them all explicitly. These infinite lattices have a form like (for example)

    [... 1 1 0 0 1 0 1 0 1 0 ...]

where the "`...`" on the left means an infinite sequence of 1s, and the "`...`" on the right means an infinite sequence of 0s. What actually happens when **circular?** is set **Off** is that the list representing the CA state grows by two elements (one left, one right) on each step. These new elements are taken to be the same Boolean values as the previous ends of the list. Although the list is potentially infinite, we can only run our program a finite number of steps. So, of course, the representation always remains finite. Because information can only propagate in an ECA at a maximum speed of one cell per tick, the 'interesting' central segment of the lattice is always represented. This use of an _infinite data structure_ is very helpful in the study of cellular automata, because it lets us avoid arbitrary size constraints which could affect the behavior of the CA.

## Credits, Copyright, and License 
The elementary cellular automata were first described by Stephen Wolfram:
Wolfram, S. (1983). _Statistical Mechanics of Cellular Automata_. Reviews of Modern Physics 55 (3): 601–644. doi:10.1103/RevModPhys.55.601

This model was developed for the Complexity Explorer project by Max Orhai, 2012.
NetLogo is copyright Uri Wilensky and the Center for Connected Learning at Northwestern University.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

square
false
4
Rectangle -7500403 true false 0 0 300 300
Rectangle -1184463 true true 30 30 270 270
Polygon -16777216 false false 30 30 270 30 270 270 30 270

triangle
true
0
Polygon -7500403 true true 150 0 30 225 270 225
Polygon -16777216 false false 30 225 150 0 270 225 30 225

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
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
Line -7500403 true 150 150 120 195
Line -7500403 true 150 150 180 195

@#$#@#$#@
0
@#$#@#$#@
