//
//  Oscillator.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import CoreAudio
import AudioUnit

/**
    Manages polyphonic signal generation and handles events
 */
public class Oscillator{
    
    private(set) public var sampleRate : Float = 44100;
    private(set) public var bypassed : Bool = true;
    private(set) public var amplitude : Float = 1.0;
    private(set) public var signalFunction: ((Float) -> Float) = sin;
    private(set) public var semiShift : Int = 0;
    private(set) public var octShift : Int = 0;
    private(set) public var tuning : Float = 0.0;
    
    private var voices : [Voice] = [];
    private var activeVoices : [(id: Int, note: Int)] = []
    public var signalFunctionName = "Sine";
    private var filter : Filter;
    
    private(set) public var envAttack : Float = 1.0;
    private(set) public var envDecay : Float = 1.0;
    private(set) public var envSustain : Float = 1.0;
    private(set) public var envRelease : Float = 1.0;
    
    public init(sampleRate: Float) {
        
        self.sampleRate = sampleRate;
        self.filter = LowPassFilter(sampleRate: sampleRate, frequency: 500.0, q: 1.0);
        
        for id in 0 ..< 8{
            addVoice(voice: Voice(sampleRate: sampleRate, voiceID: id, envelopeReleased: onNoteStopped));
        }
                
    }

    public func getVoiceCount() -> Int {
        return voices.count;
    }
    
    public func getVoice(index: Int) -> Voice? {
        return index < voices.count ? voices[index] : nil;
    }
    
    public func getVoicePlayingNote(noteNumber: Int) -> Voice?{
        
        for voice in activeVoices {
            if(voice.note == noteNumber){
                return getVoice(index: voice.id)!;
            }
        }
        
        return nil;
        
    }
    
    public func getNextFreeVoice() -> Voice?{
        
        for voice in voices {
            if(!voice.isPlaying){
                return voice;
            }
        }
        
        return nil;
        
    }
    
    public func getFilter() -> Filter{
        return filter;
    }
    
    public func setEnvelopeAttack(_ attack: Float){
        
        envAttack = attack;
        
        for voice in voices {
            voice.envelope.setAttackTime(attack);
        }
        
    }
    
    public func setEnvelopeDecay(_ decay: Float){
        
        envDecay = decay;
        
        for voice in voices {
            voice.envelope.setDecayTime(decay);
        }
        
    }
    
    public func setEnvelopeSustain(_ sustain: Float){
        
        envSustain = sustain;
        
        for voice in voices {
            voice.envelope.setSustainLevel(sustain);
        }
        
    }
    
    public func setEnvelopeRelease(_ release: Float){
        
        envRelease = release;
        
        for voice in voices {
            voice.envelope.setReleaseTime(release);
        }
        
    }
    
    public func setSemiShift(_ semi: Int) {
        for voice in voices {
            voice.stop()
        }
        
        self.semiShift = semi;
        
    }
    public func setOctShift(_ oct: Int) {
        
        for voice in voices {
            voice.stop()
        }
        
        self.octShift = oct;
        
    }
    
    public func setBypassed(_ bypass: Bool) -> Void{

        if (bypass) {
            bypassed = true;
            killAll();

        }
        else {
            bypassed = false;
        }
        
    }
    
    public func setSignalFunction(function: @escaping (Float) -> Float){
        
        signalFunction = function;
        
        for voice in voices {
            voice.stop();
            voice.setSignalFunction(function);
        }
        
    }
    
    public func setTuning(_ tuning: Float){
        self.tuning = tuning;
        for voice in voices {
            voice.setTuning(tuning);
        }
    }
    
    
    public func setAmplitude(_ amp: Float){
        self.amplitude = amp;
    }
    
    private func onNoteStopped(voiceID: Int){
        
        var i : Int = 0;
        while i < activeVoices.count{
            
            if(activeVoices[i].id == voiceID){
                activeVoices.remove(at: i);
                continue;
            }
            
            i += 1;
            
        }
    }
    
    public func killAll() -> Void{
        
        for voice in voices {
            voice.kill();
        }
        
    }
    
    public func addVoice(voice: Voice) -> Void {
        voices.append(voice);
    }
    
    public func removeLastVoice() -> Bool{
        return removeVoice(index: voices.count - 1);
    }
    
    public func removeVoice(index: Int) -> Bool {
        
        if(index >= voices.count || index < 0) { return false; }
        voices[index].stop();
        voices.remove(at: index);
        return true;
        
    }
    
    private func applyNoteShift(noteNumber: Int) -> Int{
        
        return noteNumber + semiShift + 12 * octShift;
        
    }
    
    public func onNoteOn(noteNumber: Int, velocity: Int) -> Void{
        
        if(bypassed) { return; }
                        
        var voice : Voice? = getVoicePlayingNote(noteNumber: applyNoteShift(noteNumber: noteNumber));
        
        if(voice != nil){
            voice!.start(noteNumber: applyNoteShift(noteNumber: noteNumber), velocity: velocity, tuning: tuning + audioEngine.getAudioUnit().masterTuning);
            activeVoices.append((id: voice!.voiceID, note: applyNoteShift(noteNumber: noteNumber)))
        }
        else{
            
            voice = getNextFreeVoice();
            if voice != nil {
                voice!.start(noteNumber: applyNoteShift(noteNumber: noteNumber), velocity: velocity, tuning: tuning + audioEngine.getAudioUnit().masterTuning);
                activeVoices.append((id: voice!.voiceID, note: applyNoteShift(noteNumber: noteNumber)))
            }
            
        }
        
    }
    
    func onNoteOff(noteNumber: Int) -> Void{
                
        let voice = getVoicePlayingNote(noteNumber: applyNoteShift(noteNumber: noteNumber));
        
        if(voice != nil){
            voice!.stop();
        }
    }
    
    @inlinable @inline(__always) func clamp(_ value: Float, _ reduce: Float, _ threshold: Float) -> Float {
        
        return value * reduce < -threshold ? -threshold : (value * reduce > threshold) ? threshold : value * reduce;
        
    }
    
    public func fillBuffer(_ bufferList: UnsafeMutableAudioBufferListPointer, _ frameCount: AUAudioFrameCount, _ bufferOffset: AUAudioFrameCount) -> Void {
        
        if(bypassed) { return; }

        for sample in 0 ..< frameCount {
            
            var out : Float = 0.0;
            
            var count = 0;
            
            for voice in voices{
                
                if(voice.isPlaying) { count += 1; }
                
                out += clamp(voice.process(), 0.8, 1.0) * amplitude * audioEngine.getAudioUnit().masterAmp;
                
            }
            
            if(count == 0) { return;}
            
            out = filter.process(sample: out)
            
            bufferList.add(sample: Int(sample), value: out);
            
        }
        
    }
        
}
