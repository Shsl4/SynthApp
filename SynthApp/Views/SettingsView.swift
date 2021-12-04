//
//  SettingsView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct SettingsView: View {

    @Binding var osc1Color: Color
    @Binding var osc2Color: Color
    @State var tuningSliderValue: Float = 0.0
    @State var tuningSliderRange: ClosedRange<Float> = -25...25
    @State var amplitudeSliderValue: Float = 0.0
    @State var amplitudeSliderRange: ClosedRange<Float> = -25...25

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        NavigationView {

            List {

                Section(header: Text("Oscillator Settings")) {

                    ColorPicker(selection: $osc1Color, label: {
                        Text("Oscillator 1 Color")
                    })

                    ColorPicker(selection: $osc2Color, label: {
                        Text("Oscillator 2 Color")
                    })

                }
                .onAppear(perform: {

                    let aMax = audioEngine.getAudioUnit().getParameterMaxValue(Parameters.masterAmp)
                    let aMin = audioEngine.getAudioUnit().getParameterMinValue(Parameters.masterAmp)
                    let aCurrent = audioEngine.getAudioUnit().getParameterValue(Parameters.masterAmp)
                    amplitudeSliderRange = aMin...aMax
                    amplitudeSliderValue = aCurrent

                    let tMax = audioEngine.getAudioUnit().getParameterMaxValue(Parameters.masterTuning)
                    let tMin = audioEngine.getAudioUnit().getParameterMinValue(Parameters.masterTuning)
                    let tCurrent = audioEngine.getAudioUnit().getParameterValue(Parameters.masterTuning)
                    tuningSliderRange = tMin...tMax
                    tuningSliderValue = tCurrent

                })

                Section(header: Text("MIDI")) {

                    NavigationLink(destination: MIDIDevicesView(), label: {

                        Image(systemName: "pianokeys")
                        Text("MIDI Device")

                    })
                    .navigationViewStyle(StackNavigationViewStyle())

                }

                Section(header: Text("General")) {

                    HStack {

                        Image(systemName: "dial.max")
                        Text("Master Amplitude")

                        Spacer()

                        Text(String(amplitudeSliderRange.lowerBound))

                        Slider(value: $amplitudeSliderValue, in: amplitudeSliderRange, onEditingChanged: { value in

                            if value == false {
                                audioEngine.getAudioUnit().setParameterValue(Parameters.masterAmp, value: amplitudeSliderValue)
                            }

                        })
                        .frame(maxWidth: 500.0)
                        .onTapGesture(count: 2, perform: {

                            amplitudeSliderValue = audioEngine.getAudioUnit().getDefaultParameterValue(Parameters.masterAmp)
                            audioEngine.getAudioUnit().setParameterValue(Parameters.masterAmp, value: amplitudeSliderValue)

                        })

                        Text(String(amplitudeSliderRange.upperBound))

                    }

                    HStack {

                        Image(systemName: "dial.min")
                        Text("Master Tuning")

                        Spacer()

                        Text(String(tuningSliderRange.lowerBound))

                        Slider(value: $tuningSliderValue, in: tuningSliderRange, onEditingChanged: { value in

                            if value == false {
                                audioEngine.getAudioUnit().setParameterValue(Parameters.masterTuning, value: tuningSliderValue)
                            }

                        })
                        .frame(maxWidth: 500.0)
                        .onTapGesture(count: 2, perform: {

                            tuningSliderValue = audioEngine.getAudioUnit().getDefaultParameterValue(Parameters.masterTuning)
                            audioEngine.getAudioUnit().setParameterValue(Parameters.masterTuning, value: tuningSliderValue)

                        })

                        Text(String(tuningSliderRange.upperBound))

                    }

                }

            }
            .padding()
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Settings")
            .navigationViewStyle(StackNavigationViewStyle())
            .background(Color(colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground))

        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(osc1Color: Binding<Color>.constant(.red), osc2Color: Binding<Color>.constant(.red))
    }
}
