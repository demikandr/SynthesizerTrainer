import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngine()
    @StateObject private var soundLibrary = SoundLibrary()
    @StateObject private var targetSoundPlayer = TargetSoundPlayer()
    @StateObject private var soundMatcher = SoundMatcher()
    
    @State private var selectedWaveform: WaveformType = .sine
    @State private var filterCutoff: Double = 1000.0
    @State private var amplitude: Double = 0.3
    @State private var attackTime: Double = 0.1
    @State private var releaseTime: Double = 0.3
    
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
            
            // Match Quality Indicator
            if let matchResult = soundMatcher.currentMatchResult,
               let targetSound = soundLibrary.currentTargetSound {
                VStack(spacing: 10) {
                    Text("Match Quality")
                        .font(.headline)
                    
                    // Overall score with large percentage
                    Text("\(matchResult.percentage)%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(matchResult.percentage >= 80 ? .green : 
                                       matchResult.percentage >= 60 ? .orange : .red)
                    
                    Text(matchResult.qualityDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Parameter breakdown
                    HStack(spacing: 15) {
                        VStack {
                            Text("Wave")
                            Text("\(Int(matchResult.waveformMatch * 100))%")
                                .font(.caption)
                                .foregroundColor(matchResult.waveformMatch >= 0.8 ? .green : .orange)
                        }
                        VStack {
                            Text("Freq")
                            Text("\(Int(matchResult.frequencyMatch * 100))%")
                                .font(.caption)
                                .foregroundColor(matchResult.frequencyMatch >= 0.8 ? .green : .orange)
                        }
                        VStack {
                            Text("Filter")
                            Text("\(Int(matchResult.filterMatch * 100))%")
                                .font(.caption)
                                .foregroundColor(matchResult.filterMatch >= 0.8 ? .green : .orange)
                        }
                        VStack {
                            Text("Vol")
                            Text("\(Int(matchResult.amplitudeMatch * 100))%")
                                .font(.caption)
                                .foregroundColor(matchResult.amplitudeMatch >= 0.8 ? .green : .orange)
                        }
                        VStack {
                            Text("Env")
                            Text("\(Int(matchResult.envelopeMatch * 100))%")
                                .font(.caption)
                                .foregroundColor(matchResult.envelopeMatch >= 0.8 ? .green : .orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hint text
                    if matchResult.overallScore < 0.9 {
                        Text(soundMatcher.getHint(
                            target: targetSound,
                            userWaveform: selectedWaveform,
                            userFrequency: 440.0, // Fixed frequency for now
                            userFilterCutoff: Float(filterCutoff),
                            userAmplitude: Float(amplitude)
                        ))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
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
                
                // Envelope controls
                HStack(spacing: 20) {
                    VStack {
                        Text("Attack: \(Int(attackTime * 1000))ms")
                            .font(.subheadline)
                        Slider(value: $attackTime, in: 0.01...0.5, step: 0.01)
                            .accentColor(.purple)
                    }
                    VStack {
                        Text("Release: \(Int(releaseTime * 1000))ms")
                            .font(.subheadline)
                        Slider(value: $releaseTime, in: 0.1...2.0, step: 0.05)
                            .accentColor(.purple)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onChange(of: selectedWaveform) {
            audioEngine.setWaveform(selectedWaveform)
            updateMatchScore()
        }
        .onChange(of: filterCutoff) {
            audioEngine.setFilterCutoff(Float(filterCutoff))
            updateMatchScore()
        }
        .onChange(of: amplitude) {
            audioEngine.setAmplitude(Float(amplitude))
            updateMatchScore()
        }
        .onChange(of: attackTime) {
            audioEngine.setAttackTime(Float(attackTime))
            updateMatchScore()
        }
        .onChange(of: releaseTime) {
            audioEngine.setReleaseTime(Float(releaseTime))
            updateMatchScore()
        }
        .onAppear {
            // Set initial values
            audioEngine.setWaveform(selectedWaveform)
            audioEngine.setFilterCutoff(Float(filterCutoff))
            audioEngine.setAmplitude(Float(amplitude))
            audioEngine.setAttackTime(Float(attackTime))
            audioEngine.setReleaseTime(Float(releaseTime))
            updateMatchScore()
        }
    }
    
    private func updateMatchScore() {
        guard let targetSound = soundLibrary.currentTargetSound else { return }
        
        soundMatcher.compareSound(
            target: targetSound,
            userWaveform: selectedWaveform,
            userFrequency: 440.0, // Fixed frequency for now
            userFilterCutoff: Float(filterCutoff),
            userAmplitude: Float(amplitude),
            userAttackTime: Float(attackTime),
            userReleaseTime: Float(releaseTime)
        )
    }
}

#Preview {
    ContentView()
}