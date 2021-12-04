//
//  PianoKeys.swift
//  SynthApp
//
//  Created by Pierre Juliot on 18/04/2021.
//

import SwiftUI

enum Notes : Int {
   
    case A = -4
    case ASharp = -3
    case B = -2
    case C = -1
    case CSharp = 0
    case D = 1
    case DSharp = 2
    case E = 3
    case F = -8
    case FSharp = -7
    case G = -6
    case GSharp = -5
}

struct BlackKey : View{
    
    let rootNote : Notes;
    @Binding var octave : Int;
    let width: CGFloat;
    let frameHeight: CGFloat;
    
    @State var currentColor : Color = Color.black;
    
    private func getPlayedNoteNumber() -> Int {
        return rootNote.rawValue + 12 * octave;
    }
    
    var body : some View{
        
        Rectangle()
            .fill(currentColor)
            .border(Color.black, width: 1)
            .frame(width: width, height: frameHeight * 2 / 3, alignment: .center)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                if(pressing){
                    audioEngine.getAudioUnit().onNoteOn(noteNumber: getPlayedNoteNumber(), velocity: 100);
                    currentColor = Color.gray
                }
                else{
                    audioEngine.getAudioUnit().onNoteOff(noteNumber: getPlayedNoteNumber());
                    currentColor = Color.black
                }
                                            
            }, perform: {})
        
    }
    
}

struct WhiteKey<Content: Shape>: View {
    
    @Binding var octave : Int;
    let rootNote : Notes;
    let width: CGFloat;
    let frameHeight: CGFloat;
    let keyView : Content;
    
    init(@ViewBuilder keyView: () -> Content, rootNote: Notes, octave: Binding<Int>, width: CGFloat, frameHeight: CGFloat) {
        self.keyView = keyView();
        self.rootNote = rootNote;
        self._octave = octave;
        self.width = width;
        self.frameHeight = frameHeight;
    }
    
    @State var currentColor : Color = Color.white;
    
    private func getPlayedNoteNumber() -> Int {
        return rootNote.rawValue + 12 * octave;
    }
    
    var body : some View{
        
        ZStack{
            
            keyView
                .fill(currentColor)
                .border(Color.black, width: 1)
                .frame(width: width * 1.5, height: frameHeight, alignment: .center)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    
                    if(pressing){
                        audioEngine.getAudioUnit().onNoteOn(noteNumber: getPlayedNoteNumber(), velocity: 100);
                        currentColor = Color.gray
                    }
                    else{
                        audioEngine.getAudioUnit().onNoteOff(noteNumber: getPlayedNoteNumber());
                        currentColor = Color.white;

                    }
                                                
                }, perform: {})
            
            if(rootNote == Notes.C){
                
                VStack{
                    
                    Spacer()
                    
                    Text(String(format: "C%d", octave - 3))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.gray)
                        .padding()
                    
                }
                
            }
            
        }
        
    }
}

struct PianoKeys_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView();
    }
}
