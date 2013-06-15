globals [
  patch-data
  string 
  next-space
  current-word
  rank
  x
  #-of-words
  y-coordinate
  x-coordinate
  ]
breed [line-points power-point]
breed [power-points power-point]
breed [normal-points normal-point]
breed [utterances utterance]   ; main turtles used in program
utterances-own [
  name
  word-length
  number
  number-like-lengths
  delete?
]

breed [x-axis-labels x-axis-label] ; only used for drawing plot
breed [y-axis-labels y-axis-label]
breed [x-axis]
breed [y-axis]
to startup
  setup
end
  
to setup 
  ca
  reset-ticks
  ask patches [set pcolor white]
  set rank [ ]
  draw-plot
  load-sample    ; if a user file is not loaded a default file will be used instead
  define-utterances
  tick
end
  
  
  
  to define-utterances
  while [length string > 0] [
    set next-space position " " string
    set current-word substring string 0 ( next-space )
    
      let i length current-word + 1
      while [ i > 0 ] [
      set string but-first string
      set i i - 1
    ]
    create-utterances  1 [ 
      set name current-word
      set label current-word
      set delete? false
      set label-color black
      set size .1
      
      set word-length length name
      ]
        ]
    set #-of-words count utterances
  end
  

 to plot-by-frequency
   
    count-like-words
    elim-redundant
   let s 1
   let u count utterances
   ask utterances [set delete? false]
   while [s <= u]
   [ifelse count utterances with [delete? = false] > 0 [
   ask one-of utterances with [delete? = false] [if count utterances with [delete? = false and [number] of myself < [number] of self] = 0
   [ifelse  s  * x-stretch + 2 > max-pxcor  [die set s s + 1]
   [setxy (s * x-stretch + 2) (number * y-stretch + 2) set delete? true 
    set s s + 1]]]]
   [stop]
 ]
  
 end
 
   to count-like-words
   ask utterances
  [ set number count other utterances with [[name] of myself = [name] of self] + 1]
end
  
  to elim-redundant
    ask utterances [if count other utterances with [[name] of myself = [name] of self] > 0 [die]]
end
 
  to plot-by-length
  ask x-axis-labels  [ set label "W o r d  L e n g t h " set size .4 ]
   count-like-lengths
   elim-redundant-lengths
  ask utterances
  [setxy (word-length  * x-stretch + 2) ((number-like-lengths / 2) * y-stretch + 4)]
  display
 end

to count-like-lengths
     ask utterances
  [ set number-like-lengths count other utterances with [[word-length] of myself = [word-length] of self] + 1]
end

to elim-redundant-lengths
    ask utterances [if count other utterances with [[number-like-lengths] of myself = [number-like-lengths] of self] > 0 [die]]
end




to log-log
     ask utterances
  [let  a log(xcor )10 * 10 let c log(ycor)10 * 10  ;both coordinates are multiplied by ten to re-scale the data and make it visible in the plot.
    setxy a c
        ]
end



to hide-words
  ask utterances [set label " "  set shape "circle" set size 1 set color grey] 
  end

to show-words
  ask utterances [set label name   set shape "circle" set size .1] 
  end




;;;;;;;;;;;;;;;;;;;;;;;;
;;;;fit with curve;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to fit-line
  ask line-points [die]
  ask patches with [ (pycor = 2) and (pxcor < max-pxcor) and (pxcor > 0)]
  [sprout-line-points 1]
  ask line-points [set y-coordinate ((m * xcor) + b) 
    determine-coordinates
    set size 1 set shape "circle"  set color orange ]
  display
  end

to fit-curve
  ask power-points [die]
  ask patches with [ (pycor = 2) and (pxcor < (world-width - 2)) and (pxcor > 0)]
  [sprout-power-points 1]
  ask power-points [set y-coordinate (n / ((xcor ) )) + 2 
    determine-coordinates
    set size 1 set shape "circle"  set color blue ]
  display
  end

to fit-normal
  ask normal-points [die]
  ask patches with [ (pycor = 2) and (pxcor < (world-width - 2)) and (pxcor > 2)]
    [sprout-normal-points 1]
  ask normal-points [set x xcor / x-scaling
    set y-coordinate (( 1 / sigma ^ y-scaling) * ( 1 / sqrt (2 * pi)) * ( e ^  (((-1 * ((x - mu) ^ 2))  * ((1 / 2) * (( 1 / sigma ^ 2 ))))  )) + 2 )                          
    determine-coordinates
    set size 1 set shape "circle"  set color red ]
    display
  end

to hide-curves
  ask power-points [set size .1]
  ask normal-points [set size .1]
end

to show-curves
  ask power-points [set size 1]
  ask normal-points [set size 1]
end

to determine-coordinates
  set y-coordinate (y-coordinate * y-stretch) 
  if y-coordinate <  min-pycor or  y-coordinate > max-pycor [die] 
  set ycor y-coordinate
  set x-coordinate xcor * x-stretch if x-coordinate > max-pxcor or x-coordinate < min-pxcor [die] 
  set xcor x-coordinate 
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Data and plotting proceedures;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-sample
set string "Zipf's law states that given some corpus of natural language utterances, The same relationship occurs in many other rankings unrelated to language, such as the population ranks of cities in various countries, corporation sizes, income rankings, and so on. The appearance of the distribution in rankings of cities by population was first noticed by Felix Auerbach in 1913.[2] Empirically, a data set can be tested to see if Zipf's law applies by running the regression log R = a - b log n where R is the rank of the datum, n is its value and a and b are constants. Zipf's law applies when b = 1. When this regression is applied to cities, a better fit has been found with b = 1.07. While Zipf's law holds for the upper tail of the distribution, the entire distribution of cities is log-normal and follows Gibrat's law.[3] Both laws are consistent because a log-normal tail can typically not be distinguished from a Pareto (Zipf) tail."
remove-punctuation
  
end

to load-string
ask utterances [die]
  ;; We check to make sure the file exists first
  ifelse ( file-exists? "declaration.txt" )
  [
    ;; We are saving the data into a list, so it only needs to be loaded once.
    set string []

    ;; This opens the file, so we can use it.
    file-open "declaration.txt"

    ;; Read in all the data in the file
    while [ not file-at-end? ]
    [
      ;; file-read gives you variables.  In this case numbers.
      ;; We store them in a double list (ex [[1 1 9.9999] [1 2 9.9999] ...
      ;; Each iteration we append the next three-tuple to the current list
      set string sentence string (file-read-line)   ;set patch-data sentence patch-data (list (list file-read file-read file-read))
    ]
    
   ; set patch-data sentence patch-data (list (list file-read file-read file-read))

    user-message "File loading complete!"

    ;; Done reading in patch information.  Close the file.
    file-close
  ]
  [ user-message "There is no File IO Patch Data.txt file in current directory!" ]
remove-punctuation 
define-utterances
end

to remove-punctuation
  set string remove "," string
  set string remove "." string
  set string remove "(" string
  set string remove ")" string
  set string remove "?" string
  set string remove "!" string
  set string remove "-" string
  set string remove "/" string
  set string remove ":" string
  set string remove ";" string
  set string remove "=" string
  set string remove "b" string
  set string remove "y" string
  set string word  string " " 
  
end

to draw-plot
    ask patch 2 2 [ 
    sprout-y-axis 1 [set size 1 set heading 0 set color black pd    ]
    sprout-x-axis 1 [set size 1 set heading 90 set color black pd   ]
  ]
  repeat max-pxcor - 3 [
      ask x-axis [ fd 1  ]
  ]
  
   repeat max-pycor - 3 [
      ask y-axis [ fd 1  ]
  ] 
  ask patch 40 .25  [sprout-x-axis-labels 1 [ set label "R  a  n  k" set size .4 ]]
  ask patch .5 36  [sprout-y-axis-labels 1 [ set label "F" set size .4 ]]
  ask patch .5 34  [sprout-y-axis-labels 1 [ set label "r" set size .4 ]]
  ask patch .5 32  [sprout-y-axis-labels 1 [ set label "e" set size .4 ]]
  ask patch .5 30  [sprout-y-axis-labels 1 [ set label "q" set size .4 ]]
  ask patch .5 28  [sprout-y-axis-labels 1 [ set label "u" set size .4 ]]
  ask patch .5 26  [sprout-y-axis-labels 1 [ set label "e" set size .4 ]]
  ask patch .5 24  [sprout-y-axis-labels 1 [ set label "n" set size .4 ]]
  ask patch .5 22  [sprout-y-axis-labels 1 [ set label "c" set size .4 ]]
  ask patch .5 20  [sprout-y-axis-labels 1 [ set label "y" set size .4 ]]
  ask x-axis-labels [set label-color black]
  ask y-axis-labels [set label-color black]
end
@#$#@#$#@
GRAPHICS-WINDOW
202
42
938
379
-1
-1
6.0
1
10
1
1
1
0
1
1
1
0
120
0
50
1
1
1
ticks
30.0

BUTTON
2
42
158
94
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
2
155
158
205
plot-by-frequency
plot-by-frequency
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
2
123
158
156
NIL
load-string
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
35
281
128
314
NIL
hide-words
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
301
422
413
455
NIL
fit-curve
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
301
454
413
487
n
n
-100
250
44.33
.01
1
NIL
HORIZONTAL

TEXTBOX
325
492
392
512
y = n * 1/x
11
0.0
0

BUTTON
2
204
158
256
NIL
plot-by-length
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
634
421
854
454
NIL
fit-normal
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
634
453
745
486
sigma
sigma
.01
1
0.09
.01
1
NIL
HORIZONTAL

SLIDER
634
485
745
518
mu
mu
0
10
0.19
.01
1
NIL
HORIZONTAL

SLIDER
744
485
853
518
y-scaling
y-scaling
1
4
1.32
.01
1
NIL
HORIZONTAL

SLIDER
743
453
853
486
x-scaling
x-scaling
1
200
51
1
1
NIL
HORIZONTAL

BUTTON
201
421
291
454
NIL
hide-curves
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
35
313
128
346
NIL
show-words
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
641
524
937
542
y = 1/sigma sqrt (2pi) * e ^ -(x - mu) ^ 2 / 2sigma ^ 2
11
0.0
1

BUTTON
201
453
291
486
NIL
show-curves
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
35
345
128
378
NIL
log-log
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
204
11
654
45
Note: must press setup and load-string each time before plot-by-frequency or plot-by-length
11
0.0
1

TEXTBOX
11
10
115
32
Zipf's Law
18
0.0
1

BUTTON
2
92
158
125
defaults
set x-stretch 1\nset y-stretch 1
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
463
422
568
455
NIL
fit-line
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
463
454
568
487
m
m
-2
2
-0.756
.001
1
NIL
HORIZONTAL

SLIDER
463
485
568
518
b
b
0
100
13.33
.01
1
NIL
HORIZONTAL

TEXTBOX
468
523
618
565
y = mx + b\nwhere m is slope\nand b is the y intercept
11
0.0
1

MONITOR
35
408
148
453
NIL
#-of-words
17
1
11

SLIDER
203
378
938
411
x-stretch
x-stretch
1
10
1.19
.01
1
NIL
HORIZONTAL

SLIDER
169
42
202
379
y-stretch
y-stretch
1
10
1.45
.01
1
NIL
VERTICAL

@#$#@#$#@
## WHAT IS IT?
This model compares power law distributions and normal distributions using a sample of text. You may input a sample or use a pre-uploaded sample. The sample is plotted as frequency to rank as well as word length. Different curves are available to fit the data in real time including a log-log- plot. Data is analyzed to compare with Zipf’s law. A cursory familiarity with power laws, normal distributions and logarithms is recomended.

## BACKGROUND

Zipf’s law states that given a large sample of writing the distribution of words in terms of its rank and frequency—that is in the order of popularity and how often used—will follow a 1/x power law.  That is, the frequency of a word is inversely proportional to its rank:

 frequency is proportional to  1/rank

This can also be written as y is proportional to nx^-1 , where n is some constant and —1 is the exponent or power. 

In the case of Zipf’s Law, this means the second highest ranking word (rank = 2) will appear 1/2 the number of times as the first, the 3rd will appear 1/3 the number of times etc. When a power law is plotted on a log-log graph (the x and y axses are in logarithmic increments) it will appear as a straight line. This relationship between variables is unique to power laws and offers a test for such. The formula below is a variant of the equation for a straight line:

log y = a (log x)

where a is the slope.


## HOW TO USE IT

Press the buttons on the interface in this sequence: setup —>defaults—>plot-by-frequency. A distribution of words distributed by frequency and rank should appear in the view window. Notice the general shape of the distribution. Note: units are not provided on the plot because this model is designed to overlay different types of distributions with different scales. Notice the general shape of the graph. Next we will fit a curve to the data. Press the button fit-curve below the plot. A power law will appear, the equation for which is y = n * 1/x. The parameter n can be adjusted with the slider labeled n. Adjust this parameter until the curve matches the approximate curve of the text. Note: words can be converted to points with the button hide-words?. If the curve does not fit well, you may also adjust the y-stretch and -x-stretch located along the y and x axis respectfully. These sliders work for all the curves as well as the words themselves but to effect the words you must press plot-by-frequency again each time. You may find the curve approximates the data with roughly n = some value. 

## LOADING CUSTOM STRINGS

First, place your simple-zipf’s-law.nlogo file in a separate folder within your Netlogo folder — the folder where your Netlogo program is stored on your hard-drive. To load a sample of text, find a sample without a lot of miscellaneous symbols, punctuation and spacings etc. and no images or the like. Save the file as a .txt file with the name declaration.txt into the same folder where your simple-zipf’s-law.nlogo is located. 

Note: It is possible to load other types of data besides text if you want. Any nominal data that is separated by spaces will work as long as you save it as  declaration.txt. It may be interesting to load a sequence of digits and see what you get.

  
##HOW TO UPLOAD CUSTOM FILE NAMES
To upload custom file names, label the file anything you like and make sure it is a text file ending in .txt. Next, go to the code tab in the model and find the 'to-load-string' procedure. Wherever you see a declaration.txt, replace with the file name of your choice ending in .txt.

For example, here is a filname called whatever.txt andn how it looks on the load-string procedure. 

to load-string

ask utterances [die]
  ;; We check to make sure the file exists first
  ifelse ( file-exists? "whatever.txt" )[
    ;; We are saving the data into a list, so it only needs to be loaded once.
    set string []
    ;; This opens the file, so we can use it.
    file-open "whatever.txt"

## CHANGING THE SIZE OF THE VIEW WINDOW
If you upload a sample of text that is longer than 200 words or so you will need to change the size of the view window in order to see all the text without wrapping. To do this go to the settings tab at the top of the interface. Change the max-xcor to 477 and the max-ycor to 200 and the patch size to 1.5 this should handle text samples up to 2000 words or so. If you have an even larger sample, increase these settings and re-arrange the interface buttons and sliders (you may need to look up how to do this in the Netlogo manual).

## THINGS TO NOTICE

Does your data approximate a power law? Perhaps you notice that the upper and lower tails deviate somewhat from a straight line. This is common in data and represents the volatility of the tail. Remember, the devil is in (de)tail? If you notice this, try fitting your line to the middle part of the data, bearing in mind that your data should demonstrate linearity over a number of orders of magnitude to be considered a power-law distribution.
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
NetLogo 5.0RC4
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
