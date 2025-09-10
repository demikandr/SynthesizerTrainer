import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

// The main class that manages all the voices and handles MIDI events.
class PolyphonicSynthEngineImpl<T: VoiceProtocol>: SynthEngineProtocol {
    // MARK: Published Parameters
    
    @Published var waveform: WaveformType = .sine { didSet { onSetWaveform() } }
    
    // MARK: SynthEngineProtocol Conformance
    
    func play(note: MIDINoteNumber) {
        // Use a default velocity as the protocol doesn't provide one.
        let velocity: MIDIVelocity = 100
        
        let voice = getVoicePlayingNote(note) ?? getNextVoice()
        voice.start(note: note, velocity: velocity)
    }

    func stop(note: MIDINoteNumber) {
        if let voiceToStop = getVoicePlayingNote(note) {
            voiceToStop.stop()
        }
    }
    
    func updateWaveform(_ newWaveform: WaveformType) {
        // This function just sets the property, which then triggers the didSet observer.
        self.waveform = newWaveform
    }
    
    // MARK: Private members and methods

    private let engine = AudioEngine()
    private let mixer = Mixer()
    // A pool of voices. The number of voices determines the polyphony.
    private var voices: [VoiceProtocol] = []
    private var nextVoiceIndex: Int = 0
    
    init() {
        // Create the pool of synth voices
        let polyphony: Int = 8 // We can play up to 8 notes at once
        for _ in 0..<polyphony {
            let voice = T()
            voices.append(voice)
            mixer.addInput(voice.outputNode)
        }
        // Set the initial parameters for the voices
        onSetWaveform()
        
        // Set the engine's output and start it
        engine.output = mixer
        do {
            try engine.start()
        } catch {
            Log("AudioEngine failed to start. Error: \(error)", type: .error)
        }
    }
    
    private func getVoicePlayingNote(_ note: MIDINoteNumber) -> VoiceProtocol? {
        return voices.first(where: { $0.note == note })
    }
    
    // Returns a voice that is most likely to be currently unused.
    private func getNextVoice() -> VoiceProtocol {
        // If there is an unused yet voice, then return i
        // Else if there is a voice that is stopped, return the voice with the earliest stop
        // Else return a voice with the earliest start
        // TODO: implement the logic above
        
        // Return the next voice from the array
        let nextVoice = voices[nextVoiceIndex]
        nextVoiceIndex = (nextVoiceIndex + 1) % voices.count
        return nextVoice
        
    }
    
    private func onSetWaveform() {
        // This is the single source of truth for updating the voices' waveform.
        voices.forEach { $0.setWaveform(waveform) }
    }
}
