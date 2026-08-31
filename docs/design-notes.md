# Algorithmically Augmented Percussion with Python + Max/MSP

## Consolidated design notes

This document consolidates the discussion beginning with the idea of composing a percussion/drum piece in a Ferneyhoughian spirit using **Python as the compositional engine**, **Max/MSP as the real-time performance and sound engine**, and optionally **electronic drums as live input** and **Jitter for visuals**.

The goal is not to imitate Brian Ferneyhough's surface style mechanically, nor simply to generate dense drum patterns. The useful idea taken from the discussion is to construct music from **hierarchical, multi-parametric, partially independent and sometimes conflicting formal processes**, while separating the complexity of the resulting music from the physical difficulty of the live part.

------------------------------------------------------------------------

# 1. Core artistic problem

The initial practical problem is:

> How can a composer without access to virtuoso performers realize highly complex, formally organized percussion music electronically, while retaining a meaningful role for live human performance?

A useful answer is to split the system into two levels:

-   a **simple human performance**, providing structural events, timing, energy, articulation and gesture;
-   an **algorithmic superstructure**, generated from or conditioned by that performance.

The human does not have to execute every generated event. Instead, the human supplies a performable structural skeleton and the machine realizes lower-level complexity.

Conceptually:

``` text
                 COMPOSITION
                      |
             formal superstructure
                      |
              Python algorithm
                      |
          +-----------+-----------+
          |                       |
        HUMAN                  MACHINE
          |                       |
   structural level          detail level
          |                       |
   X---------X              x-x-xx-x-x
          |                       |
          +-----------+-----------+
                      |
                 PERFORMANCE
```

The key proposition is:

> **Compositional complexity does not require equivalent physical performance complexity.**

This is more interesting than simply replacing an unavailable virtuoso drummer with sequenced samples. The distribution of responsibility between performer and machine becomes part of the composition itself.

------------------------------------------------------------------------

# 2. Why percussion is particularly suitable

Percussion naturally supports multi-parametric organization. A percussion event can be described through many relatively independent dimensions:

-   instrument;
-   register;
-   striking area;
-   beater;
-   dynamic;
-   articulation;
-   resonance;
-   duration;
-   density context;
-   attack sharpness;
-   spectral brightness;
-   damping;
-   repetition rate;
-   spatial position;
-   sample variation;
-   pitch shift;
-   processing amount.

Therefore the system does not need to think only in terms of:

``` text
pitch + rhythm
```

It can think in terms of:

``` text
instrument
surface
stick/beater
dynamic
attack
density
resonance
spatial position
rhythmic subdivision
processing
```

This makes percussion particularly appropriate for post-serial or Ferneyhough-inspired multi-parametric organization.

## 2.1 Do not begin from conventional drum patterns

If the starting abstraction is:

``` text
kick / snare / hi-hat groove
```

the result may easily become complicated IDM, progressive-metal drumming or generative beat music.

A better abstraction is to treat the kit as a **field of sound-producing surfaces**.

For example:

``` text
Bass drum:
- center
- edge
- muted
- open
- roll

Snare:
- center
- rim
- rimshot
- cross-stick
- buzz
- dead stroke

Tom:
- center
- edge
- muted

Hi-hat:
- closed
- half-open
- open
- pedal
- bell

Ride:
- bow
- bell
- edge
- choke
```

The system therefore operates on perhaps 20--30 articulation states rather than five generic drums.

------------------------------------------------------------------------

# 3. Recommended technical architecture

The recommended division of responsibility is:

``` text
Electronic drums
       |
       | MIDI
       v
    Max/MSP
       |
       | OSC
       v
     Python
 compositional engine
       |
       | OSC
       v
    Max/MSP
       |
       +-- sample playback
       +-- synthesis
       +-- DSP
       +-- routing
       +-- spatialization
       |
       v
      AUDIO
```

Python answers:

> **What should happen?**

Max answers:

> **How and exactly when should it sound?**

## 3.1 Python responsibilities

Python is the general composition engine. It should handle:

-   macro form;
-   section logic;
-   formal curves;
-   rhythmic trees;
-   phrase archetypes;
-   transformations;
-   gesture analysis;
-   memory;
-   constraints;
-   competing parametric processes;
-   candidate generation and selection;
-   precomposed compositional material;
-   interpretation of WHAT / WHEN / HOW HARD;
-   generation of abstract output events.

## 3.2 Max/MSP responsibilities

Max should handle:

-   MIDI input;
-   immediate performer feedback;
-   OSC communication;
-   low-latency scheduling;
-   sample playback;
-   synthesis;
-   DSP;
-   mixing;
-   spatialization;
-   continuous controllers;
-   visual rendering through Jitter;
-   real-time output.

Anything genuinely time-critical should stay in Max.

Python should preferably return a phrase with **relative event offsets** rather than trying to sleep between events and transmit them one by one.

For example Python may return:

``` text
+0 ms      snare       energy=.82
+47 ms     snare-rim   energy=.63
+119 ms    tom-high    energy=.57
+163 ms    metal       energy=.42
+281 ms    tom-low     energy=.31
```

Max schedules these accurately.

## 3.3 Immediate sound versus generated response

A useful optimization is to let the physical hit sound immediately in Max:

``` text
E-drum ---> Max ---> immediate drum sound
              |
              +----> Python
                       |
                    compute
                       |
                       v
                      Max
                       |
                generated superstructure
```

This avoids unnecessary latency and reinforces the conceptual distinction:

> **Human event = structural event. Machine events = elaboration of that event.**

------------------------------------------------------------------------

# 4. Communication between Max and Python

OSC over UDP is a natural first choice.

Example Max-to-Python messages:

``` text
/hit/snare 0.82
/hit/tom1 0.46
/hit/kick 0.91
```

Python-to-Max:

``` text
/event snare_rim 0.000 0.82
/event tom1      0.047 0.63
/event metal     0.119 0.57
/event tom2      0.163 0.42
```

In a more developed implementation, Python should return whole phrase descriptions rather than individual time-delayed messages.

The communication protocol should ideally use semantic information rather than being tied directly to MIDI note numbers.

------------------------------------------------------------------------

# 5. Neutral event representation

A percussion event can contain much more information than standard MIDI conveniently expresses.

For example:

``` json
{
  "time": 12.734,
  "instrument": "snare",
  "zone": "rim",
  "velocity": 0.82,
  "duration": 0.11,
  "pitchShift": -0.7,
  "brightness": 0.63,
  "pan": -0.2,
  "flam": 3,
  "timingDeviation": 0.018
}
```

This neutral representation can later be rendered through Max, REAPER or MIDI.

A useful long-term architecture is:

``` text
                 Python
            Composition Core
                  |
       +----------+----------+
       |          |          |
      Max       REAPER      MIDI
     live       offline     export
 performance   rendering
```

The composition logic therefore does not become dependent on Max.

------------------------------------------------------------------------

# 6. Live input: WHAT, WHEN and HOW HARD

A simple electronic-drum performance already supplies three useful dimensions:

-   **WHAT** was struck;
-   **WHEN** it was struck;
-   **HOW HARD** it was struck.

These should not merely reproduce ordinary MIDI mappings.

Avoid:

``` text
WHAT     -> instrument
WHEN     -> note time
HOW HARD -> volume
```

Instead, treat the input as compositional variables.

A hit can be modeled as:

\[ H_n = (W_n, T_n, V_n) \]

where:

-   (W_n) = struck pad/surface;
-   (T_n) = timestamp;
-   (V_n) = velocity.

Also derive:

\[ `\Delta `{=tex}T_n = T_n - T\_{n-1} \]

and maintain previous events:

\[ H\_{n-1}, H\_{n-2}, `\ldots`{=tex} \]

The response is then conceptually:

\[ P_n = G(H_n, H\_{n-1}, H\_{n-2}, `\ldots`{=tex}, F(t)) \]

where (F(t)) is the current formal state.

------------------------------------------------------------------------

# 7. WHAT as process selection

WHAT does not need to mean "play the corresponding drum sample."

Different pads can select **process families**.

Example:

  Input    Process
  -------- ---------------
  Kick     convergence
  Snare    fragmentation
  Tom      propagation
  Cymbal   resonance

## 7.1 Convergence

Events begin dispersed and progressively collapse toward a target:

``` text
x       x      x    x   x  x xxX
```

The convergence can occur in:

-   time;
-   spatial position;
-   instrumental topology;
-   register;
-   spectral content;
-   dynamics.

## 7.2 Fragmentation

One event recursively divides:

``` text
X
|
X       X
|
X   x   X    x
|
X x x x X x x x
```

Parameters can include:

-   recursion depth;
-   branching factor;
-   decay;
-   instrumental spread;
-   temporal compression.

## 7.3 Propagation

A gesture moves across the virtual percussion field:

``` text
snare -> rack tom -> floor tom -> ride -> electronic layer
```

## 7.4 Resonance

A short attack generates a sustained field instead of a burst of attacks:

``` text
X
|
+-------------------------------- resonance
```

------------------------------------------------------------------------

# 8. HOW HARD as transformation strength

Velocity can represent **energy** rather than simply loudness.

Define:

\[ E `\in [0,1]`{=tex}\]

and derive several properties from it.

For example:

``` text
velocity / energy
       |
       +-- recursion depth
       +-- spectral distortion
       +-- dynamic range
       +-- instrumental distance
       +-- phrase instability
       +-- sample layer
       +-- stick hardness
       +-- damping
```

A soft snare fragmentation might be:

``` text
X
|
X       x
```

A hard one:

``` text
X
|
X x xx x xxx x x xx x
```

Mappings can be nonlinear.

For example:

``` text
low energy:
- soft mallet
- center hit
- long resonance

medium:
- stick
- edge hit
- medium damping

high:
- rimshot
- choke
- distortion
```

------------------------------------------------------------------------

# 9. WHEN has two meanings

## 9.1 Relative WHEN

The interval from the previous hit can influence local behavior.

Long interval:

``` text
X----------------X
```

could produce expansion or a broad resonant gesture.

Short intervals:

``` text
X--X-X-X
```

could produce compression, density or instability.

## 9.2 Absolute WHEN

The same hit should behave differently depending on its position in the piece.

A hard snare hit at minute 1 might create:

``` text
X -> x x
```

while at minute 8:

``` text
X -> xx x xxx xx x xxxxx ...
```

because the macro-formal state has changed.

Therefore:

> The macro form has authority over the local interpretation of live input.

------------------------------------------------------------------------

# 10. Human hit as trigger: useful but limited

The simplest implementation is:

``` text
hit -> launch fixed precomposed sequence
```

This is valid but compositionally limited. It makes the performer essentially a launcher of stored phrases.

A better approach is:

``` text
hit -> instantiate a precomposed abstract process
```

For example:

``` text
GESTURE TYPE 7

rhythm ratios:      3 : 5 : 2 : 7
density:            0.65
depth:              3
instrument path:    outward
energy decay:       exponential
```

The hit provides:

``` text
origin = snare
start = current time
energy = .76
```

and the system instantiates a concrete realization.

Thus the composition is predetermined at the structural level without being fixed playback.

------------------------------------------------------------------------

# 11. Human skeleton versus machine superstructure

A particularly strong model is to generate a complex structure and derive a simpler structural skeleton for the performer.

For example:

``` text
FULL MACHINE STRUCTURE:
x-x-xxx--x-x--xx-x-x-x---xxx-x--x-x-xxxx-x...

STRUCTURAL NODES:
X-------------X--------X----------------X
```

The performer plays the structural nodes.

Python/Max knows the relationship between each node and the detailed structure associated with it.

Conceptually:

``` text
Python generates complex structure
              |
       derive hierarchy
              |
       +------+------+
       |             |
    skeleton       detail
       |             |
     HUMAN          MAX
       +------+------+
              |
         PERFORMANCE
```

Benefits:

-   complex structure remains composed;
-   the human performer remains indispensable;
-   the live part remains feasible;
-   timing and dynamics of the performer alter the realization;
-   machine complexity can be much greater than human complexity.

------------------------------------------------------------------------

# 12. Generating material between human events

Two consecutive hits can define a temporal container:

``` text
X-----------------------X
|<------ 820 ms ------->|
```

A proportional structure such as:

``` text
3 : 2 : 5 : 7
```

can be fitted into the container.

However, there is a real-time causality problem: the system does not know the length of the interval until the second hit occurs.

Solutions include:

1.  use the interval to determine the **next** generated phrase;
2.  use pre-existing estimates/prediction;
3.  delay the machine response intentionally;
4.  use human events as boundaries for processes that begin after the second event.

The one-gesture delay can itself become a compositional rule:

\[ H_n `\rightarrow `{=tex}M\_{n+1} \]

------------------------------------------------------------------------

# 13. Gesture-level interaction

Reacting to complete gestures may be stronger than reacting independently to every hit.

Architecture:

``` text
raw MIDI hits
     |
gesture segmentation
     |
gesture object
     |
feature extraction
     |
composition engine
```

The human performs a phrase, marks its completion, and the machine responds to the **whole gesture**.

This supports phrase-level relationships and avoids reducing the interaction to a series of isolated trigger-response events.

------------------------------------------------------------------------

# 14. Gesture segmentation

There is no requirement to infer gesture boundaries automatically.

## 14.1 Explicit delimiter

A dedicated MIDI note, pad, pedal or controller can mean:

> END CURRENT GESTURE

Everything since the previous delimiter becomes one gesture.

Advantages:

-   deterministic;
-   performer-controlled;
-   easy to debug;
-   no ambiguity;
-   musically intentional.

The delimiter may be silent or audible.

For example, a rimshot could simultaneously be a musical event and a phrase terminator.

## 14.2 Silence threshold

Alternative:

``` text
if no hit for > 800 ms:
    close current gesture
```

Useful but ambiguous.

A deliberate pause may split a gesture; dense transitions may fail to create a boundary.

## 14.3 Hybrid

Recommended:

``` text
explicit delimiter = authoritative

otherwise:
silence threshold may close gesture
```

## 14.4 Composition-controlled segmentation

Segmentation rules can themselves change by section:

``` text
gesture ends when:
- delimiter occurs; OR
- 6 hits have occurred; OR
- 2.5 seconds have elapsed
```

Thus segmentation can become a formal parameter.

------------------------------------------------------------------------

# 15. Gesture classification is optional

It is not necessary to classify every gesture as:

``` text
ACCELERATION
CRESCENDO
DESCENDING TRAJECTORY
...
```

Classification can discard useful continuous information.

Prefer deterministic **feature extraction**.

Useful gesture features include:

-   duration;
-   number of hits;
-   mean inter-onset interval;
-   IOI slope;
-   IOI variance;
-   velocity mean;
-   velocity slope;
-   velocity variance;
-   density;
-   instrument diversity;
-   instrumental entropy;
-   topological distance;
-   net displacement;
-   direction consistency;
-   return-to-origin tendency.

For example:

``` text
tempo_trend = -0.83
velocity_trend = +0.61
spatial_direction = -0.74
density = 0.82
```

The engine can use these continuous values directly.

If categories later prove compositionally useful, deterministic rules can be added:

``` python
if ioi_slope < -0.5:
    gesture_type = "strong_acceleration"
elif ioi_slope < -0.15:
    gesture_type = "mild_acceleration"
```

No machine learning is required.

Recommended starting point:

> **explicit segmentation + deterministic feature extraction + formal interpretation**

------------------------------------------------------------------------

# 16. Drum-kit topology

Assign physical or conceptual coordinates to the kit:

``` text
hihat      = (-2, 1)
snare      = (-1, 0)
tom1       = (0, 1)
tom2       = (1, 0)
floor_tom  = (2, -1)
ride       = (2, 1)
kick       = (0, -1)
```

This allows drum motion to function somewhat like melodic contour.

Possible generated trajectories:

-   spiral;
-   zig-zag;
-   nearest neighbor;
-   maximum-distance jump;
-   clockwise rotation;
-   random walk;
-   convergence toward a target;
-   expansion away from a source.

Features can include:

``` text
total_distance
net_displacement
direction_consistency
return_to_origin
```

The topology can affect both audio orchestration and visuals.

------------------------------------------------------------------------

# 17. Rhythmic organization

Use hierarchical proportional subdivision rather than arbitrary note durations.

Example:

``` text
whole span
   |
divide 5:3
   |
first region divide 4:7:2
second region divide 3:5
   |
selected nodes subdivide again
```

This produces hierarchical rhythm.

A rhythmic tree might be represented conceptually as:

``` text
RT-01

1
├── 3
│   ├── 2
│   ├── 1
│   └── 3
└── 5
    ├── 1
    ├── 4
    ├── 2
    └── 3
```

The tree exists independently of absolute duration and can be fitted to a human-defined or composition-defined temporal span.

In Python, exact rational arithmetic using `fractions.Fraction` is preferable during structural calculation:

``` python
Fraction(7, 48)
```

rather than prematurely converting everything to floating-point seconds.

Conversion to seconds can occur at rendering time.

------------------------------------------------------------------------

# 18. Phrase archetypes

Phrase archetypes give the piece recurring behavioral identities without requiring literal repetition.

Suggested archetypes:

-   FRAGMENT;
-   CONVERGE;
-   PROPAGATE;
-   RESONATE;
-   INTERRUPT;
-   SHADOW.

## FRAGMENT

One event becomes many.

## CONVERGE

Many dispersed events collapse toward a common target.

## PROPAGATE

An event or property travels through instrumental/topological space.

## RESONATE

An attack generates a sustained or spectrally evolving field.

## INTERRUPT

A human event terminates an existing machine process.

This gives the performer real formal agency.

## SHADOW

The machine recalls or imitates a recent human gesture with transformations such as:

-   delay;
-   temporal compression;
-   temporal expansion;
-   topological inversion;
-   dynamic inversion;
-   timbral substitution;
-   fragmentation;
-   rhythmic distortion.

The same archetype can appear differently according to formal state.

This creates coherence without simple repetition.

------------------------------------------------------------------------

# 19. Macro form

Generating interesting phrases is not enough. A collection of local algorithms does not automatically produce a piece.

A strong overarching principle proposed in the discussion is the changing **relationship between human and machine**.

One possible five-stage form:

``` text
I. IMITATION / DEPENDENCE
II. ELABORATION
III. MEMORY
IV. AUTONOMY / CONFLICT
V. RESIDUE
```

## I. Dependence / imitation

-   machine remains close to human input;
-   low density;
-   low autonomy;
-   little or no memory;
-   human-machine causality is obvious.

## II. Elaboration

-   machine recursively develops human material;
-   phrase archetypes become clearer;
-   complexity increases;
-   human events remain strong structural causes.

## III. Memory

-   the machine begins combining current input with previous gestures;
-   short- and medium-term memories become active;
-   recurrence appears without literal repetition.

## IV. Autonomy / conflict

-   accumulated processes continue independently;
-   machine memory and formal systems can override current human input;
-   competing layers become strong;
-   human can interrupt, redirect or destabilize machine activity.

## V. Residue

-   new generation may be disabled;
-   machine exposes transformed memories of earlier material;
-   human activity becomes sparse or stops;
-   remembered processes decay toward silence.

This provides a formal argument rather than merely an increase in note density.

------------------------------------------------------------------------

# 20. Machine autonomy as a formal parameter

Define:

\[ A(t) = `\text{machine autonomy}`{=tex} \]

with:

\[ 0 `\leq `{=tex}A `\leq 1`{=tex} \]

At (A=0), machine output closely follows human events.

At (A=1), machine processes can be largely independent.

Increasing autonomy may affect:

``` text
trigger dependence       ↓
rhythmic independence    ↑
phrase duration          ↑
subdivision depth        ↑
memory/history           ↑
timbral transformation   ↑
machine polyphony        ↑
prediction/deviation     ↑
```

Do not define autonomy as merely "more notes."

------------------------------------------------------------------------

# 21. Formal curves

Other parameters can evolve continuously through the piece:

``` text
machine_autonomy(t)
density(t)
memory_depth(t)
timbral_brightness(t)
rhythmic_instability(t)
human_dependency(t)
recursion_depth(t)
spectral_noise(t)
topological_spread(t)
```

Formal curves allow the same local input and phrase archetype to behave differently according to position in the piece.

This is one of the main mechanisms by which macro form governs microstructure.

------------------------------------------------------------------------

# 22. Section plans

The macro-formal labels should be implemented by explicit section plans.

Example:

``` text
SECTION III — MEMORY

duration:
150 seconds

human processes allowed:
- fragmentation
- propagation
- resonance

machine processes allowed:
- shadow
- delayed imitation
- recombination

rhythmic trees:
RT-04
RT-07
RT-11

memory depth:
2 -> 6 gestures

instrument field:
membranes -> mixed -> metals

density:
medium

maximum simultaneous machine voices:
5

phrase lengths:
1.5–8 seconds
```

The distinction is:

-   **macro form**: what is happening dramatically;
-   **section plan**: what mechanisms implement that state.

------------------------------------------------------------------------

# 23. Transformation matrices

A transformation matrix can describe relationships between phrase types or transformation possibilities.

For example:

  From → To     Fragment   Propagate   Resonate   Shadow   Converge
  ----------- ---------- ----------- ---------- -------- ----------
  Fragment           .10         .35        .05      .30        .20
  Propagate          .25         .10        .20      .30        .15
  Resonate           .05         .20        .30      .35        .10
  Shadow             .40         .15        .10      .10        .25
  Converge           .25         .25        .15      .20        .15

This may be probabilistic, but does not need to be.

Deterministic examples:

``` text
Fragment:
- inversion -> Converge
- temporal stretch -> Resonance
- topology rotation -> Propagate
- memory projection -> Shadow
```

"Matrix" here does not have to mean literal linear algebra. It can simply be a formal table of permitted or weighted transformations.

------------------------------------------------------------------------

# 24. Constraint structures

Constraints prevent generators from behaving arbitrarily.

## Hard constraints

Examples:

``` text
maximum machine voices = 6

never trigger two versions of the same sample
within 20 ms

resonance phrases cannot begin while
three other resonances are active

machine response must not obscure
the next structural human cue
```

## Soft constraints

Examples:

``` text
prefer propagation to neighboring instruments

prefer lower density after a very dense gesture

prefer timbral contrast with previous phrase

prefer preserving the drummer's velocity contour
```

A generator can produce multiple candidates and score them:

``` text
candidate A:
rhythmic fit        .82
timbral contrast    .64
formal fit          .92
memory relevance    .71
```

The highest-scoring candidate can be chosen.

The scores are **compositional fitness measures**, not objective measures of musical quality.

------------------------------------------------------------------------

# 25. Ferneyhoughian conflicting layers

The useful interpretation of "conflicting layers" is not simply several simultaneous percussion voices.

The more important principle is:

> **Several independent formal systems make competing demands on the same material.**

Suppose the drummer produces:

``` text
SNARE
velocity = .82
Δt = 410 ms
```

Independent systems might demand:

``` text
RHYTHM:
generate seven attacks and accelerate

DENSITY:
keep current activity low-medium

TIMBRE:
move from membranes toward metals

TOPOLOGY:
propagate outward from snare

DYNAMICS:
decrescendo sharply

MEMORY:
reuse an interval pattern from an earlier gesture
```

The generated phrase must negotiate these demands.

This is the central model for Ferneyhough-inspired parametric complexity in the system.

------------------------------------------------------------------------

# 26. Do not resolve every conflict perfectly

If every layer is collapsed into a smooth mathematically optimal compromise, the result may become too homogeneous.

Assign priorities:

``` text
rhythm       1.0
formal curve 0.8
topology     0.7
memory       0.5
dynamics     0.4
```

More importantly, allow priorities to change by section.

Early:

``` text
human input >>> everything else
```

During conflict:

``` text
machine memory
rhythmic process
formal autonomy
        >>> current human input
```

Thus the **hierarchy among competing systems is itself composed**.

------------------------------------------------------------------------

# 27. Literal parametric contradictions

Conflicting processes can operate at different hierarchical levels.

Example:

``` text
local rhythm:
ACCELERATE

group spacing:
EXPAND
```

Result:

``` text
x---x--x-x       x----x--x-x-x
                 ^
           larger group gap
```

Thus local acceleration and global expansion coexist.

Other useful contradictory trajectories:

``` text
density ↑
dynamic ↓
spectral brightness ↑
resonance ↓
```

or:

``` text
tempo ↑
instrumental spread ↓
memory influence ↑
human dependency ↓
```

The aim is not random contradiction but **non-alignment of independently organized parameters**.

------------------------------------------------------------------------

# 28. Machine memory

Machine memory should store human gestures and/or generated material so they can later influence new material.

Do not store only raw absolute MIDI timestamps.

A memory item should retain:

1.  absolute position in the piece;
2.  relative event timing;
3.  event properties;
4.  extracted features;
5.  optional formal metadata.

Conceptual object:

``` python
GestureMemory(
    start_time=42.180,
    events=[
        Hit(dt=0.000, pad="snare", velocity=0.74),
        Hit(dt=0.318, pad="tom1", velocity=0.51),
        Hit(dt=0.527, pad="snare", velocity=0.82),
    ],
    features={
        "duration": 0.527,
        "mean_velocity": 0.69,
        "density": 5.7,
        "trajectory": "snare→tom→snare",
        "acceleration": True
    }
)
```

Relative timing preserves the identity of the gesture independently of when it occurred.

------------------------------------------------------------------------

# 29. Ways to reuse memory

## Literal recall

Replay the gesture.

## Temporal transformation

``` text
original:
snare --310ms--> tom --210ms--> snare

compressed x0.55:
snare --171ms--> tom --116ms--> snare
```

## Topological transformation

Map the original pad path into another region of the kit.

## Dynamic inversion

Invert or otherwise transform the velocity contour.

## Partial recall

Reuse only:

-   rhythm;
-   velocity contour;
-   topology;
-   density profile;
-   articulation sequence;
-   rhythmic tree;
-   spectral trajectory.

For example:

``` text
old gesture
   |
   +-- rhythm --------> new phrase A
   +-- dynamics ------> new phrase B
   +-- topology ------> current Fragment process
```

This is more compositionally useful than simply looping old MIDI.

------------------------------------------------------------------------

# 30. Memory timescales

Use multiple memory horizons:

``` text
short-term:
last 2–4 gestures

medium-term:
material from current section

long-term:
important material from earlier sections
```

The macro form can determine which memory system is active.

For example:

-   early sections: memory disabled;
-   middle: short-term memory;
-   later: medium- and long-term recombination;
-   residue: only transformed long-term memory, with no new generative material.

This makes memory a formal device rather than a technical effect.

------------------------------------------------------------------------

# 31. The composition JSON

The JSON file should **not** contain the finished performance.

It should function as a **score/configuration for the Python composition engine**.

The Python source defines the general system.

The JSON defines one particular piece.

The Max patch defines the performance/rendering environment.

Separation:

``` text
composition.json
- form
- sections
- curves
- selected rhythmic trees
- transformations
- mappings
- constraints
- parameter values

Python source
- Composition
- FormalCurve
- RhythmicTree
- FragmentGenerator
- PropagationGenerator
- ConstraintSolver
- GestureMemory
- CompositionState
- Event
- Phrase

Max patch
- MIDI
- OSC
- scheduling
- sample mapping
- DSP
- audio
- visuals
```

------------------------------------------------------------------------

# 32. Example composition JSON

``` json
{
  "title": "Study I",

  "form": {
    "duration": 660,
    "sections": [
      {
        "id": "dependence",
        "start": 0,
        "end": 120
      },
      {
        "id": "elaboration",
        "start": 120,
        "end": 270
      },
      {
        "id": "memory",
        "start": 270,
        "end": 420
      },
      {
        "id": "conflict",
        "start": 420,
        "end": 540
      },
      {
        "id": "residue",
        "start": 540,
        "end": 660
      }
    ]
  },

  "curves": {
    "autonomy": [
      [0, 0.05],
      [270, 0.35],
      [420, 0.70],
      [520, 0.95],
      [660, 0.00]
    ],

    "density": [
      [0, 0.15],
      [300, 0.55],
      [500, 0.90],
      [660, 0.10]
    ]
  },

  "phrase_archetypes": {
    "fragment": {
      "min_depth": 1,
      "max_depth": 5
    },

    "propagate": {
      "max_distance": 4
    },

    "resonate": {
      "min_duration": 0.5,
      "max_duration": 6.0
    }
  },

  "rhythmic_trees": {
    "rt01": [3, [2, 1, 3], [1, 4, 2]],
    "rt02": [5, [3, 2], [7, 1, 4]]
  }
}
```

Python loads it once:

``` python
composition = Composition.load("study-1.json")
```

------------------------------------------------------------------------

# 33. Runtime interpretation of the JSON

Max sends a live hit:

``` text
/hit snare 0.82
```

Python constructs:

``` python
Hit(
    instrument="snare",
    velocity=0.82,
    timestamp=421.37
)
```

The engine queries:

``` python
state = composition.state_at(421.37)
```

and may obtain:

``` text
section = CONFLICT
autonomy = .71
density = .68
memory_depth = 5

allowed archetypes:
- Fragment
- Propagate
- Shadow
```

Then:

``` python
phrase = engine.respond(hit, state)
```

The resulting phrase might be:

``` python
Phrase(
    archetype="fragment",
    source="snare",
    events=[
        Event(0.000, "snare", 0.82),
        Event(0.041, "rim",   0.71),
        Event(0.103, "tom1",  0.59),
        Event(0.151, "ride",  0.48),
        Event(0.237, "metal", 0.31),
    ]
)
```

Python sends this to Max, which schedules and renders it.

------------------------------------------------------------------------

# 34. JSON can define competing layer weights

A section can explicitly define how strongly different systems influence generation:

``` json
{
  "id": "conflict",

  "allowed_archetypes": [
    "fragment",
    "propagate",
    "shadow"
  ],

  "rhythmic_trees": [
    "rt07",
    "rt11",
    "rt14"
  ],

  "constraints": {
    "max_polyphony": 8,
    "max_phrase_duration": 4.5,
    "minimum_human_dependency": 0.15
  },

  "layer_weights": {
    "rhythm": 1.0,
    "density": 0.7,
    "memory": 0.9,
    "topology": 0.5,
    "human_input": 0.4
  }
}
```

Earlier in the piece:

``` json
{
  "layer_weights": {
    "human_input": 1.0,
    "rhythm": 0.4,
    "memory": 0.0
  }
}
```

Later:

``` json
{
  "layer_weights": {
    "human_input": 0.3,
    "rhythm": 0.9,
    "memory": 1.0
  }
}
```

Thus the changing hierarchy of formal systems can itself be encoded in the score.

------------------------------------------------------------------------

# 35. JSON as a small compositional DSL

The JSON can describe not only values but relationships.

Example:

``` json
{
  "fragmentation_depth": {
    "source": "hit.velocity",
    "map": [0.0, 1.0, 1, 6]
  }
}
```

Meaning:

\[ velocity 0..1 `\rightarrow `{=tex}fragmentation depth 1..6 \]

Another example:

``` json
{
  "machine_density": {
    "combine": [
      "formal.density",
      "hit.velocity",
      "memory.activity"
    ],
    "weights": [0.5, 0.2, 0.3]
  }
}
```

At that point, the composition JSON begins to function as a small **domain-specific language for algorithmic composition**.

Python is the interpreter/execution engine.

------------------------------------------------------------------------

# 36. Simulated performance with MIDI

A fixed MIDI performance is an excellent development and testing method.

Architecture:

``` text
                    INPUT

        +-------------+-------------+
        |                           |
   live e-drums                  MIDI file
        |                           |
        +-------------+-------------+
                      |
              normalized Hit stream
                      |
                Python engine
                      |
             generated event stream
                      |
                     Max
                      |
                    audio
```

The Python engine should not care whether an event came from a live performer or a MIDI file.

Both become:

``` python
Hit(
    timestamp=12.351,
    pad="snare",
    velocity=0.76
)
```

This creates a deterministic test harness.

Without it, two variables change simultaneously:

1.  the performance changes;
2.  the algorithm changes.

With fixed MIDI:

``` text
same performance

parameter set A -> render A
parameter set B -> render B
parameter set C -> render C
```

Only the composition engine changes.

------------------------------------------------------------------------

# 37. Recommended test fixtures

## Tiny mapping fixture

Four or five events:

``` text
snare p
snare ff
tom mf
cymbal f
```

Use this to test:

-   pad mappings;
-   velocity mappings;
-   phrase selection;
-   OSC;
-   scheduling.

## Gesture fixture

10--20 seconds containing:

-   acceleration;
-   deceleration;
-   crescendo;
-   diminuendo;
-   pad trajectory;
-   pause;
-   delimiter.

Use this for:

-   segmentation;
-   feature extraction;
-   memory;
-   gesture-level response.

## Standard two-minute benchmark

Include deliberately varied situations:

-   sparse;
-   dense;
-   soft;
-   loud;
-   regular;
-   irregular;
-   accelerating;
-   decelerating;
-   repeated pad;
-   changing pads;
-   long silence;
-   several explicit gesture boundaries.

Keep this MIDI file permanently and use it as a regression test for the composition engine.

------------------------------------------------------------------------

# 38. Parameter exploration

The primary criterion for a composition remains:

> **Does it sound musically convincing?**

Formal elegance is not sufficient if the result is uninteresting.

However, evaluation can be divided into three levels.

## Musical evaluation

Ask:

-   Is the music compelling?
-   Is there direction?
-   Is there contrast?
-   Is recurrence recognizable?
-   Is pacing effective?
-   Is the density tiring or meaningful?
-   Do phrases have identities?
-   Does the piece avoid sounding like arbitrary generated percussion?

## System evaluation

Ask:

-   Can the listener perceive the relationship between human and machine?
-   Does a hard hit create a perceptibly stronger transformation?
-   Does Fragment remain recognizable when it returns?
-   Is machine autonomy perceptible?
-   Does remembered material sound related to earlier material?
-   Do conflicting layers produce an audible effect rather than only numerical differences?

## Formal evaluation

Ask:

-   Does the global trajectory work?
-   Do sections feel different for structural reasons?
-   Does the transition from dependence to autonomy make sense?
-   Does the memory section genuinely introduce recurrence?
-   Does the residue section sound like residue rather than merely reduced density?

------------------------------------------------------------------------

# 39. A/B testing

Use the same MIDI input and compare controlled variations.

Examples:

``` text
A: memory disabled
B: memory enabled
```

``` text
A: formal curve fixed
B: formal curve evolving
```

``` text
A: parametric layers aligned
B: parametric layers conflicting
```

``` text
A: velocity controls only loudness
B: velocity controls transformation energy
```

``` text
A: phrase generation ignores history
B: phrase generation uses short-term memory
```

Change one hypothesis at a time where possible.

------------------------------------------------------------------------

# 40. Parameter presets rather than exhaustive search

If Fragment has:

``` text
max_depth            2–7
branch_probability   .2–.9
time_compression     .3–1.2
instrument_spread    1–6
velocity_decay       .5–.95
```

the full parameter space becomes large quickly.

Instead of exhaustive search, define meaningful hypotheses/presets:

``` json
{
  "fragment_sparse": {
    "max_depth": 2,
    "branch_probability": 0.35,
    "instrument_spread": 2
  },

  "fragment_violent": {
    "max_depth": 6,
    "branch_probability": 0.85,
    "instrument_spread": 6
  },

  "fragment_focused": {
    "max_depth": 5,
    "branch_probability": 0.70,
    "instrument_spread": 1
  }
}
```

Render them against the same MIDI input and compare.

Blind listening can be useful when practical.

------------------------------------------------------------------------

# 41. Automatic metrics: descriptors, not quality scores

Useful automatic measurements include:

-   event density;
-   polyphony;
-   dynamic range;
-   instrument entropy;
-   average inter-onset interval;
-   IOI variance;
-   repetition rate;
-   memory reuse;
-   topological spread;
-   phrase duration;
-   number of concurrent processes;
-   percentage of machine events traceable to human input.

These can help explain why two versions sound different.

They should not be treated as an objective "musical quality" score.

The ear remains the final judge.

------------------------------------------------------------------------

# 42. Event logging and reproducibility

Python should save a complete event log.

Example:

``` json
{
  "source_hit": {
    "time": 42.18,
    "pad": "snare",
    "velocity": 0.82
  },

  "formal_state": {
    "section": "conflict",
    "autonomy": 0.71,
    "density": 0.64
  },

  "phrase": {
    "archetype": "fragment",
    "memory_source": 17,
    "events": []
  }
}
```

Benefits:

-   debug bad phrases;
-   reproduce performances;
-   compare engine versions;
-   analyze compositional behavior;
-   prepare diagrams/examples for papers;
-   trace how a human event became machine material.

For stochastic processes, also save random seeds.

------------------------------------------------------------------------

# 43. Suggested development loop

``` text
1. Compose mock human MIDI
        |
2. Run it through Python
        |
3. Save generated event log
        |
4. Render through Max
        |
5. Listen
        |
6. Change one compositional hypothesis
        |
7. Render again
        |
8. A/B compare
```

Once parameter sets behave consistently across several mock performances, test them with actual electronic drums.

------------------------------------------------------------------------

# 44. Max patch format and coding agents

Modern Max patch files (`.maxpat`) are essentially JSON documents describing:

-   boxes/objects;
-   patch cords;
-   object IDs;
-   inlet/outlet indices;
-   positions;
-   object text;
-   saved attributes;
-   subpatchers;
-   dependencies;
-   parameter metadata.

Therefore coding agents can generate and modify Max patches.

However, syntactically valid JSON does not guarantee a correct Max patch. Max itself should be treated as the validator:

``` text
agent writes .maxpat
        |
open in Max
        |
check Max Console
        |
test behavior
        |
fix
```

Prefer modular patches/abstractions:

``` text
midi-input.maxpat
gesture-history.maxpat
python-bridge.maxpat
event-scheduler.maxpat
percussion-voice.maxpat
sample-engine.maxpat
visual-engine.maxpat
```

Do not ask an agent to build the entire system as one enormous patch.

------------------------------------------------------------------------

# 45. Development-time versus performance-time generation

Two kinds of generation should be distinguished.

## Development-time

``` text
coding agent / script
       |
generate .maxpat
       |
open in Max
```

## Performance-time

``` text
Python composition engine
       |
OSC/events
       |
stable Max patch
       |
audio/visual output
```

Use development-time patch generation sparingly.

Use performance-time musical generation extensively.

The Max patch should eventually become stable infrastructure.

------------------------------------------------------------------------

# 46. Samples and synthesis

Samples are suitable for this system because the objective is not necessarily perfect acoustic simulation.

A hybrid percussion voice can use:

``` text
sample
+
resonator
+
noise
+
transient shaping
+
pitch shift
+
convolution
```

This creates a continuum:

``` text
realistic drum
      ->
processed drum
      ->
abstract percussion
```

The same composition can therefore move from recognizable instrumental sound toward electronic abstraction.

------------------------------------------------------------------------

# 47. Visuals with Jitter

Visuals can be integrated through Max/Jitter.

Recommended architecture:

``` text
E-DRUM
  |
 MAX
  |
  | MIDI/OSC
  v
PYTHON
  |
  +-- musical phrase
  +-- formal state
  +-- memory relationships
  +-- transformation state
  |
  v
 MAX
  +-------------------+
  |                   |
 MSP                 JITTER
  |                   |
audio               visuals
```

Python should not normally generate pixels or geometry.

It should send **semantic compositional information**.

Example:

``` json
{
  "gesture": 27,
  "archetype": "fragment",
  "energy": 0.81,
  "autonomy": 0.67,
  "density": 0.54,
  "memorySource": 11,
  "transformationDistance": 0.72,
  "topologicalSpread": 0.83
}
```

Jitter interprets this visually.

------------------------------------------------------------------------

# 48. Avoid generic audio visualization

Do not make every generated percussion hit produce a flashing object.

That tends toward:

``` text
347 hits = 347 visual flashes
```

which is closer to a conventional music visualizer than a composed audiovisual system.

Prefer different structural resolutions:

``` text
MUSIC                         VISUAL

individual hit        --->   usually nothing
human gesture         --->   visual object
phrase archetype      --->   visual behavior
memory recall         --->   return/transformation
formal state          --->   overall environment
machine autonomy      --->   visual independence
```

Audio and visuals can therefore be related without being redundant.

------------------------------------------------------------------------

# 49. Visualizing human/machine relationships

A human hit can introduce a simple visual object.

Machine fragmentation can recursively alter it:

``` text
HUMAN:

       ●

MACHINE:

       ●
     ·   ·
   · ·   · ·
 ·  · · ·  · ·
```

As machine autonomy increases, visual descendants can persist and evolve for longer without new human input.

This makes the macro-formal human/machine relationship visible.

------------------------------------------------------------------------

# 50. Visualizing conflicting layers

Independent musical parameters can control independent visual dimensions.

Example mapping:

``` text
rhythm       -> motion speed
density      -> number of objects
timbre       -> texture/shape complexity
topology     -> spatial displacement
memory       -> persistence/trails
energy       -> size
```

Because these processes are independent, visually contradictory behavior can occur.

For example:

-   fewer objects;
-   increasing movement speed;
-   increasing spatial separation;
-   longer persistence.

This is the visual analogue of non-aligned musical parameters.

------------------------------------------------------------------------

# 51. Visualizing machine memory

When a human gesture is stored, associate it with a visual structure.

When the gesture returns from memory, the visual form also returns but transformed.

Thus the audience may recognize recurrence even when the sound has changed significantly.

This is particularly suitable for the formal progression:

``` text
MEMORY -> CONFLICT -> RESIDUE
```

In the residue section, transformed visual traces of earlier gestures can remain after the performer stops.

------------------------------------------------------------------------

# 52. Continuous controllers

Electronic drums may provide more than note and velocity data.

Depending on hardware, useful input can include:

-   rim/center distinctions;
-   cymbal zones;
-   choke;
-   hi-hat openness;
-   pedal position;
-   positional sensing.

Continuous controllers can affect **latent system state**.

Example:

``` text
hi-hat pedal opens
       |
visual geometry becomes unstable
       |
snare hit
       |
structure fractures
       |
machine phrase begins
```

The performer therefore influences the system even before an attack occurs.

------------------------------------------------------------------------

# 53. One possible first complete piece

A practical first project could be a 7--11 minute solo electronic-percussion study.

Human resources:

``` text
kick
snare
2–3 toms
hi-hat
ride/crash
gesture delimiter
```

The live part remains relatively simple.

The machine uses:

``` text
RHYTHM
hierarchical proportional trees

PROCESS
Fragment / Converge / Propagate / Resonate / Shadow / Interrupt

ENERGY
derived partly from velocity

TOPOLOGY
kit-space trajectories

MEMORY
short-, medium- and long-term

FORM
Dependence -> Elaboration -> Memory -> Conflict -> Residue

CONFLICT
independent rhythmic, dynamic, timbral, topological and memory layers
```

The visuals operate mainly at gesture/process/formal level.

------------------------------------------------------------------------

# 54. Suggested implementation order

Do not build the complete system at once.

## Stage 1 --- MIDI acquisition

``` text
e-drum -> Max -> print note, velocity, timestamp
```

## Stage 2 --- Python bridge

``` text
e-drum -> Max -> OSC -> Python -> console
```

## Stage 3 --- return path

``` text
e-drum -> Max -> Python
                  |
             generated event
                  |
                  v
                 Max
                  |
              sample
```

## Stage 4 --- one archetype

Implement only `Fragment`.

One hit creates a deterministic generated phrase.

## Stage 5 --- fixed MIDI simulation

Create a small MIDI fixture and make live and simulated input normalize into the same `Hit` type.

## Stage 6 --- gesture segmentation

Add explicit delimiter and gesture objects.

## Stage 7 --- feature extraction

Add:

``` text
duration
density
IOI slope
velocity slope
topological distance
```

## Stage 8 --- rhythmic trees

Add hierarchical proportional subdivision.

## Stage 9 --- formal state

Add sections and one or two formal curves.

## Stage 10 --- additional archetypes

Add Propagate, Shadow, Resonance, etc.

## Stage 11 --- memory

Begin with literal short-term recall, then partial/transformed recall.

## Stage 12 --- conflicting layers

Separate rhythm, density, dynamics, topology, timbre and memory processes.

## Stage 13 --- constraints

Add hard limits and soft preferences.

## Stage 14 --- visual layer

Add Jitter after the musical system is understandable.

------------------------------------------------------------------------

# 55. Minimal conceptual Python model

A clean object model might eventually include:

``` text
Composition
CompositionState
Section
FormalCurve

Hit
Gesture
GestureFeatures
GestureMemory

RhythmicTree
Phrase
Event

PhraseArchetype
FragmentGenerator
ConvergeGenerator
PropagateGenerator
ResonateGenerator
ShadowGenerator
InterruptGenerator

Transformation
TransformationMatrix

Constraint
ConstraintSet
Candidate
CandidateEvaluator

PerformanceInput
MidiFileInput
OscLiveInput

EventOutput
OscMaxOutput
EventLogger
```

Avoid building all of these abstractions before they are needed. They are a possible destination, not a mandatory initial architecture.

------------------------------------------------------------------------

# 56. Central compositional principles

The most important principles from the discussion can be reduced to the following.

## 56.1 Separate compositional and performance complexity

The machine can realize detail that the human does not physically perform.

## 56.2 The human must remain structurally consequential

The drummer should not merely press buttons to launch backing tracks.

Timing, force, pad choice, gesture shape and phrase boundaries should materially alter the realization.

## 56.3 Precompose systems, not necessarily events

Precompose:

-   formal trajectories;
-   process families;
-   rhythmic trees;
-   transformations;
-   constraints;
-   memory behavior;
-   layer priorities.

Allow live input to instantiate them.

## 56.4 Macro form governs local meaning

The same input should have different consequences in different sections.

## 56.5 Prefer independent parameter streams

Rhythm, density, dynamics, timbre, topology and memory do not need to align.

## 56.6 Conflict is compositional material

Do not automatically reconcile all independent systems into one smooth gesture.

## 56.7 Memory should transform, not merely repeat

Recall relationships and features, not only exact MIDI.

## 56.8 Gesture classification is optional

Continuous deterministic features are often more useful than categorical labels.

## 56.9 Test composition deterministically

Use fixed MIDI input, logs, repeatable seeds and A/B renders.

## 56.10 Sound remains the final criterion

Metrics, formal systems and mathematical elegance are tools. They do not replace musical judgment.

------------------------------------------------------------------------

# 57. Questions that remain open and should be answered through composition

Several choices should not be decided theoretically in advance. They should be tested through actual pieces.

1.  How much of the human gesture must remain audible in the machine response for causality to be perceptible?
2.  At what point does machine autonomy become musically interesting rather than arbitrary?
3.  How many phrase archetypes are enough to create identity without making the grammar obvious?
4.  How much rhythmic hierarchy can listeners perceive?
5.  Which gesture features produce useful musical transformations?
6.  Is explicit gesture delimitation musically convincing in performance?
7.  Should delimiters be audible or silent?
8.  How long should machine memory persist?
9.  Which properties survive transformation strongly enough to make memory recognizable?
10. How many conflicting parameter layers can operate before the result becomes perceptually undifferentiated?
11. Should the performer be able to interrupt machine processes?
12. Should some machine processes become impossible to stop?
13. Should section transitions be time-based, event-based, performer-triggered or hybrid?
14. How much randomness is actually necessary?
15. Can most of the system remain deterministic and still produce sufficiently varied performances?
16. How should visual memory correspond to musical memory without merely illustrating it?
17. Does the final piece communicate its human/machine formal trajectory without explanatory notes?

These are not implementation defects. They are compositional questions.

------------------------------------------------------------------------

# 58. Compact system summary

The complete idea can be summarized as:

``` text
                       COMPOSITION.JSON
                              |
                     precomposed formal model
                              |
                              v
ELECTRONIC DRUMS ---> MAX ---> PYTHON
       |                       |
       |                  analyze gesture
       |                  determine state
       |                  consult memory
       |                  run processes
       |                  negotiate conflicts
       |                  apply constraints
       |                       |
       |                       v
       +<------ MAX <----- generated phrase
                 |
          +------+------+
          |             |
         MSP          JITTER
          |             |
        AUDIO         VISUALS
```

Development/testing mode replaces the electronic drums with a fixed MIDI performance:

``` text
TEST.MID
   |
normalized hit/gesture stream
   |
Python composition engine
   |
event log + Max rendering
   |
A/B listening
```

The artistic hierarchy is:

``` text
MACRO FORM
    |
FORMAL STATE
    |
COMPETING PARAMETRIC LAYERS
    |
PHRASE ARCHETYPE
    |
HUMAN GESTURE
    |
ALGORITHMIC REALIZATION
    |
AUDIO / VISUAL OUTPUT
```

The essential aesthetic proposition is:

> **A simple live percussion performance supplies structural, temporal and energetic information. A precomposed algorithmic system interprets that information according to the current formal state, memory and multiple partially independent parametric processes, producing a complex audiovisual superstructure whose relationship to the performer changes over the course of the piece.**
