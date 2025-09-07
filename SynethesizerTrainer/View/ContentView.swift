import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

struct ContentView: View {
    
    var body: some View {
        SynthView(synthEngine: SynthEngineImpl())
    }
}

#Preview {
    ContentView()
}
