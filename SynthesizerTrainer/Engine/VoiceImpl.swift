import SwiftUI
import AudioKit
import SoundpipeAudioKit

// A single voice of our polyphonic synthesizer.
// It contains an oscillator and an amplitude envelope.
class VoiceImpl: VoiceProtocol {
    private var oscillator: DynamicOscillator
    private var envelope: AmplitudeEnvelope
    
    private var isPlaying = false  // Track playing state manually

    // Check if the voice is currently active
    var isActive: Bool {
        return isPlaying
    }
    
    func setWaveform(_ waveform: WaveformType) { oscillator.setWaveform(waveform.audioKitTable)
    }

    required init() {
        // Initialize the oscillator and envelope
        oscillator = DynamicOscillator()
        envelope = AmplitudeEnvelope(oscillator)

        // Start the oscillator but keep the volume at 0 until a note is played
        oscillator.start()
        oscillator.amplitude = 0
    }
    
    var outputNode: Node {
        get {
            return envelope
        }
    }
    
    var note: MIDINoteNumber = MIDI_NOTE_NUMBER_A4

    // Start playing a note with a specific MIDI note number and velocity
    func start(note: MIDINoteNumber, velocity: MIDIVelocity) {
        self.note = note
        oscillator.frequency = note.midiNoteToFrequency()
        
        // Use velocity to control the amplitude.
        let amplitude = Float(velocity) / 127.0
        oscillator.amplitude = amplitude * 0.7
        
        // Open the envelope gate to start the ADSR sequence
        envelope.openGate()
        isPlaying = true  // Mark as playing
    }
    
    // Stop playing the note (begin the release phase of the envelope)
    func stop() {
        // Close the gate to trigger the release phase
        envelope.closeGate()
        
        // Schedule setting isPlaying to false after release completes
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(envelope.releaseDuration)) {
            self.isPlaying = false
            self.oscillator.amplitude = 0
        }
    }
}
