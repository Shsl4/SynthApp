//
//  Stepper.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct ParameterStepper: View {

    static let placeHolder = ParameterStepper(storeValue: Binding<Int>.constant(0), step: 0, range: 0 ... 0, onValueChanged: {}, name: "Param")

    @Binding var storeValue: Int
    let step: Int
    let range: ClosedRange<Int>
    let onValueChanged : () -> Void
    let name: String

    var body: some View {

        VStack {

            Text(String(storeValue))

            Stepper("", value: $storeValue, in: range, step: step, onEditingChanged: { _ in

                onValueChanged()

            }).labelsHidden().padding(.vertical)

            Text(name)

        }

    }
}

struct ParameterStepper_Previews: PreviewProvider {
    static var previews: some View {
        ParameterStepper(storeValue: Binding<Int>.constant(0), step: 1, range: 0 ... 1, onValueChanged: {}, name: "Param")
    }
}
