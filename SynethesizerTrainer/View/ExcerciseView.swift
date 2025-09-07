import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog

struct ExcerciseView: View {
    @StateObject var synthEngine = SynthEngineImpl()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("SynthEngine Test")
                .font(.largeTitle)
                .padding()
            
            SynthParamsView(synthEngine: synthEngine)
            SynthKeyboardView(synthEngine:synthEngine)
        }
    }
    
}

#Preview {
    ExcerciseView()
}
