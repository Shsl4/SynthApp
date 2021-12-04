//
//  Knob.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import SwiftUI


public struct Knob : View{
    
    let color1 = Color(Color.RGBColorSpace.sRGB, red: 0.15, green: 0.15, blue: 0.15, opacity: 1.0)
    let color2 = Color(Color.RGBColorSpace.sRGB, red: 0.25, green: 0.25, blue: 0.25, opacity: 1.0)
    
    public init(_ title: String, param: Parameters, onNewValue: @escaping (Float) -> Void){
        self.knobName = title;
        self.param = param;
        self.max = CGFloat(audioEngine.getAudioUnit().getParameterMaxValue(param));
        self.min = CGFloat(audioEngine.getAudioUnit().getParameterMinValue(param));
        self.setNewValue = onNewValue;
        self.paramUnit = audioEngine.getAudioUnit().getParameterUnitName(param);
        self.defaultValue = audioEngine.getAudioUnit().getDefaultParameterValue(param);
    }
    
    let param : Parameters;
    let setNewValue : (Float) -> Void;
    let max: CGFloat;
    let min: CGFloat;
    let paramUnit : String;
    
    let knobName : String;
    @State var currentAngle : Angle = Angle.zero;
    @State var lastAngle : Angle = Angle.zero;
    @State var releaseAngle : Angle = Angle.zero;
    @State var percent : Float = 50.0;
    @State var isRotating = false;
    @State var displayedText : String = "";
    let defaultValue : Float;

    let maxAngle : Float = 120.0;
    
    
    private func rotationAngle(of point: CGPoint, around center: CGPoint) -> Float {
        let deltaY = point.y - center.y
        let deltaX = point.x - center.x
        return Float(atan2(deltaY, deltaX));
    }
    
    private func updateValue() -> Void{
        
        let newVal = (Float(max) - Float(min)) * percent / 100.0 + Float(min);
        setNewValue(newVal);
        displayedText = String(format: "%.1f %@", newVal, paramUnit);
        
    }
    
    public var body : some View{
        
        VStack{
            
            Spacer()
                .onAppear(){
                    
                    let currentValue = audioEngine.getAudioUnit().getParameterValue(param);
                    //(current - min) * 100.0 / (max - min)
                    let val = (currentValue - Float(min)) * 100.0 / ((Float(self.max) - Float(self.min)));
                    self.percent = val
                    let angle = Double(((maxAngle + maxAngle) * val / 100.0) - maxAngle);
                    self.currentAngle = Angle(degrees: angle)
                    self.lastAngle = self.currentAngle;
                    self.releaseAngle = self.currentAngle;
                    self.displayedText = knobName;
                }
                        
            GeometryReader{ reader in
                
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                    
                    Circle()
                        .foregroundColor(color1)
                        .padding(.horizontal)

                    
                    Circle()
                        .strokeBorder(color2, lineWidth: reader.size.width / 50, antialiased: true)
                        .padding(.horizontal)

                    VStack{
                        Rectangle()
                            .frame(width: reader.size.width / 30, height: reader.size.height / 3.5, alignment: .bottom)
                            .cornerRadius(100.0, antialiased: true)
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                    .rotationEffect(currentAngle)
                    .padding()

                })
                .onTapGesture(count: 2, perform: {
                   
                    let val = (defaultValue - Float(min)) * 100.0 / ((Float(self.max) - Float(self.min)));
                    self.percent = val
                    let angle = Double(((maxAngle + maxAngle) * val / 100.0) - maxAngle);
                    self.currentAngle = Angle(degrees: angle)
                    self.lastAngle = self.currentAngle;
                    self.releaseAngle = self.currentAngle;
                    self.displayedText = knobName;
                    setNewValue(defaultValue);
                    

                })
                .highPriorityGesture(DragGesture().onChanged({ value in
                    
                    let val = Float((value.translation.width - value.translation.height) / 2.0) + Float(lastAngle.degrees);
                    if(val > maxAngle) { percent = 100.0;
                        updateValue()
                        return;
                    }
                    
                    if(val < -Float(maxAngle)) { percent = 0.0;
                        updateValue()
                        return;
                    }
                    
                    self.currentAngle = Angle(degrees: Double(val));
                    percent = (Float(currentAngle.degrees) + maxAngle) * 100.0 / (maxAngle + maxAngle);
                    updateValue()
                    
                })
                .onEnded { value in
                    lastAngle = currentAngle;
                    displayedText = knobName;
                })
                
            }
            .aspectRatio(1.0, contentMode: .fit);
                        
            Text(displayedText).foregroundColor(Color(UIColor.label))
            
            Spacer()

            
        }
        
        
    }
    
}

struct Knob_Previews: PreviewProvider {
    static var previews: some View {
        //Knob("Knob", Binding<CGFloat>.constant(0.0), min: 1, max: 1)
        EmptyView();
    }
}
