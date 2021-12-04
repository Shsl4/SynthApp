//
//  BackgroundGraph.swift
//  SynthApp
//
//  Created by Pierre Juliot on 16/04/2021.
//

import SwiftUI

struct BackgroundGraph: View {
    
    @State var numIntersections : Int;
    
    var body: some View {

        GeometryReader { reader in
            
            Rectangle()
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            ForEach(1 ..< numIntersections) { line in
                Group {
                    Path { path in
                        let off : CGFloat = reader.size.width / CGFloat(numIntersections);
                        let y : CGFloat = reader.size.height
                        path.move(to: CGPoint(x: CGFloat(line) * off , y: 0))
                        path.addLine(to: CGPoint(x: CGFloat(line) * off, y: y))
                    }.stroke(Color(UIColor.secondarySystemFill))
                    
                }
            }
            
            ForEach(1 ..< numIntersections) { line in
                Group {
                    Path { path in
                        let off : CGFloat = reader.size.height / CGFloat(numIntersections);
                        let x : CGFloat = reader.size.width
                        path.move(to: CGPoint(x: 0, y: CGFloat(line) * off))
                        path.addLine(to: CGPoint(x: x, y: CGFloat(line) * off))
                    }
                    .stroke(Color(UIColor.secondarySystemFill))
                }
                
            }
            
        }
    }
}

struct BackgroundGraph_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGraph(numIntersections: 4);
    }
}
