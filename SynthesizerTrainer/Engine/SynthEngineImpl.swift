import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

class SynthEngineImpl: SynthEngineProtocol {
    private let engine = AudioEngine()
    private var oscillator: Oscillator?
    private var currentNote: MIDINoteNumber?
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
            play(note: note)
        }
    }
    
    func updateWaveform(_ newWaveform: WaveformType) {
        waveform = newWaveform
    }
    
    func play(note: MIDINoteNumber) {
        guard let oscillator = oscillator else { return }
        
        oscillator.frequency = note.midiNoteToFrequency()
        oscillator.start()
        currentNote = note
    }
    
    func stop(note: MIDINoteNumber) {
        guard let oscillator = oscillator else { return }
        
        if currentNote == note {
            oscillator.stop()
            currentNote = nil
        }
    }
}
