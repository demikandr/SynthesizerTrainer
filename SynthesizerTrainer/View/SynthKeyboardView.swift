import SwiftUI
import AudioKit
import Keyboard

struct SynthKeyboardView<T: SynthEngineProtocol>: View {
    @ObservedObject var synthEngine: T
    @State private var pressedKeys: Set<MIDINoteNumber> = []
    
    var body: some View {
        VStack {
            Keyboard(layout: .piano(pitchRange: Pitch(intValue:49) ... Pitch(intValue: 72)),
                     noteOn: {(pitch, _) in synthEngine.play(note: MIDINoteNumber(pitch.midiNoteNumber))},
                     noteOff: {(pitch) in synthEngine.stop(note: MIDINoteNumber(pitch.midiNoteNumber))})
            .frame(height: 150)
            .padding()
            
            Text("Play notes on the keyboard")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SynthKeyboardView(synthEngine: SimpleSynthEngineImpl())
}
