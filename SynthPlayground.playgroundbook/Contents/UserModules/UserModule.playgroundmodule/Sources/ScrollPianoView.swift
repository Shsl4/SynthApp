//
//  ScrollPianoView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 18/04/2021.
//

import SwiftUI

struct ScrollPianoView: View {
    
    @Environment(\.colorScheme) var colorScheme;
        
    var body: some View {
        
        GeometryReader { reader in
            
            VStack {
            
                HStack{
                    
                    FilterView(oscIndex: 0)
                        .padding()


                    FilterView(oscIndex: 1)
                        .padding()

                }
                .frame(width: reader.size.width * 3/4, height: reader.size.height * 1/3, alignment: .center)
                
                ZStack{
                    
                    
                    VStack{
                                            
                        Text("< Slide here to scroll the piano >")
                            .padding()
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        Spacer()
                    
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        
                        VStack{
                            Text("")
                                .padding()
                        }.background(Color.init(.displayP3, white: 0.0, opacity: 0.0))
                        
                        VStack{
                                                        
                            HStack(alignment: .bottom, spacing: 0.0, content: {
                                
                                PianoView(octave: 4)
                                PianoView(octave: 5)
                                PianoView(octave: 6)
                                PianoView(octave: 7)
                                PianoView(octave: 8)
                                PianoView(octave: 9)
                                PianoView(octave: 10)

                            })
                            .padding(.top)
                            
                            
                        }
                        
                    }
                    
                }
                .frame(width: reader.size.width, height: reader.size.height * 2/3, alignment: .center)

                
            }
        }
    }
}

struct ScrollPianoView_Previews: PreviewProvider {
    static var previews: some View {
        //ScrollPianoView()
        EmptyView();
    }
}
