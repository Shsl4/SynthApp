//
//  PianoView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 17/04/2021.
//

import SwiftUI

struct PianoView: View {
    
    @State var blackKeyWidth : CGFloat = 60.0;
    @State var octave : Int = 4;
    
    var body: some View {

        GeometryReader{ reader in
 
            ZStack{
                
                HStack(alignment: .center, spacing: 0.0, content: {
                    
                    WhiteKey(keyView: { return LeftKey(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.F,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                    WhiteKey(keyView: { return MiddleKey(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.G,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                    WhiteKey(keyView: { return MiddleKey2(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.A,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                    WhiteKey(keyView: { return RightKey(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.B,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                    WhiteKey(keyView: { return LeftKey(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.C,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
      
                    WhiteKey(keyView: { return MiddleKey3(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.D,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                    WhiteKey(keyView: { return RightKey(blackKeyWidth: blackKeyWidth) },
                             rootNote: Notes.E,
                             octave: $octave,
                             width: blackKeyWidth,
                             frameHeight: reader.size.height)
                    
                })
                
                HStack(alignment: .top, spacing: 0.0, content: {
                                        
                    Group{
                        
                        Rectangle()
                            .fill(Color(.sRGB, white: 0.0, opacity: 0.0))
                            .frame(width: blackKeyWidth * 3/4, height: reader.size.height * 2 / 3, alignment: .center)
                        
                        BlackKey(rootNote: Notes.FSharp, octave: $octave, width: blackKeyWidth, frameHeight: reader.size.height)

                        Rectangle()
                            .fill(Color(.sRGB, white: 0.0, opacity: 0.0))
                            .frame(width: blackKeyWidth * 3/4, height: reader.size.height * 2 / 3, alignment: .center)
       
                        BlackKey(rootNote: Notes.GSharp, octave: $octave, width: blackKeyWidth, frameHeight: reader.size.height)
                        
                        Rectangle()
                            .fill(Color(.sRGB, white: 0.0, opacity: 0.0))
                            .frame(width: blackKeyWidth * 3/4, height: reader.size.height * 2 / 3, alignment: .center)
       
                        BlackKey(rootNote: Notes.ASharp, octave: $octave, width: blackKeyWidth, frameHeight: reader.size.height)

                        Rectangle()
                            .fill(Color(.sRGB, white: 0.0, opacity: 0.0))
                            .frame(width: blackKeyWidth * 3/2, height: reader.size.height * 2 / 3, alignment: .center)
       
                        BlackKey(rootNote: Notes.CSharp, octave: $octave, width: blackKeyWidth, frameHeight: reader.size.height)

                        Rectangle()
                            .fill(Color(.sRGB, white: 0.0, opacity: 0.0))
                            .frame(width: blackKeyWidth, height: reader.size.height * 2 / 3, alignment: .center)
       
                        BlackKey(rootNote: Notes.DSharp, octave: $octave, width: blackKeyWidth, frameHeight: reader.size.height)
                        
                    }
                    
                    Spacer()
                    
                })
                .frame(height: reader.size.height, alignment: .top)
                
            }
            
        }
        .frame(width: 10.5 * blackKeyWidth, alignment: .center)

        
    }
}

struct PianoView_Previews: PreviewProvider {
    static var previews: some View {
        PianoView(octave: 6).previewLayout(.fixed(width: 1000, height: 300))
            
    }
}
