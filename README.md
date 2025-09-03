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

## Implementation Plan for Exercise View Components

### Phase 1: Synth Parameters Section
1. **Create parameter models**
   - Define data models for each synth parameter type
   - Implement Observable properties for real-time updates
   - Add parameter validation and constraints

2. **Build individual parameter views**
   - **BasicWaveView**: Waveform selector (sine, square, saw, triangle)
   - **EnvelopeView**: ADSR controls with visual envelope display
   - **FiltersView**: Filter type selector and cutoff/resonance controls
   - **LFOView**: Rate, depth, and destination controls

3. **Create SynthParamsContainerView**
   - Implement tab-based navigation between parameter sections
   - Add smooth transitions between tabs
   - Ensure parameter changes are immediately reflected in sound

4. **Connect to SynthEngine**
   - Bind UI controls to SynthEngine published properties
   - Implement bidirectional data flow
   - Add real-time parameter value display

### Phase 2: Keyboard Component
1. **Build KeyboardView**
   - Create piano keyboard layout using AudioKitUI components
   - Implement touch/click handling for note triggering
   - Add visual feedback for pressed keys

2. **Implement note handling**
   - Connect keyboard to SynthEngine play/stop methods
   - Add polyphonic support if required
   - Implement velocity sensitivity

3. **Add keyboard features**
   - Octave shift controls
   - Note labels display toggle
   - Keyboard size adjustment for different screen sizes

### Phase 3: Integration into Exercise View
1. **Create ExerciseViewModel**
   - Manage state for all exercise components
   - Handle communication between components
   - Implement exercise flow logic

2. **Assemble ExerciseView**
   - Stack all components vertically
   - Add proper spacing and padding
   - Implement scroll view if needed for smaller screens

3. **Connect components**
   - Wire up target sound playback
   - Sync keyboard and parameter changes to sound output
   - Add exercise state management

4. **Add exercise controls**
   - Implement "Play Target" button functionality
   - Add "Submit" button with validation
   - Create reset functionality

### Phase 4: Sound Visualizer Component
1. **Create WaveformProvider utility**
   - Implement AudioKit Node tap for audio output capture
   - Create buffer management for real-time waveform data
   - Add frequency normalization to stabilize visualization

2. **Build WaveformVisualizerView**
   - Create SwiftUI view with AudioKitUI waveform components
   - Implement real-time waveform rendering
   - Add styling to match the app design
   - Ensure responsive layout for different screen sizes

3. **Integrate with audio pipeline**
   - Connect WaveformProvider to SynthEngine output
   - Add support for visualizing both target and user sounds
   - Implement smooth transitions between sound sources

### Phase 5: Testing and Polish
1. **Test audio pipeline**
   - Verify low-latency response
   - Test parameter smoothing
   - Ensure no audio glitches

2. **UI/UX refinement**
   - Add animations for parameter changes
   - Implement haptic feedback where appropriate
   - Polish visual design and transitions

3. **Performance optimization**
   - Profile and optimize waveform rendering
   - Minimize UI redraws
   - Optimize memory usage for audio buffers

## Theory view

This is an intermission section between excercies that provides theoretical background to the upcoming excercise.

*Mock is to be created*

# Data models

*To be defined after I am done with Excercise view*

# Sound comparison

There are basically 2 ways to compare the synth sound to the target sound: by comparing params and by comparing the real sound. The former is simpler, but can miss when a sound is reproduced correctly but using a different set of params. The latter is more complicated and is hard to use when we need to take into consideration how sound changes with time (envelope, LFO). 

We will implement the sound comparison by comparing params, but the comparator should be abstracted behind a protocol so that we can experiment with substituting it with another comparator.

