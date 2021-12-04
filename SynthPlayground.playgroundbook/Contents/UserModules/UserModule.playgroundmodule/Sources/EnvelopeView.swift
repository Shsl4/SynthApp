//
//  SwiftUIView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import SwiftUI

struct EnvelopeView: View {
    
    public init(envIndex: Int){
        
        attackParam = envIndex == 0 ? Parameters.env1Attack : Parameters.env2Attack;
        decayParam = envIndex == 0 ? Parameters.env1Decay : Parameters.env2Decay;
        sustainParam = envIndex == 0 ? Parameters.env1Sustain : Parameters.env2Sustain;
        releaseParam = envIndex == 0 ? Parameters.env1Release : Parameters.env2Release;
        
    }
    
    private func updatePositions(){
        
        let attackTime = audioEngine.getAudioUnit().getParameterValue(attackParam);
        let decayTime = audioEngine.getAudioUnit().getParameterValue(decayParam);
        let sustainVal = audioEngine.getAudioUnit().getParameterValue(sustainParam);
        let releaseTime = audioEngine.getAudioUnit().getParameterValue(releaseParam);
        
        attackPos = CGPoint(x: timeToPos(width: frame.width, time: Double(attackTime), maxTime: maxTime), y: 0.0);
        sustainPos = CGPoint(x: timeToPos(width: frame.width, time: Double(decayTime + attackTime), maxTime: maxTime), y: intensityToPos(height: frame.height, intensity: Double(sustainVal)));
        releasePos = CGPoint(x: timeToPos(width: frame.width, time: Double(releaseTime + decayTime + attackTime), maxTime: maxTime), y: frame.height);
        
    }
    
    let attackParam : Parameters;
    let decayParam : Parameters;
    let sustainParam : Parameters;
    let releaseParam : Parameters;
    
    @State var frame = CGSize();

    @State var numIntersections : Int = 4;
    @State var attackPos : CGPoint = CGPoint.init(x: 100, y: 100);
    @State var sustainPos : CGPoint = CGPoint.init(x: 200, y: 200);
    @State var releasePos : CGPoint = CGPoint.init(x: 300, y: 0);

    @State var origX : CGFloat = 0.0;
    @State var origsX : CGFloat = 0.0;
    @State var movingAttack : Bool = false;
    
    let maxTime : Double = 5.0;
    
    func timeToPos(width: CGFloat, time: Double, maxTime: Double) -> CGFloat{
        
        return width * CGFloat(time) / CGFloat(maxTime);
        
    }
    
    func intensityToPos(height: CGFloat, intensity: Double) -> CGFloat{
        
        return height * CGFloat(intensity);
        
    }
    
    var body: some View {

        HStack {
            
            ZStack{
                
                GeometryReader { reader in
                    
                    BackgroundGraph(numIntersections: numIntersections)
                        .onAppear(perform: {
                            
                            frame = reader.size;
                            updatePositions();
                            
                        })
                    
                    Path() { path in
                        
                        let sRectPos = CGPoint(x: sustainPos.x, y: -sustainPos.y + frame.height)
                        path.move(to: CGPoint(x: 0.0, y: reader.size.height));
                        path.addLine(to: limit(attackPos));
                        path.move(to: limit(attackPos));
                        path.addLine(to: limit(sRectPos));
                        path.move(to: limit(sRectPos));
                        path.addLine(to: limit(releasePos));
                        
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    
                }
                
            }
            .aspectRatio(4/3, contentMode: .fit)
            
            HStack{
                
                Knob("Attack", param: attackParam, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(attackParam, value: Float(value));
                    updatePositions();

                })
                
                
                Knob("Decay", param: decayParam, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(decayParam, value: Float(value));
                    updatePositions();

                    
                })
                
                Knob("Sustain", param: sustainParam, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(sustainParam, value: Float(value));
                    updatePositions();

                })
                

                Knob("Release", param: releaseParam, onNewValue: { value in
                    
                    audioEngine.getAudioUnit().setParameterValue(releaseParam, value: Float(value));
                    updatePositions();

                })
            

            }
            .padding(.leading)
        }
    }
    
    func limit(_ point: CGPoint) -> CGPoint{
        if(point.x > frame.width){
            return CGPoint(x: frame.width, y: point.y)
        }
        return point;
    }
    
}

struct EnvelopeView_Previews: PreviewProvider {
    static var previews: some View {
       /* EnvelopeView()
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .colorScheme(.dark)
*/
        EmptyView();
    }
}
