import SwiftUI
import AudioKit
import SoundpipeAudioKit
import OSLog


struct ContentView: View {
    @State private var isPlaying = false
    private var logger = Logger()
    private var engine = AudioEngine()
    var body: some View {
        VStack(spacing: 40) {
            Text("Simple Audio Test")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                if isPlaying {
                    isPlaying = false
                } else {

                    // 2. Create the oscillator
                    let oscillator = Oscillator()
                    oscillator.frequency = 440

                    // 3. Connect the oscillator to the engine's output
                    engine.output = oscillator

                    do {
                        // 4. Start the engine
                        try engine.start()
                        logger.info("engine started")
                        
                        // 5. Start the oscillator
                        oscillator.start()
                        logger.info("oscilator started")

                    } catch {
                        logger.error("AudioKit did not start! \(error)")
                    }
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
    ContentView()
}
