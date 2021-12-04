//
//  Envelope.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import AudioUnit

/*
    In order to implement the envelope, I watched the video below explaining how it works.
    I then modified the implementation to make it work with my plugin
    https://www.youtube.com/watch?v=xDdul0FhAAY
 */

/**
    Modulates a signal's amplitude over time
 */
public class Envelope{
    
    public enum State{
        
        case Idle
        case Attack
        case Decay
        case Sustain
        case Release
        
    }
    
    private(set) public var attackTime : Float;
    private(set) public var decayTime : Float;
    private(set) public var sustainLevel : Float;
    private(set) public var releaseTime : Float;
    private(set) public var state : State;
    
    private var ramp : Ramp;
    private var bypassed : Bool = false;
    private var releasedCallback : () -> Void = {};
    
    public init(){
        self.attackTime = 0.001;
        self.decayTime = 0.001;
        self.sustainLevel = 1;
        self.releaseTime = 0.001;
        self.state = State.Idle;
        self.ramp = Ramp();
    }
        
    public init(sampleRate: Float){
        attackTime = 0.001;
        decayTime = 0.001;
        sustainLevel = 1;
        releaseTime = 0.001;
        state = State.Idle;
        ramp = Ramp(sampleRate: sampleRate);
    }
    
    func setReleasedCallback(_ callback: @escaping () -> Void){
        self.releasedCallback = callback;
    }
    
    public func setSampleRate(_ rate: Float) -> Void{
        ramp.setSampleRate(rate);
    }
        
    public func trigger() -> Void{
        
        ramp.setValue(0.0);
        state = State.Attack;
        ramp.rampTo(value: 1.0, time: attackTime);

    }
    
    public func release() -> Void{
        
        state = State.Release;
        ramp.rampTo(value: 0.0, time: releaseTime);
        
    }
    
    public func process() -> Float{
        
        if(bypassed) { return 1.0; }
        
        if(state == State.Idle) {
        }
        else if(state == State.Attack) {
            if(ramp.finished()){
                state = State.Decay;
                ramp.rampTo(value: sustainLevel, time: decayTime);
            }
        }
        else if(state == State.Decay) {
            if(ramp.finished()){
                state = State.Sustain;
            }
        }
        else if(state == State.Sustain) {
            if(sustainLevel == 0.0){
                ramp.setValue(0.0);
                state = State.Release;
            }
        }
        else if(state == State.Release) {
            if(ramp.finished()){
                state = State.Idle;
                releasedCallback();
                return 0.0;
            }
        }
        
        return ramp.process();
        
    }
        
    public func isActive() -> Bool{
        return state != State.Idle;
    }
    
    public func setAttackTime(_ time: Float) -> Void {
        
        if(time >= 0.0){
            attackTime = time;
            return;
        }
        
        attackTime = 0.0;
        
    }
    
    public func setDecayTime(_ time: Float) -> Void {
        
        if(time >= 0.0){
            decayTime = time;
            return;
        }
        
        decayTime = 0.0;
        
    }
    
    public func setSustainLevel(_ level : Float) -> Void {
        
        if(level < 0.0){
            sustainLevel = 0.0;
            return;
        }
        
        sustainLevel = level;
        
    }
    
    public func setReleaseTime(_ time : Float) -> Void {
        
        if(time >= 0.0){
            releaseTime = time;
            return;
        }
        
        releaseTime = 0.0;
    }
    
    public func setBypassed(_ value: Bool){
        bypassed = value;
    }
    
    public func stop() -> Void{
        
        ramp.setValue(0.0);
        state = State.Idle;
        releasedCallback();
        
    }
    
}
