import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

class SynthEngineImpl: SynthEngineProtocol {
    private let engine = AudioEngine()
    private var oscillator: Oscillator?
    private var currentNote: Float?
    private var logger = Logger()
    
    @Published var waveform: WaveformType = .sine {
        didSet {
            recreateOscillator()
        }
    }
    @Published var isEngineRunning = false
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        createOscillator()
        
        do {
            try engine.start()
            isEngineRunning = true
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func createOscillator() {
        oscillator = Oscillator(waveform: waveform.audioKitTable)
        oscillator?.amplitude = 0.3
        engine.output = oscillator
    }
    
    private func recreateOscillator() {
        logger.info("recreating Oscilator")
        let wasPlaying = currentNote != nil
        let playingNote = currentNote
        
        oscillator?.stop()
        createOscillator()
        
        if wasPlaying, let note = playingNote {
            play(pitch: note)
        }
    }
    
    func updateWaveform(_ newWaveform: WaveformType) {
        waveform = newWaveform
    }
    
    func play(pitch: Float) {
        guard let oscillator = oscillator else { return }
        
        oscillator.frequency = pitch
        oscillator.start()
        currentNote = pitch
    }
    
    func stop(pitch: Float) {
        guard let oscillator = oscillator else { return }
        
        if currentNote == pitch {
            oscillator.stop()
            currentNote = nil
        }
    }
    
    func stopAll() {
        oscillator?.stop()
        currentNote = nil
    }
}
