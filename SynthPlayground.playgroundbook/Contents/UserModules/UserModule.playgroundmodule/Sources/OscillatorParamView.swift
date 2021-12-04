//
//  OscillatorParamView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct OscillatorParamView: View {
    
    init(parentView: OscillatorView, oscIndex: Int, frequency: Binding<Float>) {
        self.parentView = parentView;
        self.oscIndex = oscIndex;
        self.ampParameter = oscIndex == 0 ? Parameters.osc1Amp : Parameters.osc2Amp;
        self.tuningParameter = oscIndex == 0 ? Parameters.osc1Tuning : Parameters.osc2Tuning;
        self._frequency = frequency;
    }
    
    var parentView : OscillatorView;
    let oscIndex : Int;
    let ampParameter : Parameters;
    let tuningParameter : Parameters;

    @Binding var frequency : Float;
    @State var showingAlert : Bool = false;
    @State var errorMessage : String = "";
    @State var semitoneStepperValue : Int = 0;
    @State var octaveStepperValue : Int = 0;
    @State var formula : String = "";
    
    var body: some View {
        
        VStack{
            
            HStack{
                                                
                ParameterStepper(storeValue: $semitoneStepperValue, step: 1, range: -12 ... 12, onValueChanged: {
                    
                    let param = oscIndex == 0 ? Parameters.osc1Semi : Parameters.osc2Semi;
                    audioEngine.getAudioUnit().setParameterValue(param, value: Float(semitoneStepperValue));
                                        
                    
                }, name: "Semi")
                
                ParameterStepper(storeValue: $octaveStepperValue, step: 1, range: -4 ... 4, onValueChanged: {
                    
                    let param = oscIndex == 0 ? Parameters.osc1Oct : Parameters.osc2Oct;
                    audioEngine.getAudioUnit().setParameterValue(param, value: Float(octaveStepperValue));
                    
                    if(octaveStepperValue >= 0){
                        
                        frequency = 1.0 + Float(octaveStepperValue);
                        
                    }
                    else{
                        
                        frequency = 1.0;
                        
                    }
                    
                }, name: "Oct")
                                
                Knob("Amplitude", param: ampParameter, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(ampParameter, value: value)
                    
                })
                
                Knob("Tuning", param: tuningParameter, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(tuningParameter, value: value)
                    
                })
            }
        }
    }
}


