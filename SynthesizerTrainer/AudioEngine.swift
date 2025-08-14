import AVFoundation
import Foundation

class AudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private var synthesizer: Synthesizer?
    
    @Published var isPlaying = false
    
    init() {
        setupAudioSession()
        setupEngine()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupEngine() {
        synthesizer = Synthesizer()
        
        guard let synthesizer = synthesizer else { return }
        
        engine.attach(synthesizer.sourceNode)
        engine.connect(synthesizer.sourceNode, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func startSynthesizer() {
        synthesizer?.start()
        isPlaying = true
    }
    
    func stopSynthesizer() {
        synthesizer?.stop()
        isPlaying = false
    }
    
    func setWaveform(_ waveform: WaveformType) {
        synthesizer?.setWaveform(waveform)
    }
    
    func setFilterCutoff(_ cutoff: Float) {
        synthesizer?.setFilterCutoff(cutoff)
    }
    
    func setAmplitude(_ amplitude: Float) {
        synthesizer?.setAmplitude(amplitude)
    }
}