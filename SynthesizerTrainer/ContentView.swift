import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngine()
    @StateObject private var soundLibrary = SoundLibrary()
    @StateObject private var targetSoundPlayer = TargetSoundPlayer()
    
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
            
            // Target Sound Section
            if let targetSound = soundLibrary.currentTargetSound {
                VStack(spacing: 15) {
                    Text("Target Sound")
                        .font(.headline)
                    
                    VStack {
                        Text(targetSound.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(targetSound.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Target sound control buttons
                    HStack(spacing: 20) {
                        Button("◀") {
                            _ = soundLibrary.getPreviousTargetSound()
                        }
                        .disabled(soundLibrary.targetSounds.first?.id == targetSound.id)
                        
                        Button(action: {
                            if targetSoundPlayer.isPlaying {
                                targetSoundPlayer.stopTargetSound()
                            } else {
                                targetSoundPlayer.playTargetSound(targetSound)
                            }
                        }) {
                            Image(systemName: targetSoundPlayer.isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(targetSoundPlayer.isPlaying ? Color.red : Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Button("▶") {
                            _ = soundLibrary.getNextTargetSound()
                        }
                        .disabled(soundLibrary.targetSounds.last?.id == targetSound.id)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
            
            // Synthesizer Controls
            VStack(spacing: 25) {
                Text("Your Synthesizer")
                    .font(.headline)
                
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
            audioEngine.setWaveform(selectedWaveform)
        }
        .onChange(of: filterCutoff) {
            audioEngine.setFilterCutoff(Float(filterCutoff))
        }
        .onChange(of: amplitude) {
            audioEngine.setAmplitude(Float(amplitude))
        }
        .onAppear {
            // Set initial values
            audioEngine.setWaveform(selectedWaveform)
            audioEngine.setFilterCutoff(Float(filterCutoff))
            audioEngine.setAmplitude(Float(amplitude))
        }
    }
}

#Preview {
    ContentView()
}