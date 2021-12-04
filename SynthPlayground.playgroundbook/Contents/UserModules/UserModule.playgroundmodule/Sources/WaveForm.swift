//
//  WaveForm.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct WaveForm : Shape{
    
    public init(function: @escaping (Float) -> Float, frequency: Binding<Float>) {
        
        self.function = function;
        self._frequency = frequency
        
    }
    
    public init(function: @escaping (Float) -> Float, defaultPhase: Float, frequency: Binding<Float>) {
        
        self.function = function;
        self.defaultPhase = defaultPhase;
        self._frequency = frequency;
        
    }
    
    let function: (Float) -> Float
    var resolution : Float = 100;
    let amp : Float = 50.0;
    var defaultPhase : Float = 0.0;
    @Binding var frequency : Float;
    
    var samples: [Float] {
        
        var data = [Float]()
        var phase : Float = defaultPhase;
        let phaseIncrement = (twoPi / resolution) * frequency;
        
        for _ in 0 ..< Int(resolution) {
            
            let y = function(phase);
            data.append(y < -1.0 ? -1.0 : (y > 1.0 ? 1.0 : y))
            phase += phaseIncrement
            if phase >= twoPi {
                phase -= twoPi
            }
            if phase < 0.0 {
                phase += twoPi
            }
            
        }
        
        // Normalize the signal
        
        var max : Float = 0;
        
        for i in 0 ..< Int(resolution) {
            if(abs(data[i]) > max){
                max = abs(data[i]);
            }
        }
        
        for i in 0 ..< Int(resolution) {
            
            data[i] = (data[i] / max) * amp;
            
        }
        
        return data;
    }
    
    func path(in rect: CGRect) -> Path {
        
        Path{ path in
            
            var off : CGFloat = rect.size.width / (CGFloat(resolution));
            var y : CGFloat = rect.size.height / 2;
            path.move(to: CGPoint(x: CGFloat(0) * off , y: y + CGFloat(samples[0])))
            
            for sample in 0 ..< Int(resolution) {
                
                off = rect.size.width / (CGFloat(resolution));
                y = rect.size.height / 2;
                let nextPos : Int = sample > 0 ? sample - 1 : 0;
                path.addLine(to: CGPoint(x: CGFloat(nextPos) * off, y: y + CGFloat(samples[nextPos])))
                
            }
        }
    }
}

