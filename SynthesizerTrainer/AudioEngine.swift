import AVFoundation
import Foundation

class AudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private var synthesizer: Synthesizer?
    
    // Audio buffer management settings
    private let preferredBufferSize: AVAudioFrameCount = 256
    private let preferredSampleRate: Double = 44100.0
    
    @Published var isPlaying = false
    
    init() {
        setupAudioSession()
        setupEngine()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Configure audio session for low-latency playback
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            
            // Set preferred buffer duration for low latency
            let bufferDuration = Double(preferredBufferSize) / preferredSampleRate
            try session.setPreferredIOBufferDuration(bufferDuration)
            
            // Set preferred sample rate
            try session.setPreferredSampleRate(preferredSampleRate)
            
            try session.setActive(true)
            
            // Log actual audio session settings
            print("Audio Session Configuration:")
            print("- Sample Rate: \(session.sampleRate) Hz")
            print("- Buffer Duration: \(session.ioBufferDuration) seconds")
            print("- Output Latency: \(session.outputLatency) seconds")
            
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupEngine() {
        synthesizer = Synthesizer()
        
        guard let synthesizer = synthesizer else { return }
        
        // Create audio format with our preferred settings
        let audioFormat = AVAudioFormat(
            standardFormatWithSampleRate: preferredSampleRate,
            channels: 2 // Stereo output
        )
        
        engine.attach(synthesizer.sourceNode)
        engine.connect(synthesizer.sourceNode, to: engine.mainMixerNode, format: audioFormat)
        
        // Configure main mixer node
        engine.mainMixerNode.outputVolume = 0.8 // Slightly lower to prevent clipping
        
        do {
            // Prepare engine with buffer size
            engine.prepare()
            try engine.start()
            
            print("Audio Engine Configuration:")
            print("- Format: \(audioFormat?.description ?? "nil")")
            print("- Running: \(engine.isRunning)")
            
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func startSynthesizer() {
        synthesizer?.start()
        isPlaying = true
    }
    
    func stopSynthesizer() {
        synthesizer?.stop()
        isPlaying = false
    }
    
    func setWaveform(_ waveform: WaveformType) {
        synthesizer?.setWaveform(waveform)
    }
    
    func setFilterCutoff(_ cutoff: Float) {
        synthesizer?.setFilterCutoff(cutoff)
    }
    
    func setAmplitude(_ amplitude: Float) {
        synthesizer?.setAmplitude(amplitude)
    }
    
    func setAttackTime(_ time: Float) {
        synthesizer?.setAttackTime(time)
    }
    
    func setReleaseTime(_ time: Float) {
        synthesizer?.setReleaseTime(time)
    }
    
    // MARK: - Audio Buffer Management
    
    func getAudioLatency() -> TimeInterval {
        let session = AVAudioSession.sharedInstance()
        return session.outputLatency + session.ioBufferDuration
    }
    
    func getCurrentSampleRate() -> Double {
        return AVAudioSession.sharedInstance().sampleRate
    }
    
    func getCurrentBufferSize() -> AVAudioFrameCount {
        let session = AVAudioSession.sharedInstance()
        return AVAudioFrameCount(session.ioBufferDuration * session.sampleRate)
    }
    
    func restartAudioEngine() {
        engine.stop()
        setupAudioSession()
        setupEngine()
        
        // Restore playing state if needed
        if isPlaying {
            startSynthesizer()
        }
    }
    
    deinit {
        engine.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}