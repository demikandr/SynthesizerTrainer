# Design doc for Synthesizer Trainer

# Objective

Create an app that teaches sound design. User completes a series of lessons. In each lesson the user is present with a target sound and a simple synthesizer. They can tweak various knobs of the synthesizer to reproduce the target sound. The base course progressively covers different parts of synth: basic wave, filters, envelope, LFO. The follow up courses cover creation of different popular sounds.  
![][image1]

# Lessons

Basics

- Basic wave, obertones and frequences  
- Envelope, punchy sounds vs ambient pads  
- Filters, LPF  
- LFO: tremolo (volume)


Basics practice

- Punchy lead  
- Ambient pads  
- Vibrating Leads

Basics 2 

- Noise, sub-Oscilator, maybe 2 basic waveforms, low and high Octaves  
- Envelope: nothing new here, but let’s create hi-hat  
- Filters: HPF, BPF, notch  
- LFO: sweep (filter), vibration (frequency)

Basics 2 practice

- Punchy bass  
-   
- 

Step-by-step: 808 bass

- basic wave  
- envelope  
- Filters  
- LFO

Step-by-step: other popular sound

- … \<same structure as above\>...  
- …

# Architecture

We write the app in Swift using SwiftUI. We rely on AudioKit and AudioKitUI for implementing synthesizer logic and visualization.

For managing sound we would create the following objects:

* **`SynthEngine` (instead of `SynthService`)**: This object should directly wrap the AudioKit synthesizer node. It should expose `@Published` properties for each synthesizer parameter in a way that makes them easy to use in the corresponding AudioKitUI component. It should also has an interaction point for playing notes with `play(pitch)` and \`stop(pitch)\` public methods.  
* **`WaveformProvider`**: This should be a simple utility that takes an AudioKit `Node` as input and generates waveform data for visualization. It shouldn't need to know anything about the `SynthEngine` itself, only how to tap into its audio output.  
* **`LessonEngine`**: Introduce a new `ObservableObject` to manage the state of the current exercise. It would hold the target parameters, calculate the score, and track the user's current synth settings for comparison.  
* Several ViewModels that correspond to individual sections of the ExcerciesView

Each view, each section of each view should be a separate swift view class. Their file and directory hierarchy should correspond to the view hierarchy. The logic should be coupled to the view using MVVM pattern.

# UI

In this section I describe the entire UI of the app. Note that albeit I list many views here, for now I am focusing on implementing Excercise view only. 

We will use Model-View-ViewModel pattern.

## Excercise view

Excercise view consists of 5 sections, all stacked together on one screen:

- Target sound  
- Sound visualizer  
- Synth params  
- Keyboard  
- “Submit” button

Sound visualizer visualizes the currently played sound, regardless of whether it is the target sound or sound from the synth. It pictures the soundwave. It should when possible picture it in a way that it doesn’t move to the left or to the right (aka adjusted by the note frequency somehow).

Synth params section has several sections, user can switch between them. The synth params sections are:

- Basic wave  
- Envelope  
- Filters  
- LFO

![][image1]

## Excercise result view

Excercise result view plays the target sound, then plays the sound from synth, compares them and suggests which params to change. Optionally it also suggests which parameters should yet be tweaked (the suggestions require clarification before implementation).

*Mock is to be created*

## Lesson selector view

Lesson selector view allow to select the module and lesson. You can select the latest non-completed lesson or any of the completed lessons. Other lessons are not visible.

*Mock is to be created*

## Implementation Plan for Exercise View Components (Vertical Approach)

### Phase 1: Basic Synth End-to-End
1. **Create SynthEngine with basic wave only**
   - AudioKit synthesizer node with basic waveform parameter
   - play(pitch) and stop(pitch) methods

2. **Build BasicWaveView**  
   - Simple waveform selector (sine, square, saw, triangle)
   - Connected to SynthEngine

3. **Build KeyboardView**
   - Piano keyboard using AudioKitUI
   - Connected to SynthEngine play/stop methods

4. **Create basic ExerciseView**
   - Stack BasicWaveView and KeyboardView vertically
   - Basic "Play Target" button (placeholder)

### Phase 2: Add Envelope Parameters
1. **Extend SynthEngine with envelope**
   - Add ADSR parameters to synthesizer

2. **Build EnvelopeView**
   - ADSR controls with visual envelope display
   - Add to SynthParamsContainerView with tabs

3. **Update ExerciseView**
   - Replace BasicWaveView with SynthParamsContainerView

### Phase 3: Add Filters and LFO
1. **Extend SynthEngine with filters and LFO**
   - Add filter and LFO parameters

2. **Build FiltersView and LFOView**
   - Filter type selector and cutoff/resonance controls
   - LFO rate, depth, and destination controls

3. **Complete SynthParamsContainerView**
   - All four parameter tabs with smooth transitions

### Phase 4: Sound Visualizer
1. **Create WaveformProvider and WaveformVisualizerView**
   - Real-time waveform rendering
   - Connect to SynthEngine output

2. **Add to ExerciseView**
   - Insert visualizer between target controls and synth params

### Phase 5: Exercise Logic and Polish
1. **Add LessonEngine**
   - Target sound management and score calculation

2. **Complete exercise controls**
   - Functional "Play Target" and "Submit" buttons
   - Exercise state management

3. **UI polish and testing**
   - Animations, performance optimization, thorough testing

## Theory view

This is an intermission section between excercies that provides theoretical background to the upcoming excercise.

*Mock is to be created*

# Data models

*To be defined after I am done with Excercise view*

# Sound comparison

There are basically 2 ways to compare the synth sound to the target sound: by comparing params and by comparing the real sound. The former is simpler, but can miss when a sound is reproduced correctly but using a different set of params. The latter is more complicated and is hard to use when we need to take into consideration how sound changes with time (envelope, LFO). 

We will implement the sound comparison by comparing params, but the comparator should be abstracted behind a protocol so that we can experiment with substituting it with another comparator.

