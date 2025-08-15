import Foundation

class SoundLibrary: ObservableObject {
    @Published var targetSounds: [TargetSound] = []
    @Published var currentTargetSound: TargetSound?
    
    init() {
        loadTargetSounds()
        currentTargetSound = targetSounds.first
    }
    
    private func loadTargetSounds() {
        targetSounds = [
            // Level 1 - Basic Waveforms
            TargetSound(
                id: "sine_440",
                name: "Pure Sine",
                description: "A simple sine wave at A4",
                difficulty: 1,
                waveform: .sine,
                frequency: 440.0,
                filterCutoff: 5000.0,
                amplitude: 0.4,
                attackTime: 0.05,
                releaseTime: 0.2
            ),
            
            TargetSound(
                id: "square_330",
                name: "Square Wave",
                description: "Square wave with harmonics",
                difficulty: 2,
                waveform: .square,
                frequency: 330.0,
                filterCutoff: 2000.0,
                amplitude: 0.3,
                attackTime: 0.02,
                releaseTime: 0.1
            ),
            
            TargetSound(
                id: "sawtooth_220",
                name: "Sawtooth Bass",
                description: "Rich sawtooth wave",
                difficulty: 2,
                waveform: .sawtooth,
                frequency: 220.0,
                filterCutoff: 1500.0,
                amplitude: 0.35,
                attackTime: 0.08,
                releaseTime: 0.25
            ),
            
            // Level 2 - Filtered Sounds
            TargetSound(
                id: "filtered_square",
                name: "Muffled Square",
                description: "Square wave with low-pass filtering",
                difficulty: 3,
                waveform: .square,
                frequency: 440.0,
                filterCutoff: 800.0,
                amplitude: 0.4,
                attackTime: 0.1,
                releaseTime: 0.3
            ),
            
            TargetSound(
                id: "bright_triangle",
                name: "Bright Triangle",
                description: "Triangle wave with high cutoff",
                difficulty: 3,
                waveform: .triangle,
                frequency: 550.0,
                filterCutoff: 3000.0,
                amplitude: 0.45,
                attackTime: 0.05,
                releaseTime: 0.15
            ),
            
            // Level 3 - Complex Envelopes
            TargetSound(
                id: "slow_attack_sine",
                name: "Slow Attack",
                description: "Sine wave with slow attack",
                difficulty: 4,
                waveform: .sine,
                frequency: 440.0,
                filterCutoff: 2500.0,
                amplitude: 0.5,
                attackTime: 0.5,
                releaseTime: 0.2
            ),
            
            TargetSound(
                id: "quick_pluck",
                name: "Quick Pluck",
                description: "Fast attack, quick release",
                difficulty: 4,
                waveform: .sawtooth,
                frequency: 660.0,
                filterCutoff: 1200.0,
                amplitude: 0.4,
                attackTime: 0.01,
                releaseTime: 0.05
            ),
            
            // Level 4 - Advanced Combinations
            TargetSound(
                id: "dark_bass",
                name: "Dark Bass",
                description: "Low-frequency with heavy filtering",
                difficulty: 5,
                waveform: .square,
                frequency: 110.0,
                filterCutoff: 300.0,
                amplitude: 0.6,
                attackTime: 0.15,
                releaseTime: 0.4
            ),
            
            TargetSound(
                id: "bright_lead",
                name: "Bright Lead",
                description: "High-frequency cutting lead",
                difficulty: 5,
                waveform: .sawtooth,
                frequency: 880.0,
                filterCutoff: 4000.0,
                amplitude: 0.35,
                attackTime: 0.02,
                releaseTime: 0.1
            ),
            
            TargetSound(
                id: "smooth_pad",
                name: "Smooth Pad",
                description: "Gentle triangle with medium filtering",
                difficulty: 5,
                waveform: .triangle,
                frequency: 330.0,
                filterCutoff: 1800.0,
                amplitude: 0.3,
                attackTime: 0.3,
                releaseTime: 0.6
            )
        ]
    }
    
    func selectTargetSound(_ sound: TargetSound) {
        currentTargetSound = sound
    }
    
    func getTargetSoundsByDifficulty(_ difficulty: Int) -> [TargetSound] {
        return targetSounds.filter { $0.difficulty == difficulty }
    }
    
    func getNextTargetSound() -> TargetSound? {
        guard let current = currentTargetSound,
              let currentIndex = targetSounds.firstIndex(where: { $0.id == current.id }),
              currentIndex + 1 < targetSounds.count else {
            return nil
        }
        
        let nextSound = targetSounds[currentIndex + 1]
        currentTargetSound = nextSound
        return nextSound
    }
    
    func getPreviousTargetSound() -> TargetSound? {
        guard let current = currentTargetSound,
              let currentIndex = targetSounds.firstIndex(where: { $0.id == current.id }),
              currentIndex > 0 else {
            return nil
        }
        
        let previousSound = targetSounds[currentIndex - 1]
        currentTargetSound = previousSound
        return previousSound
    }
}