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
    
    // Simple envelope (attack/release only)
    private var attackTime: Float = 0.1 // seconds
    private var releaseTime: Float = 0.3 // seconds
    private var envelopeValue: Float = 0.0
    private var envelopeTarget: Float = 0.0
    private var envelopeRate: Float = 0.0
    
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
        
        // Generate samples once and copy to all channels
        for frame in 0..<Int(frameCount) {
            let rawSample = generateSample()
            let filteredSample = applyLowPassFilter(rawSample)
            let envelopedSample = applyEnvelope(filteredSample)
            
            // Write same sample to all channels (mono to stereo)
            for buffer in ablPointer {
                let bufferPointer = buffer.mData?.assumingMemoryBound(to: Float.self)
                bufferPointer?[frame] = envelopedSample
            }
            
            // Increment phase once per frame, not per channel
            phase += 2.0 * Float.pi * frequency / sampleRate
            if phase >= 2.0 * Float.pi {
                phase -= 2.0 * Float.pi
            }
        }
        
        return noErr
    }
    
    private func generateSample() -> Float {
        let sample: Float
        let normalizedPhase = phase / (2.0 * Float.pi) // 0.0 to 1.0
        
        switch waveformType {
        case .sine:
            sample = sin(phase)
        case .square:
            // Simple anti-aliasing by softening the transition
            let transition: Float = 0.02 // Small transition zone
            if normalizedPhase < (0.5 - transition) {
                sample = 1.0
            } else if normalizedPhase < (0.5 + transition) {
                // Linear interpolation across transition
                let t = (normalizedPhase - (0.5 - transition)) / (2.0 * transition)
                sample = 1.0 - 2.0 * t
            } else {
                sample = -1.0
            }
        case .sawtooth:
            // Ramp from -1 to 1
            sample = (2.0 * normalizedPhase) - 1.0
        case .triangle:
            if normalizedPhase < 0.5 {
                sample = (4.0 * normalizedPhase) - 1.0
            } else {
                sample = 3.0 - (4.0 * normalizedPhase)
            }
        }
        
        return sample * amplitude
    }
    
    func start() {
        isGenerating = true
        // Reset filter state when starting
        filterState = 0.0
        // Trigger envelope attack
        envelopeTarget = 1.0
        envelopeRate = (envelopeTarget - envelopeValue) / (attackTime * sampleRate)
    }
    
    func stop() {
        // Trigger envelope release
        envelopeTarget = 0.0
        envelopeRate = (envelopeTarget - envelopeValue) / (releaseTime * sampleRate)
        // Note: Don't set isGenerating = false immediately, let envelope finish
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
        // Clamp cutoff frequency to reasonable range
        let clampedCutoff = max(20.0, min(filterCutoff, sampleRate * 0.45))
        let rc = 1.0 / (2.0 * Float.pi * clampedCutoff)
        let dt = 1.0 / sampleRate
        filterCoeff = dt / (rc + dt)
        
        // Ensure coefficient is in valid range
        filterCoeff = max(0.001, min(filterCoeff, 0.999))
    }
    
    private func applyLowPassFilter(_ input: Float) -> Float {
        filterState += filterCoeff * (input - filterState)
        return filterState
    }
    
    private func applyEnvelope(_ input: Float) -> Float {
        // Update envelope value
        if abs(envelopeValue - envelopeTarget) > 0.001 {
            envelopeValue += envelopeRate
            
            // Clamp to target if we've overshot
            if (envelopeRate > 0 && envelopeValue >= envelopeTarget) ||
               (envelopeRate < 0 && envelopeValue <= envelopeTarget) {
                envelopeValue = envelopeTarget
                
                // If we've reached 0 during release, stop generating
                if envelopeTarget == 0.0 && envelopeValue == 0.0 {
                    isGenerating = false
                    filterState = 0.0 // Reset filter when fully stopped
                }
            }
        }
        
        return input * envelopeValue
    }
    
    func setAttackTime(_ time: Float) {
        attackTime = max(0.001, time) // Minimum 1ms
    }
    
    func setReleaseTime(_ time: Float) {
        releaseTime = max(0.001, time) // Minimum 1ms
    }
}