import SwiftUI

struct SynthKeyboardView<T: SynthEngineProtocol>: View {
    @ObservedObject var synthEngine: T
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("SynthEngine Test")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                if isPlaying {
                    synthEngine.stop(pitch: 440)
                    isPlaying = false
                } else {
                    synthEngine.play(pitch: 440)
                    isPlaying = true
                }
            }) {
                Text(isPlaying ? "Stop Tone" : "Play Tone")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isPlaying ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            
            Text("Frequency: 440 Hz")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SynthKeyboardView(synthEngine: SynthEngineImpl())
}
