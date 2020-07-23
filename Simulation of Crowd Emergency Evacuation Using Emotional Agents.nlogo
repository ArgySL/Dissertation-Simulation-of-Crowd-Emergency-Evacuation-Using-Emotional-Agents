breed [citizens citizen]
breed [authorities authority]
;;directed-link-breed [contagions contagion]


globals [

  total-citizens  ;;Total number of people present on the area
  successful-escapes  ;;Total number of people that have been evacuated
  total-contagions ;; Total number of emotional contagions that took place
  failed-evacuations ;; Total number of people that failed to evacuate the area
;; %panicked      ;; Percentage of panicked people
;;  %alert         ;; Percentage of alert people
;;  %calm          ;; Percentage of calm people

  ]

citizens-own [

 ;; speed ;; Speed of citizens; fluctuates depending on emotional state
  panicked? ;; Panicked state of citizens
  alerted? ;;  Alerted state of citizens
  calm? ;; Calm state of citizens
  turn-check ;; A debugging variable that serves its purpose by pinpointing which direction the agent chose to take.
  evacuation-directions?;; A variable that is used to facilitate the turtle's evacuation
  mood;; The variable used to store the mood of a turtle
]

to draw-building

  if mouse-down?     ;; Use the mouse to draw buildings and/or structures.
    [
      ask patch mouse-xcor mouse-ycor ;;I was conflicted whether to include a pre-defined map or give the option to draw buildings/surroundings.
                                      ;;On the one hand, we have code simplicity and map flexibity, with the only disadvantage being the slow setup of the environment.
            [ set pcolor gray ]       ;;On the other hand, there is better control over the model and more sophisticated techniques can be applied, at the cost of enviroment flexibility.

  ]

end

to draw-exit

  if mouse-down?     ;; Use the mouse to draw the exit that turtles use to evacuate.
    [
      ask patch mouse-xcor mouse-ycor

            [ set pcolor magenta ]

  ]

end

to place-authorities ;; A procedure used for debugging purposes to check citizen behavior.

  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor

            [ sprout-authorities 1
                [set color orange] ]
      set-default-shape authorities "person"

  ]

end

to setup

  clear-turtles
  setup-figures
  reset-ticks
  reset-timer
  clear-all-plots

end

to go

  ask citizens [
  emotional-check
  flee
  interact
  seek-help
  hurried-escape
  evacuate
  update-globals
  ]

  tick
  if successful-escapes + failed-evacuations = initial-population [stop]
  if  ticks >= 2000 [stop]

end

to setup-figures ;; Procedure that initializes turtle numbers, locations and variables
                 ;; Has potential for future improvements and/or additions

  ;; ifelse chance >= 50
  ;; [ask n-of 1 patches with [pcolor = black] [
  ;;  [set pcolor = red ] ] ] ;;for fire
  ;;[ask n-of 1 patches with [pcolor = black][
  ;; [set pcolor = blue ] ] ] ;;for flood

  ask n-of initial-population patches with [pcolor = black]
    [ sprout-citizens 1
      [ set color blue ] ]

  ask n-of initial-authorities patches with [pcolor = black]
    [ sprout-authorities 1
      [ set color orange ] ]

  ask n-of 1 patches with [pcolor = magenta]
   [ sprout-authorities 1
    [ set color orange ] ]



  ask n-of hazards patches with [pcolor = black]
      [ set pcolor red]

  set-default-shape citizens "person"
  set-default-shape authorities "person"
  set successful-escapes 0
  set failed-evacuations 0

  ask citizens [
    set total-contagions 0
    set panicked? false
    set alerted? false
    set calm? false
    set evacuation-directions? false
    catastrophe-occurs
  ]

end

to catastrophe-occurs;; The "event" that initiates the whole process of evacuation
                     ;; It assigns statuses to all existing citizens and starts the evacuation.

  set mood random 100

  ifelse mood >= 69
    [ calm-down ]
    [ if mood <= 68
      [ get-alerted ]
    ]

  if mood <= 15
    [get-panicked]

end

to flee
  ask citizens with [ panicked? ] [
    rt random-float 30
    lt random-float 30
    fd 0.5

  ]
  ask citizens with [ alerted? ] [
    rt random-float 30
    lt random-float 30
    fd 0.2

  ]
  ask citizens with [ calm? ] [
    rt random-float 30
    lt random-float 30
    fd 0.1

  ]
 ask citizens [
  if [pcolor] of patch-ahead 1 = grey
    [collision-check]
  ]

END

to seek-help;; Procedure that helps citizens locate authorities

  if any? turtles in-radius 4 with [color = orange][
   face min-one-of turtles with [ color = orange ] [ distance myself ]
     fd 4

      get-directions
    ]

end

to hurried-escape ;;Procedure that helps citizens locate the nearest exit

  if any? authorities in-radius 30 with [pcolor = magenta]
   [if any? patches in-radius 30 with [pcolor != gray] [
    face min-one-of patches with [ pcolor = magenta ] [ distance myself ]
    ;;   fd 8
    ]
  ]
end


to evacuate ;; The final step of evacuation

    ask citizens with [evacuation-directions?] [

     face min-one-of patches with [ pcolor = magenta ] [ distance myself ]
     fd 1
    ]

  ask citizens with [pcolor = magenta]
    [evacuation-successful]


  ask citizens with [pcolor = red]
     [evacuation-failed]


end

to emotional-check ;; This procedure exists to mimic the mental deterioration
                   ;; of the citizen as time goes by

  if ticks mod 20 = 0 ;;do something every N number of ticks
  [ set mood mood - 1 ]

   ifelse mood >= 69
    [ calm-down ]
    [ if mood <= 68
      [ get-alerted ]
    ]

  if mood <= 15
    [get-panicked]


  if mood <= 0 [
     evacuation-failed
    ]

end

to get-panicked

  set panicked? true
  set alerted? false
  set calm? false
  set color red

  end

to get-alerted

  set alerted? true
  set panicked? false
  set calm? false
  set color yellow

end

to calm-down

  set calm? true
  set panicked? false
  set alerted? false
  set color green

end

to interact;; What I want to do here is mimic emotional contagion.

  ask citizens with [alerted?] [
    if any? citizens in-radius 2 with [panicked?]
        [ set mood mood - 1
          set total-contagions total-contagions + 1]

    if any? citizens in-radius 2 with [calm?]
        [ set mood mood + 1
          set total-contagions total-contagions + 1]

    if any? other citizens in-radius 2 with [alerted?]
        [ set mood mood + 0
          set total-contagions total-contagions + 1]

  ]
  ask citizens with [calm?] [
    if any? citizens in-radius 2 with [alerted?]
      [set mood mood - 1.5
        set total-contagions total-contagions + 1 ]

    if any? citizens in-radius 2 with [panicked?]
      [set mood mood - 4
        set total-contagions total-contagions + 1 ]

    if any? other citizens in-radius 2 with [calm?]
      [set mood mood + 0.5
        set total-contagions total-contagions + 1]
  ]

  ask citizens with [panicked?] [
    if any? other citizens in-radius 2 with [panicked?]
      [ set mood mood - 2
        set total-contagions total-contagions + 1 ]

    if any? citizens in-radius 2 with [alerted?]
      [ set total-contagions total-contagions + 1 ]

    if any? citizens in-radius 2 with [calm?]
      [ set total-contagions total-contagions + 1 ]

  ]

end

to get-directions


    if any? authorities in-radius 3
       [
         set mood mood + 5
         set evacuation-directions? true
         set total-contagions total-contagions + 1
       ]

end

to collision-check

    set turn-check random 10

     if turn-check > 6
      [turn-right]
     if turn-check < 4
      [turn-left]
       if [pcolor] of patch-ahead 1 = gray
        [avoid-wall]

end

to avoid-wall
  let choice-path random 10
  ifelse choice-path >= 6

  [turn-right]
  [turn-left]

end



to turn-right ;;Generates a random degree of turn.

  rt random-float 180

end

to turn-left   ;;Generates a random degree of turn.

  lt random-float 180

end

to evacuation-failed

  set failed-evacuations failed-evacuations + 1
  die

end

to evacuation-successful

  set successful-escapes successful-escapes + 1
  die

end


to update-globals ;;Sets globals to current values for reporters.

  set total-citizens (count citizens)

end
@#$#@#$#@
GRAPHICS-WINDOW
288
81
808
602
-1
-1
8.4
1
10
1
1
1
0
1
1
1
-30
30
-30
30
0
0
1
ticks
30.0

BUTTON
14
32
78
65
Setup
setup\n
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
79
32
142
65
Go
go
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
13
69
144
102
Setup Structures
draw-building
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
20
231
192
264
initial-population
initial-population
0
150
0.0
1
1
NIL
HORIZONTAL

SLIDER
20
272
192
305
initial-authorities
initial-authorities
0
4
0.0
1
1
NIL
HORIZONTAL

MONITOR
12
499
153
544
# of Sucessful Escapes
successful-escapes
17
1
11

BUTTON
153
71
238
104
Draw Exit
draw-exit
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
27
149
151
182
NIL
place-authorities
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
23
108
125
141
Clear Turtles
clear-turtles
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
135
109
212
143
Clear All
ca
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
153
499
277
544
# of Failed Evacuations
failed-evacuations
17
1
11

PLOT
35
621
235
771
Emotional State Tracking
Time
People
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Panicked" 1.0 0 -2674135 true "" "plot count citizens with [ panicked? ] display"
"Alerted" 1.0 0 -1184463 true "" "plot count citizens with [ alerted? ] display"
"Calm" 1.0 0 -13840069 true "" "plot count citizens with [ calm? ] display"
"Total" 1.0 0 -7500403 true "" "plot count citizens display"

MONITOR
141
545
260
590
Simulation Duration
ticks
17
1
11

MONITOR
10
544
140
589
# of Emotion Contagions
total-contagions
17
1
11

MONITOR
27
364
143
409
# of Panicked People
count citizens with [panicked?]
17
1
11

SLIDER
19
312
191
345
hazards
hazards
0
3
0.0
1
1
NIL
HORIZONTAL

MONITOR
1769
653
1839
698
NIL
timer
17
1
11

MONITOR
26
409
135
454
# of Alerted People
count citizens with [alerted?]
17
1
11

MONITOR
26
455
119
500
# of Calm People
count citizens with [calm?]
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT
It is strongly recommended to first draw the desired environment for the agents to navigate in, otherwise every action taken will result to a runtime error.
(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

Various improvements can be made upon this model in terms of both functionality and utility.

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES
Zombieland 1.4
Virus Model
State Machines Example Model
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
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
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
