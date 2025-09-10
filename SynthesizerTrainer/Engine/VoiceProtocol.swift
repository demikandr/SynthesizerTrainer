import AudioKit
import SoundpipeAudioKit

// A single voice for both polyphonic and monophonic synthesizer.
// It contains an oscillator and an amplitude envelope.
protocol VoiceProtocol {

    // Initializer
    init()
    
    // Guaranteed to not change after init()
    var outputNode: Node { get }
    
    var note: MIDINoteNumber { get }
    
    // MARK: Playing interface
    // Start playing a note with a specific MIDI note number and velocity
    func start(note: MIDINoteNumber, velocity: MIDIVelocity)
    
    // Stop playing the note (begin the release phase of the envelope)
    func stop()
    
    // MARK: Settings interface
    func setWaveform(_ waveform: WaveformType)
    
}
