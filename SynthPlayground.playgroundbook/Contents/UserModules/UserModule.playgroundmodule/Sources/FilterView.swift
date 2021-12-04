//
//  FilterView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 17/04/2021.
//

import SwiftUI

struct FilterView: View {
    
    
    let oscIndex : Int;
    let cutoffParam : Parameters;
    let qParam : Parameters;
    
    @State var bypassed : Bool = false;
    @Environment(\.colorScheme) var colorScheme;
    
    init(oscIndex: Int) {
        self.oscIndex = oscIndex;
        self.cutoffParam = oscIndex == 0 ? Parameters.osc1FilCutoff : Parameters.osc2FilCutoff;
        self.qParam = oscIndex == 0 ? Parameters.osc1FilQ : Parameters.osc2FilQ;

    }

    func toggleEnabled() -> Void{
        
        bypassed = !bypassed;
        let param = oscIndex == 0 ? Parameters.osc1FilBypass : Parameters.osc2FilBypass;
        audioEngine.getAudioUnit().setParameterValue(param, value: bypassed ? 1.0 : 0.0);
        
    }
    
    
    var body: some View {

        GeometryReader{ reader in
            
            HStack{
                
                HStack{
                    
                    Knob("Cutoff", param: cutoffParam, onNewValue: { value in
                        
                        audioEngine.getAudioUnit().setParameterValue(cutoffParam, value: value)
                        
                    })
                    
                    Knob("Q", param: qParam, onNewValue: { value in
                        
                        audioEngine.getAudioUnit().setParameterValue(qParam, value: value)

                    })
                    
                }
                .padding()
                .frame(width: reader.size.width * 1/2)
                
                Divider()
                    .onAppear(){
                        
                        let param = oscIndex == 0 ? Parameters.osc1FilBypass : Parameters.osc2FilBypass;
                        bypassed = audioEngine.getAudioUnit().getParameterValue(param) != 0;
                        
                    }
                
                VStack{
                    
                    Text(String(format:"Oscillator %d Filter", oscIndex + 1))
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                    
                    Button(action: {
                        
                        toggleEnabled()
                        
                    }, label: {
                        
                        if(bypassed){
                            Spacer()
                            Image(systemName: "play")
                            Text("Enable")
                            Spacer()
                            
                        }
                        else{
                            
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
                    
                    
                }
                .padding()
                .frame(width: reader.size.width * 1/2)
                
            }
            
        }
        .padding()
        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
        .background(colorScheme == .light ? Color(UIColor.secondarySystemFill) : Color(UIColor.tertiarySystemBackground))
        .cornerRadius(15)

    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        //FilterView()
        EmptyView();
    }
}
