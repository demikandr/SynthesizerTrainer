# SynthesizerTrainer - Design Document

## Project Overview

**Goal:** iOS app for learning synthesizer sound design through interactive sound matching challenges.

**Core Concept:** Users listen to target sounds and recreate them using 3 simple synthesizer controls with real-time visual feedback.

## MVP Features

### Audio Engine
- Single oscillator with waveform selection (sine, square, sawtooth, triangle)
- Low-pass filter with cutoff frequency control
- Simple amplitude envelope (attack/release)
- Real-time audio synthesis using AVAudioEngine

### User Interface
- Play button for target sound
- Play button for current synthesized sound
- Three control sliders (waveform, filter cutoff, envelope)
- Basic waveform visualization display
- Simple "match quality" indicator

### Sound Library
- 10 preset target sounds
- Progressive difficulty (simple waveforms → filtered sounds → enveloped sounds)
- Hardcoded audio files or parameter sets

### Core Functionality
- Audio playback and synthesis
- Basic sound comparison algorithm
- Parameter adjustment with real-time feedback

## Class Structure

### Audio Layer
- `AudioEngine`: Core audio synthesis and playback management
- `Synthesizer`: Single-oscillator synth with filter and envelope
- `SoundMatcher`: Compares target vs current sound similarity
- `TargetSound`: Model for target sounds with parameters/audio data

### UI Layer
- `ContentView`: Main app screen with controls and visualization
- `SynthControlView`: Individual parameter control sliders
- `WaveformView`: Real-time audio waveform display
- `SoundLibraryView`: Target sound selection interface

### Data Layer
- `SoundLibrary`: Manages collection of target sounds
- `AppState`: Global app state and user progress
- `AudioSettings`: Audio configuration and parameters

## Class Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                             │
├─────────────────────────────────────────────────────────────┤
│  ContentView                                                │
│       │                                                     │
│       ├─── SynthControlView ──┐                            │
│       ├─── WaveformView       │                            │
│       └─── SoundLibraryView   │                            │
│                               │                            │
└───────────────────────────────┼────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  AppState ◄─────────────────── AudioSettings               │
│     │                              │                       │
│     └─── SoundLibrary               │                       │
│              │                      │                       │
│              └─── TargetSound       │                       │
│                                     │                       │
└─────────────────────────────────────┼───────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────┐
│                     Audio Layer                             │
├─────────────────────────────────────────────────────────────┤
│  AudioEngine                                                │
│       │                                                     │
│       ├─── Synthesizer                                     │
│       ├─── SoundMatcher                                    │
│       └─── TargetSound (playback)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Key Relationships:
• ContentView owns and orchestrates all UI components
• AppState serves as central state manager for the entire app
• AudioEngine manages all audio operations and synthesis
• SoundMatcher compares audio from Synthesizer with TargetSound
• UI controls flow through AppState to AudioEngine parameters
• Real-time audio data flows from AudioEngine to WaveformView
```

## Feature Implementation List

### Foundation
1. ✅ Set up iOS project with audio permissions
2. ✅ Implement basic AVAudioEngine setup
3. ✅ Create single oscillator audio generation
4. ✅ Add waveform selection (4 wave types)
5. ✅ Implement low-pass filter processing
6. Add simple envelope (attack/release)
7. Create real-time parameter control system

### Audio System
8. Implement audio buffer management
9. Add target sound playback system
10. Create basic sound comparison algorithm
11. Implement audio visualization (waveform display)
12. Add audio session management for iOS

### User Interface
13. Design main app layout in SwiftUI
14. Create parameter control sliders
15. Implement play/stop buttons for target and synth
16. Add waveform visualization view
17. Create sound selection interface
18. Implement basic match quality indicator

### Content and Logic
19. Create 10 target sounds (audio files or parameter sets)
20. Implement sound library management
21. Add basic scoring/matching logic
22. Create app state management
23. Implement sound progression system

### Integration and Polish
24. Connect UI controls to audio parameters
25. Add real-time visual feedback
26. Implement app lifecycle management
27. Add basic error handling
28. Performance optimization for real-time audio
29. Basic testing and debugging
30. App icon and launch screen