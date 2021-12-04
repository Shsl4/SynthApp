//
//  SettingsBarView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct SettingsBarView: View {

    @Binding var osc1Color: Color
    @Binding var osc2Color: Color

    @Environment(\.colorScheme) var colorScheme

    @State var showingMIDIMenu: Bool = false
    @State var showingSettingsMenu: Bool = false

    public var body: some View {

        HStack {

            Button(action: { showingSettingsMenu = true }, label: {

                Image(systemName: "gear")
                Text("Synth Settings")

            })
            .padding()
            .background(Color(UIColor.secondarySystemFill))
            .foregroundColor(Color(UIColor.label))
            .cornerRadius(10.0)
            .sheet(isPresented: $showingSettingsMenu) {
                SettingsView(osc1Color: $osc1Color, osc2Color: $osc2Color)
            }

            Button(action: { showingMIDIMenu = true }, label: {

                Image(systemName: "pianokeys")
                Text("MIDI Device")

            })
            .padding()
            .background(Color(UIColor.secondarySystemFill))
            .foregroundColor(Color(UIColor.label))
            .cornerRadius(10.0)
            .sheet(isPresented: $showingMIDIMenu) {
                MIDIDevicesView()
            }

            Button(action: { audioEngine.getAudioUnit().killAll() }, label: {

                Image(systemName: "exclamationmark.triangle")
                Text("Panic")

            })
            .padding()
            .background(Color(UIColor.secondarySystemFill))
            .foregroundColor(Color(UIColor.label))
            .cornerRadius(10.0)

        }

        // .background(Color(colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground))

    }
}

struct SettingsBarView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBarView(osc1Color: Binding<Color>.constant(.red), osc2Color: Binding<Color>.constant(.red))
    }
}
