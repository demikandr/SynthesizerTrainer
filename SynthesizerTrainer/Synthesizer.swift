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
    
    private var isGenerating = false
    private var audioSourceNode: AVAudioSourceNode!
    
    override init() {
        super.init()
        
        self.sampleRate = Float(AVAudioSession.sharedInstance().sampleRate)
        
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
                let sample = generateSample()
                bufferPointer?[frame] = sample
                
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
}