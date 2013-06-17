breed [nodes node] ;; just for vocabulary consistency

to setup ;; construct and rewire a ring graph
  clear-all ask patches [set pcolor white]
  create-ordered-nodes node-count [setup-node fd 14]
  let d 1.01 * [distance-to-nearest-neighbor] of one-of nodes
  ask nodes
    [create-links-with other nodes in-radius (d * neighbor-count / 2)]
  rewire
  update-plots set-current-plot "link distance distribution" 
end

to setup-node
  set color 2 set label-color black
  set size 0.3 + (16 / node-count)
  set shape "circle 2" set label ""
end

to-report distance-to-nearest-neighbor ;; spatial, NOT graph distance!
  report distance min-one-of other nodes [distance myself]
end

to rewire ;; the Watts - Strogatz algorithm
  ask nodes
    [foreach sort my-links ;; 'sort' just to get a list
      [if random-float 1 < beta
        [ask ? [die]
         create-link-with one-of other nodes
              with [not link-neighbor? myself]]]]
end

to show-neighborhood
  reset-display
  let target pick-node
  if target != nobody
    [ask target
      [let nbr-nodes (turtle-set self link-neighbors)
       let nbr-links links with
                 [member? end1 nbr-nodes and member? end2 nbr-nodes]
       ask links with [not member? self nbr-links] [set color 8.5]
       ask nodes with [not member? self nbr-nodes] [set color 8.5]]]
end

to show-link-distances show-link-distances-to pick-node end
to show-link-distances-to [a-node]
  ask nodes [set label "" set color 8]
  if a-node = nobody [stop]
  ask nodes [set label "*"]
  ask a-node [set label 0]
  let i 0
  while [any? nodes with [label = "*"]
         and i < count nodes] ;; otherwise the graph is partitioned
      [link-up i set i i + 1]
  
  clear-legend ask nodes [set label-color 0]
  update-plots
end

to link-up [n]
  ask nodes with [label = n]
    [ask link-neighbors with [label = "*"] [set label n + 1]]
end

to-report pick-node 
  while [not mouse-down?] [] ;; wait for a click. Warning: stops the world!
  report min-one-of nodes-on [(patch-set self neighbors)]
                             of patch mouse-xcor mouse-ycor
                    [distancexy mouse-xcor mouse-ycor]
end

to-report local-c ;; undirected graph clustering coefficient, per node
  ;; twice the number of links between the k link-neighbors
  ;; divided by the highest possible number of such links
  let neighborhood link-neighbors
  let nbr-links link-set
     [my-links with [member? other-end neighborhood]] of link-neighbors
  let k count neighborhood
  ifelse k < 2 [report 0] ;; to avoid zero division
               [report (2 * count nbr-links) / (k * (k - 1))]
end

to-report clustering-coefficient
    report precision (mean [local-c] of nodes) 2
end

to show-clustering-coefficients ;; to two decimal places
  ask links [set color 8] clear-output
  ask nodes [set label precision local-c 2 set color 8]
  clear-legend ask nodes [set label-color 0]
  output-type precision (mean sort [label] of nodes) 2
end


to show-grey-legend [white-value black-value legend-label]
  clear-legend
  ask patch 15 -16 [set plabel legend-label set plabel-color black]
  foreach n-values 10 [?] [ask patch (15 - ?) -15 [set pcolor ?]]
  ask patch  6 -15 [set plabel white-value  set plabel-color black]
  ask patch 15 -15 [set plabel black-value  set plabel-color white]
end

to clear-legend
  ask patches [set pcolor white set plabel ""]
end

to reset-display
  ask nodes [setup-node] ask links [set color 5]
  clear-plot clear-legend
end


;; Average distance calculation procedures:

to-report average-distance-to [a-node]
  show-link-distances-to a-node
  report mean filter is-number? [label] of nodes
end

to-report global-average-distance
  let average mean filter [? > 0] map average-distance-to sort nodes
  reset-display report precision average 3
end
@#$#@#$#@
GRAPHICS-WINDOW
185
45
624
505
16
16
13.0
1
11
1
1
1
0
0
0
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
20
225
160
265
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
10
75
175
108
node-count
node-count
10
200
10
10
1
NIL
HORIZONTAL

SLIDER
10
115
175
148
neighbor-count
neighbor-count
2
10
2
2
1
NIL
HORIZONTAL

SLIDER
10
155
175
188
beta
beta
0
1
0
0.01
1
NIL
HORIZONTAL

PLOT
640
85
835
205
degree distribution
# neighbors (degree)
# nodes
0.0
10.0
0.0
10.0
true
false
"" "let link-counts sort [count my-links] of turtles\n  set-plot-pen-mode 1\n  set-plot-x-range (first link-counts - 1) (last link-counts + 2)\n  histogram link-counts"
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
635
260
840
380
link distance distribution
distance to clicked node
# nodes
0.0
10.0
0.0
10.0
true
false
"" "let link-distances filter [is-number? ?] sort [label] of turtles\n  if not empty? link-distances\n    [set-plot-pen-mode 1\n     set-plot-x-range (first link-distances - 1) (last link-distances + 2)\n     histogram link-distances]"
PENS
"default" 1.0 0 -16777216 true "" ""

BUTTON
20
390
160
430
NIL
show-link-distances
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
20
335
160
375
NIL
show-neighborhood
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

TEXTBOX
15
290
170
330
Click a button, and then click one of the nodes:
13
0.0
1

TEXTBOX
10
10
230
35
Small World Network
18
0.0
1

TEXTBOX
210
15
385
40
Watts-Strogatz beta model
12
3.0
1

TEXTBOX
25
52
175
83
Set the parameters:
13
0.0
1

TEXTBOX
640
50
830
81
How many nodes have a given number of neighbors?
11
4.0
1

TEXTBOX
30
200
160
218
Create a new graph:
13
0.0
1

TEXTBOX
25
435
171
500
(Label each node with the number of links in the shortest path between it and the selected node)
10
4.0
1

TEXTBOX
640
225
840
276
How many nodes have a given distance from the one you clicked?
11
4.0
1

TEXTBOX
640
400
845
420
(See the Info tab for an explanation)
11
4.0
1

MONITOR
640
420
795
465
NIL
global-average-distance
2
1
11

MONITOR
640
465
787
510
NIL
clustering-coefficient
2
1
11

@#$#@#$#@
## THE WATTS - STROGATZ SMALL WORLD NETWORK MODEL

In 1998, Duncan Watts and Steven Strogatz published this description of a family of random graphs. The _vertices_ (or **nodes**) of these _small-world networks_, while unlikely to be directly linked, are likely to be connected by a fairly short path through the network. Empirical studies have found that road maps, social networks and gene expression networks (as well as many other naturally occuring graphs) have this small-world property. So do 'classical' Erdos - Renyi _random graphs_, where each pair of vertices has the same uniform probability of being connected. However, ER random graphs don't show much local clustering, while many real networks do. The Watts - Strogatz model retains a specific degree of locality by using a parameter named _beta_ to interpolate between a locally connected regular _ring lattice_ (corresponding to _beta_ = 0) and an ER random graph (at _beta_ = 1).

## HOW IT WORKS AND HOW TO USE IT

Set the **node-count** and **neighbor-count** sliders however you like, set **beta** to 0, and click **setup**. You've just made a circle-shaped ring lattice graph, where each node is connected to the same number of nearest neighbors, as the **degree distribution** histogram shows with a single bar. You can highlight the neighborhood of a node by clicking **show-neighborhood** and then clicking on a node.

Now, if you click **show-link-distances** and then click one of the nodes, you can see all the lengths (in hops) of the shortest paths through the network from each of the other nodes to your selected node, together with another histogram which shows the almost uniform distribution of these path lengths. Notice that the farther away in the circle each node is from the clicked node, the higher its _distance_.   The global average distance (averge over all shortest path-lengths between nodes) is shown on the lower right. 

If you set the **beta** slider above zero and click **setup** again then each node, in random order and with independent probability _beta_, will replace each of its existing links with a new link to another randomly chosen node with which it's not already linked. Now calculate all the shortest paths again. What happens to the path length distribution? What about the degree distribution?

The _neighborhood_ of a node _n_ is the collection of all the _neighbors_ of _n_, that is, all the nodes directly connected to it, _i.e._ at distance 1.

The _clustering coefficient C(n)_ of a node _n_ is a fraction between 0 and 1: the number of links which actually do exist between these neighbors, out of the total number of such links which could potentially exist. The global clustering coefficient (the average _C(i)_ over all nodes _i_) is shown in the lower right.  

## THINGS TO NOTICE AND TRY

As _beta_ increases, the vertex degree distribution begins to approximate a Poisson distribution, which they attain when _beta_ = 1 and the graph is an ER random graph.

Can you find the conditions, for a graph of a given size, which keep path lengths lowest and global clustering coefficients highest? How about if the initial neighbor count is also fixed?

## NETLOGO FEATURES

Notice the reporter **pick-turtle**. This is a workaround to get the identity of an individual turtle from the user via a mouse click. Unfortunately, it disables the rest of the environment while waiting for the click.

The WS small-world network model doesn't allow for self-links, or multiple links between any two nodes. That's just fine, because NetLogo link agents don't permit these conditions either.

## RELATED MODELS

The Barabasi - Albert _preferential attachment_ random network model generates graphs which also have the small-world property, but low amounts of local clustering. Unlike these WS graphs, the graphs produced by the BA model have 'scale-free' degree distributions which follow a power law, as do many empirical networks.

## CREDITS AND REFERENCES

Watts, D.J.; Strogatz, S.H. (1998). "Collective dynamics of 'small-world' networks.". Nature 393 (6684): 409 - 10. doi:10.1038/30918.

NetLogo is copyright Uri Wilensky and the Center for Connected Learning of Northwestern University.
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
Circle -1 true false 30 30 240

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
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
2.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
