import Foundation
import AVFoundation

struct TargetSound {
    let id: String
    let name: String
    let description: String
    let difficulty: Int // 1-5 scale
    
    // Target parameters for sound recreation
    let waveform: WaveformType
    let frequency: Float
    let filterCutoff: Float
    let amplitude: Float
    let attackTime: Float
    let releaseTime: Float
    
    init(id: String, name: String, description: String, difficulty: Int = 1,
         waveform: WaveformType = .sine, frequency: Float = 440.0,
         filterCutoff: Float = 1000.0, amplitude: Float = 0.3,
         attackTime: Float = 0.1, releaseTime: Float = 0.3) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.waveform = waveform
        self.frequency = frequency
        self.filterCutoff = filterCutoff
        self.amplitude = amplitude
        self.attackTime = attackTime
        self.releaseTime = releaseTime
    }
}

class TargetSoundPlayer: ObservableObject {
    private var targetSynthesizer: Synthesizer?
    private let engine = AVAudioEngine()
    
    @Published var isPlaying = false
    
    init() {
        setupTargetPlayer()
    }
    
    private func setupTargetPlayer() {
        targetSynthesizer = Synthesizer()
        
        guard let targetSynthesizer = targetSynthesizer else { return }
        
        // Use mono format for target sounds to distinguish from main synthesizer
        let audioFormat = AVAudioFormat(
            standardFormatWithSampleRate: 44100.0,
            channels: 1
        )
        
        engine.attach(targetSynthesizer.sourceNode)
        engine.connect(targetSynthesizer.sourceNode, to: engine.mainMixerNode, format: audioFormat)
        
        // Lower volume for target sounds
        engine.mainMixerNode.outputVolume = 0.6
        
        do {
            engine.prepare()
            try engine.start()
        } catch {
            print("Failed to start target sound engine: \(error)")
        }
    }
    
    func playTargetSound(_ targetSound: TargetSound, duration: TimeInterval = 2.0) {
        guard let targetSynthesizer = targetSynthesizer else { return }
        
        // Configure synthesizer with target parameters
        targetSynthesizer.setWaveform(targetSound.waveform)
        targetSynthesizer.setFrequency(targetSound.frequency)
        targetSynthesizer.setFilterCutoff(targetSound.filterCutoff)
        targetSynthesizer.setAmplitude(targetSound.amplitude)
        targetSynthesizer.setAttackTime(targetSound.attackTime)
        targetSynthesizer.setReleaseTime(targetSound.releaseTime)
        
        // Start playing
        targetSynthesizer.start()
        isPlaying = true
        
        // Stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            targetSynthesizer.stop()
            self?.isPlaying = false
        }
    }
    
    func stopTargetSound() {
        targetSynthesizer?.stop()
        isPlaying = false
    }
    
    deinit {
        engine.stop()
    }
}