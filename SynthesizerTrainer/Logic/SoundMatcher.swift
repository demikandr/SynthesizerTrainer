import Foundation

struct SoundMatchResult {
    let overallScore: Float // 0.0 to 1.0, where 1.0 is perfect match
    let waveformMatch: Float
    let frequencyMatch: Float
    let filterMatch: Float
    let amplitudeMatch: Float
    let envelopeMatch: Float
    
    var percentage: Int {
        return Int(overallScore * 100)
    }
    
    var qualityDescription: String {
        switch overallScore {
        case 0.9...1.0:
            return "Excellent Match!"
        case 0.8..<0.9:
            return "Very Good"
        case 0.7..<0.8:
            return "Good Match"
        case 0.6..<0.7:
            return "Getting Close"
        case 0.4..<0.6:
            return "Keep Trying"
        default:
            return "Try Again"
        }
    }
}

class SoundMatcher: ObservableObject {
    @Published var currentMatchResult: SoundMatchResult?
    
    func compareSound(target: TargetSound, userWaveform: WaveformType, userFrequency: Float, 
                     userFilterCutoff: Float, userAmplitude: Float, userAttackTime: Float, userReleaseTime: Float) -> SoundMatchResult {
        
        // Calculate individual parameter matches
        let waveformMatch = calculateWaveformMatch(target: target.waveform, user: userWaveform)
        let frequencyMatch = calculateFrequencyMatch(target: target.frequency, user: userFrequency)
        let filterMatch = calculateFilterMatch(target: target.filterCutoff, user: userFilterCutoff)
        let amplitudeMatch = calculateAmplitudeMatch(target: target.amplitude, user: userAmplitude)
        let envelopeMatch = calculateEnvelopeMatch(
            targetAttack: target.attackTime, userAttack: userAttackTime,
            targetRelease: target.releaseTime, userRelease: userReleaseTime
        )
        
        // Calculate weighted overall score
        let weights: [Float] = [0.25, 0.2, 0.25, 0.15, 0.15] // waveform, freq, filter, amp, envelope
        let scores = [waveformMatch, frequencyMatch, filterMatch, amplitudeMatch, envelopeMatch]
        
        let overallScore = zip(weights, scores).reduce(0) { result, pair in
            result + (pair.0 * pair.1)
        }
        
        let result = SoundMatchResult(
            overallScore: overallScore,
            waveformMatch: waveformMatch,
            frequencyMatch: frequencyMatch,
            filterMatch: filterMatch,
            amplitudeMatch: amplitudeMatch,
            envelopeMatch: envelopeMatch
        )
        
        currentMatchResult = result
        return result
    }
    
    private func calculateWaveformMatch(target: WaveformType, user: WaveformType) -> Float {
        return target == user ? 1.0 : 0.0
    }
    
    private func calculateFrequencyMatch(target: Float, user: Float) -> Float {
        let difference = abs(target - user)
        let tolerance: Float = 50.0 // Hz tolerance
        
        if difference <= tolerance {
            return 1.0 - (difference / tolerance) * 0.2 // Small penalty within tolerance
        } else {
            // Exponential decay for larger differences
            return max(0.0, exp(-difference / (tolerance * 2)))
        }
    }
    
    private func calculateFilterMatch(target: Float, user: Float) -> Float {
        let difference = abs(target - user)
        let tolerance: Float = 200.0 // Hz tolerance for filter
        
        if difference <= tolerance {
            return 1.0 - (difference / tolerance) * 0.3
        } else {
            return max(0.0, exp(-difference / (tolerance * 3)))
        }
    }
    
    private func calculateAmplitudeMatch(target: Float, user: Float) -> Float {
        let difference = abs(target - user)
        let tolerance: Float = 0.1 // Amplitude tolerance
        
        if difference <= tolerance {
            return 1.0 - (difference / tolerance) * 0.2
        } else {
            return max(0.0, exp(-difference / (tolerance * 2)))
        }
    }
    
    private func calculateEnvelopeMatch(targetAttack: Float, userAttack: Float, 
                                      targetRelease: Float, userRelease: Float) -> Float {
        let attackDiff = abs(targetAttack - userAttack)
        let releaseDiff = abs(targetRelease - userRelease)
        
        let attackTolerance: Float = 0.05 // 50ms tolerance
        let releaseTolerance: Float = 0.1 // 100ms tolerance
        
        let attackScore = attackDiff <= attackTolerance ? 
            1.0 - (attackDiff / attackTolerance) * 0.3 :
            max(0.0, exp(-attackDiff / (attackTolerance * 2)))
        
        let releaseScore = releaseDiff <= releaseTolerance ?
            1.0 - (releaseDiff / releaseTolerance) * 0.3 :
            max(0.0, exp(-releaseDiff / (releaseTolerance * 2)))
        
        return (attackScore + releaseScore) / 2.0
    }
    
    // Helper method to get parameter-specific feedback
    func getParameterFeedback(for parameter: String, score: Float) -> String {
        switch score {
        case 0.9...1.0:
            return "Perfect!"
        case 0.7..<0.9:
            return "Very close"
        case 0.5..<0.7:
            return "Getting closer"
        case 0.3..<0.5:
            return "Keep adjusting"
        default:
            return "Needs work"
        }
    }
    
    // Method to provide hints for improvement
    func getHint(target: TargetSound, userWaveform: WaveformType, userFrequency: Float,
                userFilterCutoff: Float, userAmplitude: Float) -> String {
        
        var hints: [String] = []
        
        if target.waveform != userWaveform {
            hints.append("Try the \(target.waveform) waveform")
        }
        
        if abs(target.filterCutoff - userFilterCutoff) > 300 {
            let direction = target.filterCutoff > userFilterCutoff ? "higher" : "lower"
            hints.append("Adjust filter cutoff \(direction)")
        }
        
        if abs(target.amplitude - userAmplitude) > 0.15 {
            let direction = target.amplitude > userAmplitude ? "louder" : "quieter"
            hints.append("Make it \(direction)")
        }
        
        return hints.isEmpty ? "You're very close!" : hints.joined(separator: ", ")
    }
}