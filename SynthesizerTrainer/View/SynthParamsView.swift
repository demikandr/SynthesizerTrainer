import SwiftUI

struct SynthParamsView<T: SynthEngineProtocol>: View {
    @ObservedObject var synthEngine: T
    
    var body: some View {
        VStack(spacing: 40) {
            Picker("Waveform", selection: $synthEngine.waveform) {
                ForEach(WaveformType.allCases, id: \.self) { waveform in
                    Text(waveform.rawValue).tag(waveform)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: synthEngine.waveform) { _, newValue in
                synthEngine.updateWaveform(newValue)
            }
        }
    }
}

#Preview {
    SynthParamsView(synthEngine: SimpleSynthEngineImpl())
}
