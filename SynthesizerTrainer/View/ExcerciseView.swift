import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

// TODO: add some visualization for Synth initialization as it is slow for PolyphonicSynthEngine
struct ExcerciseView: View {
    @StateObject var synthEngine = SimpleSynthEngineImpl()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("SynthEngine Test")
                .font(.largeTitle)
                .padding()
            
            SynthParamsView(synthEngine: synthEngine)
            SynthKeyboardView(synthEngine: synthEngine)
        }
    }
    
}

#Preview {
    ExcerciseView()
}
