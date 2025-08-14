import AVFoundation
import Foundation

enum WaveformType: CaseIterable {
    case sine, square, sawtooth, triangle
}

class Synthesizer: NSObject {
    private var frequency: Float = 440.0 // A4
    private var amplitude: Float = 0.3
    private var waveformType: WaveformType = .sine
    private var phase: Float = 0.0
    private var sampleRate: Float = 44100.0
    private var filterCutoff: Float = 1000.0
    
    // Simple low-pass filter state
    private var filterState: Float = 0.0
    private var filterCoeff: Float = 0.1
    
    private var isGenerating = false
    private var audioSourceNode: AVAudioSourceNode!
    
    override init() {
        super.init()
        
        self.sampleRate = Float(AVAudioSession.sharedInstance().sampleRate)
        updateFilterCoefficients()
        
        audioSourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
            guard let self = self, self.isGenerating else {
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buffer in ablPointer {
                    memset(buffer.mData, 0, Int(buffer.mDataByteSize))
                }
                return noErr
            }
            
            return self.renderAudio(frameCount: frameCount, audioBufferList: audioBufferList)
        }
    }
    
    var sourceNode: AVAudioSourceNode {
        return audioSourceNode
    }
    
    private func renderAudio(frameCount: AVAudioFrameCount, audioBufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        
        for buffer in ablPointer {
            let bufferPointer = buffer.mData?.assumingMemoryBound(to: Float.self)
            
            for frame in 0..<Int(frameCount) {
                let rawSample = generateSample()
                let filteredSample = applyLowPassFilter(rawSample)
                bufferPointer?[frame] = filteredSample
                
                // Increment phase
                phase += 2.0 * Float.pi * frequency / sampleRate
                if phase >= 2.0 * Float.pi {
                    phase -= 2.0 * Float.pi
                }
            }
        }
        
        return noErr
    }
    
    private func generateSample() -> Float {
        let sample: Float
        
        switch waveformType {
        case .sine:
            sample = sin(phase)
        case .square:
            sample = phase < Float.pi ? 1.0 : -1.0
        case .sawtooth:
            sample = (phase / Float.pi) - 1.0
        case .triangle:
            sample = phase < Float.pi ? (2.0 * phase / Float.pi) - 1.0 : 3.0 - (2.0 * phase / Float.pi)
        }
        
        return sample * amplitude
    }
    
    func start() {
        isGenerating = true
    }
    
    func stop() {
        isGenerating = false
    }
    
    func setFrequency(_ freq: Float) {
        frequency = freq
    }
    
    func setAmplitude(_ amp: Float) {
        amplitude = max(0.0, min(1.0, amp))
    }
    
    func setWaveform(_ type: WaveformType) {
        waveformType = type
    }
    
    func setFilterCutoff(_ cutoff: Float) {
        filterCutoff = cutoff
        updateFilterCoefficients()
    }
    
    private func updateFilterCoefficients() {
        // Simple one-pole low-pass filter coefficient calculation
        let rc = 1.0 / (2.0 * Float.pi * filterCutoff)
        let dt = 1.0 / sampleRate
        filterCoeff = dt / (rc + dt)
    }
    
    private func applyLowPassFilter(_ input: Float) -> Float {
        filterState += filterCoeff * (input - filterState)
        return filterState
    }
}