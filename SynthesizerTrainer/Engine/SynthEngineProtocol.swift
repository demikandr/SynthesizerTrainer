import SwiftUI
import AudioKit

protocol SynthEngineProtocol: ObservableObject {
    
    // Published properties
    var waveform: WaveformType {get set}
    
    // MARK: Playing interface
    func play(note: MIDINoteNumber)
    func stop(note: MIDINoteNumber)
    
    // MARK: Settings interface
    func updateWaveform(_ newWaveform: WaveformType)
}

enum WaveformType: String, CaseIterable {
    case sine = "Sine"
    case square = "Square"
    case sawtooth = "Sawtooth"
    case triangle = "Triangle"
    
    var audioKitTable: AudioKit.Table {
        switch self {
        case .sine:
            return AudioKit.Table(.sine)
        case .square:
            return AudioKit.Table(.square)
        case .sawtooth:
            return AudioKit.Table(.sawtooth)
        case .triangle:
            return AudioKit.Table(.triangle)
        }
    }
}
