import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngine()
    @State private var selectedWaveform: WaveformType = .sine
    @State private var filterCutoff: Double = 1000.0
    @State private var amplitude: Double = 0.3
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack {
                Image(systemName: "waveform")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("SynthesizerTrainer")
                    .font(.title)
                Text("Audio synthesis learning app")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Synthesizer Controls
            VStack(spacing: 25) {
                // Play/Stop Button
                Button(action: {
                    if audioEngine.isPlaying {
                        audioEngine.stopSynthesizer()
                    } else {
                        audioEngine.startSynthesizer()
                    }
                }) {
                    Image(systemName: audioEngine.isPlaying ? "stop.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(audioEngine.isPlaying ? Color.red : Color.green)
                        .clipShape(Circle())
                }
                
                // Waveform Selection
                VStack {
                    Text("Waveform")
                        .font(.headline)
                    Picker("Waveform", selection: $selectedWaveform) {
                        Text("Sine").tag(WaveformType.sine)
                        Text("Square").tag(WaveformType.square)
                        Text("Sawtooth").tag(WaveformType.sawtooth)
                        Text("Triangle").tag(WaveformType.triangle)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Filter Cutoff
                VStack {
                    Text("Filter Cutoff: \(Int(filterCutoff)) Hz")
                        .font(.headline)
                    Slider(value: $filterCutoff, in: 100...5000, step: 10)
                        .accentColor(.blue)
                }
                
                // Amplitude
                VStack {
                    Text("Volume: \(Int(amplitude * 100))%")
                        .font(.headline)
                    Slider(value: $amplitude, in: 0.0...1.0, step: 0.01)
                        .accentColor(.orange)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onChange(of: selectedWaveform) {
            // Update synthesizer waveform when changed
        }
        .onChange(of: filterCutoff) {
            // Update filter cutoff when changed
        }
        .onChange(of: amplitude) {
            // Update amplitude when changed
        }
    }
}

#Preview {
    ContentView()
}