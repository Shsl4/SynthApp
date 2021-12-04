//
//  SwiftUIView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

public struct EntryView: View {

    public init() {

        do {
            try audioEngine.start()
        } catch let error as NSError {
            fatalError(error.localizedFailureReason!)
        }

        // Force static object creation
        _ = midiInstance.hasActiveDevice()

    }

    @State var osc1Color: Color = Color.green
    @State var osc2Color: Color = Color.purple

    public var body: some View {

        GeometryReader { _ in

            VStack(alignment: .center) {

                TabView {

                    OscillatorMasterView(oscColor: $osc1Color, oscIndex: 0).tabItem {
                        Label("Oscillator 1", systemImage: "waveform.path.ecg.rectangle")
                    }

                    OscillatorMasterView(oscColor: $osc2Color, oscIndex: 1).tabItem {
                        Label("Oscillator 2", systemImage: "waveform.path.ecg.rectangle.fill")
                    }

                    ScrollPianoView().tabItem {
                        Label("Piano", systemImage: "pianokeys")
                    }

                    SettingsView(osc1Color: $osc1Color, osc2Color: $osc2Color).tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .navigationViewStyle(StackNavigationViewStyle())

                }

            }

        }

    }

}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView().previewDevice(.init(stringLiteral: "iPad Air (4th generation)")).colorScheme(.dark)

    }
}
