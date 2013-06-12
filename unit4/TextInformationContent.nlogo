extensions [table]

globals [txt freq-table probabilty-table word-count Max-Word-Count]
to startup
  ca
  set input ""
end 

to setup
  ca
  set Max-Word-Count 1000  


  set txt input
  build-frequency-table list-of-words
  build-probability-table 
  sort-list
  plot-frequencies
  list-most-frequent-words

 
end 
to-report list-of-words
  let $txt txt
  set $txt word $txt " "  ; add space  for loop termination
  let words []  ; list of values
  while [not empty? $txt]
  [ let n position " " $txt
    ;show word "n: " n
    let $item substring $txt 0 n  ; extract item
    if not empty? $item [if member? last $item ".,?!;:" [set $item butlast $item ] ] ; strip trailing punctuation 
    ;carefully [set $item read-from-string $item ][ ] ; convert if number
    carefully [if member? first $item " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" [set words lput $item words]][]  ; append to list, ingnore cr/lfs
    set $txt substring $txt (n + 1) length $txt  ; remove $item and space
  ]
  report words
  print ""  
end

to build-frequency-table [#word]
  set freq-table table:make
  set probabilty-table table:make
  set word-count 0
  foreach #word [
    set word-count word-count + 1  ;; find total count of words
    if word-count >= Max-Word-Count [stop]
    ifelse table:has-key? freq-table ?  [let i table:get freq-table ? table:put freq-table ? i + 1 ] [table:put freq-table ? 1]
    ]
  
end

to build-probability-table
  foreach table:keys freq-table [ table:put probabilty-table ? table:get freq-table ? * (1 / word-count) ]
  
  ;print freq-table 
  ;print probabilty-table 
end 
  
  
to-report H
  let sum-plogp 0
  foreach table:keys probabilty-table
   [ 
     let p table:get probabilty-table ?  
     set sum-plogp  sum-plogp  + -1 * p * log p 2
   ]
   report sum-plogp
end 

to plot-frequencies
  foreach table:keys freq-table [plot table:get freq-table ? ]
end 

to sort-list
  let freq-list []
  foreach table:keys freq-table [ set freq-list lput list ? table:get freq-table ?  freq-list  ] ;builds a list version of the table.
  set freq-table table:from-list sort-by [last ?1 > last ?2] freq-list ;sort list by frequency counts and recreates table.
end 

to list-most-frequent-words
  let i 0
  foreach table:keys freq-table [ output-print (word table:get freq-table ? " x \"" ? "\"") set i i + 1 if i > 17 [output-print "... etc.. " stop]]
  
end 

to-report poe 
  report " I. \n HEAR the sledges with the bells,    \n Silver bells! \n  What a world of merriment their melody foretells! \n How they tinkle, tinkle, tinkle,  \n In the icy air of night!  \n While the stars, that oversprinkle  \n All the heavens, seem to twinkle \n  With a crystalline delight; \n  Keeping time, time, time,  \n In a sort of Runic rhyme,  \n To the tintinnabulation that so musically wells  \n From the bells, bells, bells, bells,  \n  Bells, bells, bells,   \n  From the jingling and the tinkling of the bells. \n\n II. \n  Hear the mellow wedding bells, \n   Golden bells! \n   What a world of happiness their harmony foretells! \n  Through the balmy air of night  \n  How they ring out their delight!  \n From the molten golden-notes,  \n And all in tune,  \n  What a liquid ditty floats  \n To the turtle-dove that listens, while she gloats  \n  On the moon!   \n Oh, from out the sounding cells,  \n  What a gush of euphony voluminously wells!  \n  How it swells!  \n  How it dwells  \n  On the Future! how it tells   \n Of the rapture that impels  \n  To the swinging and the ringing   \n Of the bells, bells, bells,  \n  Of the bells, bells, bells, bells, \n  Bells, bells, bells,   \n  To the rhyming and the chiming of the bells!  \n  III.  \n Hear the loud alarum bells,   \n  Brazen bells!  \n  What tale of terror, now, their turbulency tells!  \n  In the startled ear of night   \n How they scream out their affright! \n   Too much horrified to speak  \n  They can only shriek, shriek, \n   Out of tune,  \n  In a clamorous appealing to the mercy of the fire,  \n  In a mad expostulation with the deaf and frantic fire,   \n Leaping higher, higher, higher,  \n  With a desperate desire,   \n And a resolute endeavor.  \n  Now now to sit or never, \n   By the side of the pale-faced moon.   \n Oh, the bells, bells, bells!  \n  What a tale their terror tells \n   Of Despair!   \n How they clang, and clash, and roar!  \n  What a horror they outpour   \n On the bosom of the palpitating air!   \n Yet the ear it fully knows,   \n By the twanging,   \n And the clanging,   \n How the danger ebbs and flows;   \n Yet the ear distinctly tells, In the jangling,   \n And the wrangling, \n  How the danger sinks and swells,  \n  By the sinking or the swelling in the anger of the bells,  \n   Of the bells,   \n  Of the bells, bells, bells, bells,  \n  Bells, bells, bells,  \n   In the clamour and the clangour of the bells!   \n IV.   \n   Hear the tolling of the bells,  \n   Iron bells! \n   What a world of solemn thought their monody compels! \n  In the silence of the night,  \n  How we shiver with affright  \n  At the melancholy menace of their tone!  \n For every sound that floats  \n From the rust within their throats   \n Is a groan.   \n And the people ah, the people  \nThey that dwell up in the steeple,  \nAll alone, And who, tolling, tolling, tolling, \n In that muffled monotone,\n Feel a glory in so rolling  \n  On the human heart a stone   \n  They are neither man nor woman  \n  They are neither brute nor human  \n   They are Ghouls:  \n  And their king it is who tolls;  \n  And he rolls, rolls, rolls,  \n  Rolls   A paean from the bells!   \n And his merry bosom swells  \n  With the paean of the bells!  \n And he dances, and he yells; \n  Keeping time, time, time,  \n  In a sort of Runic rhyme,  \n  To the paean of the bells,  Of the bells:   \n Keeping time, time, time,  \nIn a sort of Runic rhyme,  \n  To the throbbing of the bells,   \n  Of the bells, bells, bells, \n To the sobbing of the bells;  \n Keeping time, time, time,  \n  As he knells, knells, knells,  \n  In a happy Runic rhyme,  \n  To the rolling of the bells, \n  Of the bells, bells, bells:  \n To the tolling of the bells, \n  Of the bells, bells, bells, bells, \n  Bells, bells, bells,  \n To the moaning and the groaning of the bells."
end 

to flip-biased-coin
 ifelse random 100 < ProbOfHeads [set input word input "Heads "][set input word input  "Tails "]
end 
@#$#@#$#@
GRAPHICS-WINDOW
581
38
1024
502
16
16
13.121212121212121
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

INPUTBOX
15
157
552
499
input
 Tails Tails Tails Heads Heads Heads Tails Tails Tails Heads Tails Heads Tails Tails Heads Heads Tails
1
0
String

BUTTON
13
98
87
148
Go
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
454
83
549
128
H
H
4
1
11

PLOT
578
20
1090
503
Word Frequencies
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

TEXTBOX
11
20
316
55
Information Content Calculator
18
0.0
1

TEXTBOX
101
65
353
123
Paste text in the input window below.  Word count will show you how many words or elements have been entered. All samples will be limited to 1000 words. 
11
0.0
1

MONITOR
362
83
447
128
Word count
word-count
17
1
11

BUTTON
1104
23
1239
56
Fair Coin
set input  word input one-of [\" Heads\" \" Tails\"]
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
1105
67
1240
100
Biased Coin
flip-biased-coin
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
822
49
1077
380
12

TEXTBOX
1106
92
1274
134
NIL
11
0.0
1

BUTTON
1110
308
1216
341
Wiki
set input \"Principal component analysis (PCA) is a mathematical procedure that uses an orthogonal transformation to convert a set of observations of possibly correlated variables into a set of values of linearly uncorrelated variables called principal components. The number of principal components is less than or equal to the number of original variables. This transformation is defined in such a way that the first principal component has the largest possible variance (that is, accounts for as much of the variability in the data as possible), and each succeeding component in turn has the highest variance possible under the constraint that it be orthogonal to (i.e., uncorrelated with) the preceding components. Principal components are guaranteed to be independent only if the data set is jointly normally distributed. PCA is sensitive to the relative scaling of the original variables. Depending on the field of application, it is also named the discrete Karhunen–Loève transform (KLT), the Hotelling transform or proper orthogonal decomposition (POD).PCA was invented in 1901 by Karl Pearson.[1] Now it is mostly used as a tool in exploratory data analysis and for making predictive models. PCA can be done by eigenvalue decomposition of a data covariance (or correlation) matrix or singular value decomposition of a data matrix, usually after mean centering (and normalizing or using Z-scores) the data matrix for each attribute.[2] The results of a PCA are usually discussed in terms of component scores, sometimes called factor scores (the transformed variable values corresponding to a particular data point), and loadings (the weight by which each standardized original variable should be multiplied to get the component score).[3]PCA is the simplest of the true eigenvector-based multivariate analyses. Often, its operation can be thought of as revealing the internal structure of the data in a way that best explains the variance in the data. If a multivariate dataset is visualised as a set of coordinates in a high-dimensional data space (1 axis per variable), PCA can supply the user with a lower-dimensional picture, a \\\"shadow\\\" of this object when viewed from its (in some sense) most informative viewpoint. This is done by using only the first few principal components so that the dimensionality of the transformed data is reduced.PCA is closely related to factor analysis. Factor analysis typically incorporates more domain specific assumptions about the underlying structure and solves eigenvectors of a slightly different matrix.\"
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
1111
352
1218
385
Poe
set input poe
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
1110
260
1260
304
Use these text samples or cut and paste your own.\n
11
0.0
1

TEXTBOX
377
32
546
83
Information content (H) is measured in bits. 
14
0.0
1

SLIDER
1107
109
1242
142
ProbOfHeads
ProbOfHeads
0
100
60
1
1
NIL
HORIZONTAL

BUTTON
13
63
86
96
Reset
Startup
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
1135
157
1213
190
Fair Die
set input  word input one-of [\" 1\" \" 2\" \" 3\" \" 4\" \" 5\" \" 6\"]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Here is a tool to calculate the information entropy or uncertainty (H) of any "message".

Entropy is a  key measure of information which is usually expressed by the average number of bits needed to store or communicate one symbol in a message. Entropy quantifies the uncertainty involved in predicting the value of a future event (or random variable). For example, the ability to correctly guess the outcome of a fair coin flip (one with two equally likely outcomes) provides less information (lower entropy, less surprising) than specifying the outcome from a roll of a die (six equally likely outcomes). Using this method we are able to precisely measure this  "surprize value" in different contexts. 

## HOW IT WORKS

This tool accepts text as input and calculates the frequency with which each word occurs. A "frequency table" is built. The parsing is quite crude, "The" is considered to be a different word from "the". After calculating frequencies, a second table is built , "probability table". This table hold the probability of encountering any particular word in the text if you were to be given a single word at random from the text. The probability for each word is calculated by dividing frequency count of any word by total words in the message. 

The probabilities from the probability table are used to build the sum that is H. This is done by taking the sum of probability of each element times the log of the probability and multiplying by negative 1. In other words, sum of - p log p over all elements in the message. 



## HOW TO USE IT

Load text and press "Go". Alternatively, use the buttons on the right to load sample text. 

## THINGS TO NOTICE
Notice the use of the table extension. This data structure make it much easier to organize the tables of information that we create to store frequency and probability data. Each table simply a set of ordered pairs  Key  ---> Value. To find the value of an Key use the table:get  primitive. 

## THINGS TO TRY/EXTENDING THE MODEL

Improvements to the parser could certainly be made. Also, more interesting ways to visualize the entropy of different contexts would be valuable.


## RELATED MODELS
There are many models in the Complexity Explorer suite that deal with concepts from information theory.
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
