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
        VStack(spacing: 0) {
            // Compact Header
            HStack {
                Image(systemName: "waveform")
                    .imageScale(.medium)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("SynthesizerTrainer")
                        .font(.headline)
                    Text("Audio synthesis learning app")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Main Content Area
            HStack(spacing: 15) {
                // Left Side - Target Sound
                if let targetSound = soundLibrary.currentTargetSound {
                    VStack(spacing: 8) {
                        Text("Target Sound")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        VStack(spacing: 4) {
                            Text(targetSound.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(targetSound.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Target sound controls - compact
                        HStack(spacing: 8) {
                            Button("◀") {
                                _ = soundLibrary.getPreviousTargetSound()
                            }
                            .disabled(soundLibrary.targetSounds.first?.id == targetSound.id)
                            .font(.caption)
                            
                            Button(action: {
                                if targetSoundPlayer.isPlaying {
                                    targetSoundPlayer.stopTargetSound()
                                } else {
                                    targetSoundPlayer.playTargetSound(targetSound)
                                }
                            }) {
                                Image(systemName: targetSoundPlayer.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(targetSoundPlayer.isPlaying ? Color.red : Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            Button("▶") {
                                _ = soundLibrary.getNextTargetSound()
                            }
                            .disabled(soundLibrary.targetSounds.last?.id == targetSound.id)
                            .font(.caption)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(8)
                }
                
                // Right Side - Your Synthesizer
                VStack(spacing: 8) {
                    Text("Your Synthesizer")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Play/Stop Button - smaller
                    Button(action: {
                        if audioEngine.isPlaying {
                            audioEngine.stopSynthesizer()
                        } else {
                            audioEngine.startSynthesizer()
                        }
                    }) {
                        Image(systemName: audioEngine.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(audioEngine.isPlaying ? Color.red : Color.green)
                            .clipShape(Circle())
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.08))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Center - Match Quality (prominent)
            if let matchResult = soundMatcher.currentMatchResult,
               let targetSound = soundLibrary.currentTargetSound {
                VStack(spacing: 8) {
                    Text("Match Quality")
                        .font(.headline)
                    
                    Text("\(matchResult.percentage)%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(matchResult.percentage >= 80 ? .green : 
                                       matchResult.percentage >= 60 ? .orange : .red)
                    
                    Text(matchResult.qualityDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Parameter breakdown - horizontal
                    HStack(spacing: 15) {
                        VStack(spacing: 2) {
                            Text("Wave")
                                .font(.caption)
                            Text("\(Int(matchResult.waveformMatch * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(matchResult.waveformMatch >= 0.8 ? .green : .orange)
                        }
                        VStack(spacing: 2) {
                            Text("Freq")
                                .font(.caption)
                            Text("\(Int(matchResult.frequencyMatch * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(matchResult.frequencyMatch >= 0.8 ? .green : .orange)
                        }
                        VStack(spacing: 2) {
                            Text("Filter")
                                .font(.caption)
                            Text("\(Int(matchResult.filterMatch * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(matchResult.filterMatch >= 0.8 ? .green : .orange)
                        }
                        VStack(spacing: 2) {
                            Text("Env")
                                .font(.caption)
                            Text("\(Int(matchResult.envelopeMatch * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(matchResult.envelopeMatch >= 0.8 ? .green : .orange)
                        }
                    }
                    
                    // Hint text - compact
                    if matchResult.overallScore < 0.9 {
                        Text(soundMatcher.getHint(
                            target: targetSound,
                            userWaveform: selectedWaveform,
                            userFrequency: 440.0,
                            userFilterCutoff: Float(filterCutoff),
                            userAmplitude: 0.3
                        ))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 15)
            }
            
            // Bottom - Controls (compact)
            VStack(spacing: 12) {
                // Waveform Selection - compact
                VStack(spacing: 6) {
                    Text("Waveform")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Picker("Waveform", selection: $selectedWaveform) {
                        Text("Sine").tag(WaveformType.sine)
                        Text("Square").tag(WaveformType.square)
                        Text("Sawtooth").tag(WaveformType.sawtooth)
                        Text("Triangle").tag(WaveformType.triangle)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Filter Cutoff - compact
                VStack(spacing: 4) {
                    Text("Adjust filter cutoff higher")
                        .font(.caption)
                        .foregroundColor(.blue)
                    HStack {
                        Text("Filter")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(filterCutoff)) Hz")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $filterCutoff, in: 100...5000, step: 10)
                        .accentColor(.blue)
                }
                
                // Envelope controls - very compact
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Attack")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(Int(attackTime * 1000))ms")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Slider(value: $attackTime, in: 0.01...0.5, step: 0.01)
                            .accentColor(.purple)
                    }
                    VStack(spacing: 4) {
                        Text("Release")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(Int(releaseTime * 1000))ms")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Slider(value: $releaseTime, in: 0.1...2.0, step: 0.05)
                            .accentColor(.purple)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            Spacer(minLength: 0)
        }
        .onChange(of: selectedWaveform) {
            audioEngine.setWaveform(selectedWaveform)
            updateMatchScore()
        }
        .onChange(of: filterCutoff) {
            audioEngine.setFilterCutoff(Float(filterCutoff))
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
            audioEngine.setAmplitude(0.3) // Fixed volume
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
            userAmplitude: 0.3, // Fixed amplitude - not compared
            userAttackTime: Float(attackTime),
            userReleaseTime: Float(releaseTime)
        )
    }
}

#Preview {
    ContentView()
}