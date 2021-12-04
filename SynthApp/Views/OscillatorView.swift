//
//  OscillatorView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI
import UIKit

public struct OscillatorMasterView: View {

    @Binding var oscColor: Color
    let oscIndex: Int

    public var body : some View {

        GeometryReader { reader in

            VStack {

                Spacer()

                HStack {
                    Spacer()
                }

                OscillatorView(oscColor: $oscColor, oscIndex: oscIndex)
                    .frame(width: reader.size.width * 0.8, height: reader.size.width * 0.4, alignment: .center)
                    .padding()

                Spacer()

            }
        }

    }

}

struct TextView: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }

    let action: ((String) -> Void)

    func makeUIViewController(context: Context) -> UIViewController {

        let ac = UIAlertController(title: "Enter a Formula", message: "Enter a formula to generate a custom waveform.", preferredStyle: .alert)
        ac.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in

            action(ac.textFields![0].text ?? "")

        }

        ac.addAction(cancelAction)
        ac.addAction(submitAction)

        return ac

    }

}

public struct OscillatorView: View {

    let oscIndex: Int

    @Binding var oscColor: Color
    @State var activeFunction: (Float) -> Float = sin
    @State var selectedWaveformName = "Sine"
    @State var numIntersections: Int = 4
    @State var bypassed: Bool = false
    @State var frequency: Float = 1.0
    @State var formulaAlert: Bool = false
    @State var formulaError: String = ""
    @State var showingFormula: Bool = false
    @State var formulaValue: String = ""

    @Environment(\.colorScheme) var colorScheme

    func receiveFormula(formula: String) {

        do {

            parser.reset(expression: formula)
            try parser.prepare()
            let expression = try parser.generateExpression()

            waveFormChanged(function: expression, name: "Custom Waveform")

        } catch let error as NSError {

            formulaError = error.localizedFailureReason ?? "Error"
            formulaAlert = true

        }

    }

    public init(oscColor: Binding<Color>, oscIndex: Int) {

        self._oscColor = oscColor
        self.oscIndex = oscIndex

    }

    public func waveFormChanged(function: @escaping (Float) -> Float, name: String) {

        activeFunction = function
        selectedWaveformName = name
        audioEngine.getAudioUnit().updateSignal(function, forOsc: oscIndex, name: name)

    }

    private func makePhase() -> Float {

        if selectedWaveformName == "Triangle" {
            return Float.pi / 2
        } else if selectedWaveformName == "Sawtooth" {
            return Float.pi
        }
        return 0
    }

    func toggleEnabled() {

        bypassed = !bypassed
        let param = oscIndex == 0 ? Parameters.osc1Bypass : Parameters.osc2Bypass
        audioEngine.getAudioUnit().setParameterValue(param, value: bypassed ? 1.0 : 0.0)
    }

    func updateInfo() {

        let tuple = audioEngine.getAudioUnit().getSignalInfo(forOsc: oscIndex)!
        selectedWaveformName = tuple.0
        activeFunction = tuple.1
        bypassed = audioEngine.getAudioUnit().getParameterValue(oscIndex == 0 ? Parameters.osc1Bypass : Parameters.osc2Bypass) != 0

    }

    public var body: some View {

        GeometryReader { reader in

            HStack {

                VStack {

                    HStack {

                        ZStack {

                            BackgroundGraph(numIntersections: numIntersections)
                                .onAppear(perform: { updateInfo() })

                            WaveForm(function: activeFunction, defaultPhase: makePhase(), frequency: $frequency)
                                .stroke(oscColor.opacity(bypassed ? 0.25 : 1.0), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                        }
                        .aspectRatio(4/3, contentMode: .fit)
                        .padding()

                        Spacer()

                        OscillatorParamView(parentView: self, oscIndex: oscIndex, frequency: $frequency)

                        Spacer()

                    }

                    EnvelopeView(envIndex: oscIndex)
                        .padding()

                }
                .frame(width: reader.size.width * 3/4)

                Divider()

                VStack {

                    Spacer()

                    Menu(content: {

                        Button(action: { waveFormChanged(function: sin, name: "Sine"); }, label: {

                            if selectedWaveformName == "Sine" {
                                Image(systemName: "checkmark")
                            }

                            Text("Sine")

                        })
                        Button(action: { waveFormChanged(function: Signals.sawtoothDown, name: "Sawtooth"); }, label: {

                            if selectedWaveformName == "Sawtooth" {
                                Image(systemName: "checkmark")
                            }

                            Text("Sawtooth")

                        })
                        Button(action: { waveFormChanged(function: Signals.square, name: "Square"); }, label: {

                            if selectedWaveformName == "Square" {
                                Image(systemName: "checkmark")
                            }

                            Text("Square")

                        })
                        Button(action: { waveFormChanged(function: Signals.triangle, name: "Triangle"); }, label: {

                            if selectedWaveformName == "Triangle" {
                                Image(systemName: "checkmark")
                            }

                            Text("Triangle")

                        })

                        Button(action: { waveFormChanged(function: Signals.whiteNoise, name: "White Noise"); }, label: {

                            if selectedWaveformName == "White Noise" {
                                Image(systemName: "checkmark")
                            }

                            Text("White Noise")

                        })

                    }, label: {

                        Spacer()

                        Image(systemName: "waveform")
                        Text("Waveform")

                        Spacer()

                    })
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .background(colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.quaternarySystemFill))
                    .cornerRadius(10.0)

                    Spacer()

                    Button(action: {

                        // requestFormula();
                        showingFormula = true

                    }, label: {

                        Spacer()
                        Image(systemName: "function")
                        Text("Formula")
                        Spacer()

                    })
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .background(colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.quaternarySystemFill))
                    .cornerRadius(10.0)

                    Spacer()

                    Button(action: {

                        toggleEnabled()

                    }, label: {

                        if bypassed {
                            Spacer()
                            Image(systemName: "play")
                            Text("Enable")
                            Spacer()

                        } else {

                            Spacer()
                            Image(systemName: "play.slash")
                            Text("Disable")
                            Spacer()

                        }

                    })
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .background(colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.quaternarySystemFill))
                    .cornerRadius(10.0)

                    Spacer()

                    Button(action: {

                        audioEngine.getAudioUnit().panic()

                    }, label: {

                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                        Text("Panic")
                        Spacer()

                    })
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .background(colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.quaternarySystemFill))
                    .cornerRadius(10.0)

                    Spacer()

                }
                .padding()
                .frame(width: reader.size.width * 1/4)

            }
            .popover(isPresented: $showingFormula, content: {

                TextView(action: receiveFormula)

            })
            .alert(isPresented: $formulaAlert, content: {

                return Alert(title: Text("Parse error"),
                             message: Text(formulaError),
                             dismissButton: Alert.Button.default(Text("Dismiss"), action: { formulaAlert = false }))

            })

        }
        .padding()
        .background(colorScheme == .light ? Color(UIColor.secondarySystemFill) : Color(UIColor.tertiarySystemBackground))
        .cornerRadius(15)
    }

}

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView(oscColor: Binding<Color>.constant(.orange), oscIndex: 0).previewLayout(.fixed(width: 900, height: 400)).colorScheme(.dark)
    }
}
