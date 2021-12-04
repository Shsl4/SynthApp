//
//  EnvelopePoint.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import SwiftUI

public struct EnvelopePoint: View {

    let defaultColor = Color.blue
    @State var pointColor: Color = Color.blue
    @Binding var position: CGPoint
    public var body: some View {

        GeometryReader { reader in

            ZStack {

                Circle()
                    .strokeBorder(pointColor.opacity(1), lineWidth: reader.size.width / 50, antialiased: true)
                    .frame(width: reader.size.width / 35, height: reader.size.width / 35, alignment: .center)
                Circle()
                    .strokeBorder(pointColor.opacity(0.25), lineWidth: reader.size.width / 50, antialiased: true)
                    .frame(width: reader.size.width / 25, height: reader.size.width / 25, alignment: .center)

            }
            .position(position)

        }

    }
}

struct EnvelopePoint_Previews: PreviewProvider {
    static var previews: some View {
        // EnvelopePoint()
        EmptyView()
    }
}
