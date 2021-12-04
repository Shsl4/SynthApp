//
//  SynthAUSwiftswift
//  SynthAU
//
//  Created by Pierre Juliot on 11/04/2021.
//

import Foundation
import AudioToolbox

/**
    Enum containing the AudioUnit parameters and their default values.
 */
public enum Parameters : UInt64{
    
    public struct Defaults{
        
        public static var masterAmp : Float = 1.0
        public static var osc1Bypass : Float = 0.0
        public static var osc2Bypass : Float = 1.0
        public static var env1Attack : Float = 0.00
        public static var env1Decay : Float = 1.0
        public static var env1Sustain : Float = 1.0
        public static var env1Release : Float = 0.00
        public static var env2Attack : Float = 0.00
        public static var env2Decay : Float = 1.0
        public static var env2Sustain : Float = 1.0
        public static var env2Release : Float = 0.0
        public static var masterTuning : Float = 0.0
        public static var osc1Oct : Float = 0.0
        public static var osc1Semi : Float = 0.0
        public static var osc2Oct : Float = 0.0
        public static var osc2Semi : Float = 0.0
        public static var osc1Amp : Float = 0.5
        public static var osc1Tuning : Float = 0.0
        public static var osc2Amp : Float = 0.5
        public static var osc2Tuning : Float = 0.0
        public static var osc1FilBypass : Float = 1.0
        public static var osc1FilCutoff : Float = 1000.0
        public static var osc1FilQ : Float = 1.0
        public static var osc2FilBypass : Float = 1.0
        public static var osc2FilCutoff : Float = 1000.0
        public static var osc2FilQ : Float = 1.0
        
    }
    
    case masterAmp = 0
    case osc1Bypass = 1
    case osc2Bypass = 2
    case env1Attack = 3
    case env1Decay = 4
    case env1Sustain = 5
    case env1Release = 6
    case env2Attack = 7
    case env2Decay = 8
    case env2Sustain = 9
    case env2Release = 10
    case masterTuning = 11
    case osc1Oct = 12
    case osc1Semi = 13
    case osc2Oct = 14
    case osc2Semi = 15
    case osc1Amp = 16
    case osc1Tuning = 17
    case osc2Amp = 18
    case osc2Tuning = 19
    case osc1FilBypass = 20
    case osc1FilCutoff = 21
    case osc1FilQ = 22
    case osc2FilBypass = 23
    case osc2FilCutoff = 24
    case osc2FilQ = 25
    
};

/**
    A signal generating Audio Unit with two oscillators and filters.
 */
public class SynthAudioUnit : AUAudioUnit {
    
    // Avoids "Property 'self.kernelAdapter' not initialized at super.init call". I don't want my KernelAdapter variable to be optional
    private var _krnl : SynthAUDSPKernelAdapter? = nil;
    private var kernelAdapter : SynthAUDSPKernelAdapter { return _krnl!; };
    
    private var inputBusArray : AUAudioUnitBusArray? = nil;
    private var outputBusArray : AUAudioUnitBusArray? = nil;
    private var sampleRate : Float { return Float(kernelAdapter.outputBus.format.sampleRate); };
    
    private(set) public var masterTuning : Float = 0.0;
    private(set) public var masterAmp : Float = 1.0;
    private(set) public var oscillators : [Oscillator] = []
    
    /**
        AudioUnit Constructor. Creates all of the parameters, sets their default values and configures the input / output buses
     */
    public override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        try! super.init(componentDescription: componentDescription, options: options)
        _krnl = SynthAUDSPKernelAdapter(audioUnit: self);
        
        // Create parameters
        let masterTuning = AUParameterTree.createParameter(withIdentifier: "masterTuning", name: "Master Tuning", address: Parameters.masterTuning.rawValue, min: -25.0, max: 25.0, unit: AudioUnitParameterUnit.hertz, unitName: "Hz", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let masterAmp = AUParameterTree.createParameter(withIdentifier: "masterAmp", name: "Master Amplitude", address: Parameters.masterAmp.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1Bypass = AUParameterTree.createParameter(withIdentifier: "osc1Bypass", name: "Oscillator 1 Bypass", address: Parameters.osc1Bypass.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.boolean, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env1Attack = AUParameterTree.createParameter(withIdentifier: "env1Attack", name: "Envelope 1 Attack", address: Parameters.env1Attack.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env1Decay = AUParameterTree.createParameter(withIdentifier: "env1Decay", name: "Envelope 1 Decay", address: Parameters.env1Decay.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env1Sustain = AUParameterTree.createParameter(withIdentifier: "env1Sustain", name: "Envelope 1 Sustain", address: Parameters.env1Sustain.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env1Release = AUParameterTree.createParameter(withIdentifier: "env1Release", name: "Envelope 1 Release", address: Parameters.env1Release.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1Semi = AUParameterTree.createParameter(withIdentifier: "osc1Semi", name: "Oscillator 1 semitone shift", address: Parameters.osc1Semi.rawValue, min: -4.0, max: 4.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1Oct = AUParameterTree.createParameter(withIdentifier: "osc1Oct", name: "Oscillator 1 octave shift", address: Parameters.osc1Oct.rawValue, min: -4.0, max: 4.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1Amp = AUParameterTree.createParameter(withIdentifier: "osc1Amp", name: "Oscillator 1 amplitude", address: Parameters.osc1Amp.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1Tuning = AUParameterTree.createParameter(withIdentifier: "osc1Tuning", name: "Oscillator 1 tuning", address: Parameters.osc1Tuning.rawValue, min: -25.0, max: 25.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        
        let osc2Bypass = AUParameterTree.createParameter(withIdentifier: "osc2Bypass", name: "Oscillator 2 Bypass", address: Parameters.osc2Bypass.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.boolean, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env2Attack = AUParameterTree.createParameter(withIdentifier: "env2Attack", name: "Envelope 2 Attack", address: Parameters.env2Attack.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env2Decay = AUParameterTree.createParameter(withIdentifier: "env2Decay", name: "Envelope 2 Decay", address: Parameters.env2Decay.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env2Sustain = AUParameterTree.createParameter(withIdentifier: "env2Sustain", name: "Envelope 2 Sustain", address: Parameters.env2Sustain.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let env2Release = AUParameterTree.createParameter(withIdentifier: "env2Release", name: "Envelope 2 Release", address: Parameters.env2Release.rawValue, min: 0.0, max: 5.0, unit: AudioUnitParameterUnit.seconds, unitName: "s", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2Semi = AUParameterTree.createParameter(withIdentifier: "osc2Semi", name: "Oscillator 2 semitone shift", address: Parameters.osc2Semi.rawValue, min: -4.0, max: 4.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2Oct = AUParameterTree.createParameter(withIdentifier: "osc2Oct", name: "Oscillator 2 octave shift", address: Parameters.osc2Oct.rawValue, min: -4.0, max: 4.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2Amp = AUParameterTree.createParameter(withIdentifier: "osc2Amp", name: "Oscillator 2 amplitude", address: Parameters.osc2Amp.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2Tuning = AUParameterTree.createParameter(withIdentifier: "osc2Tuning", name: "Oscillator 2 tuning", address: Parameters.osc2Tuning.rawValue, min: -25.0, max: 25.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        
        let osc1FilCutoff = AUParameterTree.createParameter(withIdentifier: "osc1FilCutoff", name: "Oscillator 1 filter cutoff", address: Parameters.osc1FilCutoff.rawValue, min: 20.0, max: 5000.0, unit: AudioUnitParameterUnit.hertz, unitName: "Hz", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1FilQ = AUParameterTree.createParameter(withIdentifier: "osc1FilQ", name: "Oscillator 1 filter Q", address: Parameters.osc1FilQ.rawValue, min: 0.1, max: 10.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc1FilBypass = AUParameterTree.createParameter(withIdentifier: "osc1FilBypass", name: "Oscillator 1 filter bypass", address: Parameters.osc1FilBypass.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.boolean, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        
        let osc2FilCutoff = AUParameterTree.createParameter(withIdentifier: "osc2FilCutoff", name: "Oscillator 2 filter cutoff", address: Parameters.osc2FilCutoff.rawValue, min: 20.0, max: 5000.0, unit: AudioUnitParameterUnit.hertz, unitName: "Hz", flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2FilQ = AUParameterTree.createParameter(withIdentifier: "osc2FilQ", name: "Oscillator 2 filter Q", address: Parameters.osc2FilQ.rawValue, min: 0.1, max: 10.0, unit: AudioUnitParameterUnit.generic, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        let osc2FilBypass = AUParameterTree.createParameter(withIdentifier: "osc2FilBypass", name: "Oscillator 2 filter bypass", address: Parameters.osc2FilBypass.rawValue, min: 0.0, max: 1.0, unit: AudioUnitParameterUnit.boolean, unitName: nil, flags: AudioUnitParameterOptions(rawValue: 0), valueStrings: nil, dependentParameters: nil);
        
        parameterTree = AUParameterTree.createTree(withChildren: [masterTuning, masterAmp, osc1Bypass, env1Attack, env1Decay, env1Sustain, env1Release, osc2Bypass, env2Attack, env2Decay, env2Sustain, env2Release, osc1Semi, osc1Oct, osc2Semi, osc2Oct, osc1Amp, osc1Tuning, osc2Amp, osc2Tuning, osc1FilBypass, osc1FilCutoff, osc1FilQ, osc2FilBypass, osc2FilCutoff, osc2FilQ]);
        
        self.maximumFramesToRender = kernelAdapter.maximumFramesToRender;
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.input, busses: [kernelAdapter.inputBus.bus]);
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [kernelAdapter.outputBus]);
        
        setupParametersCallbacks()
        
        for _ in 0 ..< 2 {
            oscillators.append(Oscillator(sampleRate: sampleRate));
        }
        
        oscillators[0].setSignalFunction(function: Signals.sawtoothDown);
        oscillators[0].signalFunctionName = "Sawtooth";
        
        // Set default parameters
        setParameterValue(Parameters.osc1Bypass, value: Parameters.Defaults.osc1Bypass);
        setParameterValue(Parameters.env1Attack, value: Parameters.Defaults.env1Attack);
        setParameterValue(Parameters.env1Decay, value: Parameters.Defaults.env1Decay);
        setParameterValue(Parameters.env1Sustain, value: Parameters.Defaults.env1Sustain);
        setParameterValue(Parameters.env1Release, value: Parameters.Defaults.env1Release);
        setParameterValue(Parameters.osc1Semi, value: Parameters.Defaults.osc1Semi);
        setParameterValue(Parameters.osc1Oct, value: Parameters.Defaults.osc1Oct);
        setParameterValue(Parameters.osc1Amp, value: Parameters.Defaults.osc1Amp);
        setParameterValue(Parameters.osc1Tuning, value: Parameters.Defaults.osc1Tuning);
        
        setParameterValue(Parameters.osc2Bypass, value: Parameters.Defaults.osc2Bypass);
        setParameterValue(Parameters.env2Attack, value: Parameters.Defaults.env2Attack);
        setParameterValue(Parameters.env2Decay, value: Parameters.Defaults.env2Decay);
        setParameterValue(Parameters.env2Sustain, value: Parameters.Defaults.env2Sustain);
        setParameterValue(Parameters.env2Release, value: Parameters.Defaults.env2Release);
        setParameterValue(Parameters.osc2Semi, value: Parameters.Defaults.osc2Semi);
        setParameterValue(Parameters.osc2Oct, value: Parameters.Defaults.osc2Oct);
        setParameterValue(Parameters.osc2Amp, value: Parameters.Defaults.osc2Amp);
        setParameterValue(Parameters.osc2Tuning, value: Parameters.Defaults.osc2Tuning);
        
        setParameterValue(Parameters.osc1FilBypass, value: Parameters.Defaults.osc1FilBypass);
        setParameterValue(Parameters.osc1FilQ, value: Parameters.Defaults.osc1FilQ);
        setParameterValue(Parameters.osc1FilCutoff, value: Parameters.Defaults.osc1FilCutoff);
        
        setParameterValue(Parameters.osc2FilBypass, value: Parameters.Defaults.osc2FilBypass);
        setParameterValue(Parameters.osc2FilQ, value: Parameters.Defaults.osc2FilQ);
        setParameterValue(Parameters.osc2FilCutoff, value: Parameters.Defaults.osc2FilCutoff);
        
        setParameterValue(Parameters.masterTuning, value: Parameters.Defaults.masterTuning);
        setParameterValue(Parameters.masterAmp, value: Parameters.Defaults.masterAmp);
        
    }
    
    /**
     Updates the signal's function being played by the target oscillator.
     
     - parameters:
     - signal: The function used to generate the signal
     - forOsc: The target oscillator index
     - name: The new function display name
     
     */
    public func updateSignal(_ signal : @escaping (Float) -> Float, forOsc: Int, name: String) -> Void{
        
        let osc = getOscillator(index: forOsc);
        osc?.setSignalFunction(function: signal);
        osc?.signalFunctionName = name;
        
    }
    
    /**
     Updates the signal's function being played by the target oscillator.
     
     - parameter forOsc: The target oscillator index
     
     - Returns: A tuple containing the oscillator's function and it's display name
     */
    public func getSignalInfo(forOsc: Int) -> (String, (Float) -> Float)? {
        
        let osc = getOscillator(index: forOsc);
        if (osc == nil) { return nil; }
        return (osc!.signalFunctionName, osc!.signalFunction);
        
    }
    
    /**
     Instantly stops all signals being generated.
     */
    public func panic() -> Void{
        
        for osc in oscillators {
            osc.killAll();
        }
        
    }
    
    /**
     Gets a parameter minimal value.
     - parameter parameter: The target parameter (Always valid as it comes from our enum).
     
     - Returns: The parameter's min value.
     */
    public func getParameterMinValue(_ parameter: Parameters) -> AUValue {
        return parameterTree!.parameter(withAddress: parameter.rawValue)!.minValue;
    }
    
    /**
     Gets a parameter maximal value.
     - parameter parameter: The target parameter (Always valid as it comes from our enum).
     
     - Returns: The parameter's max value.
     */
    public func getParameterMaxValue(_ parameter: Parameters) -> AUValue {
        return parameterTree!.parameter(withAddress: parameter.rawValue)!.maxValue;
    }
    
    
    /**
     Gets a parameter's unit name.
     - parameter parameter: The target parameter (Always valid as it comes from our enum).
     
     - Returns: The parameter's unit name.
     */
    public func getParameterUnitName(_ parameter: Parameters) -> String {
        return parameterTree!.parameter(withAddress: parameter.rawValue)!.unitName ?? "";
    }
    
    /**
     Gets a parameter value.
     - parameter parameter: The target parameter (Always valid as it comes from our enum).
     
     - Returns: The parameter's value.
     */
    public func getParameterValue(_ parameter: Parameters) -> AUValue {
        return parameterTree!.parameter(withAddress: parameter.rawValue)!.value;
    }
    
    /**
     Sets a parameter value.
     
     - Parameters:
     - parameter: The target parameter (Always valid as it comes from our enum).
     - value: The value to set.
     */
    public func setParameterValue(_ parameter: Parameters, value: AUValue) -> Void {
        parameterTree!.parameter(withAddress: parameter.rawValue)!.value = value;
    }
    
    /**
     Exhaustive function that gets a parameter default value with a validity check.
     
     - parameter param: The target parameter.
     
     - Returns: The param default value.
     */
    public func getDefaultParameterValue(_ param: Parameters) -> AUValue{
        
        switch param {
        
        case Parameters.masterAmp:
            return Parameters.Defaults.masterAmp;
        case Parameters.masterTuning:
            return Parameters.Defaults.masterTuning;
            
        case Parameters.osc1Bypass:
            return Parameters.Defaults.osc1Bypass;
        case Parameters.osc1Oct:
            return Parameters.Defaults.osc1Oct;
        case Parameters.osc1Semi:
            return Parameters.Defaults.osc1Semi;
        case Parameters.env1Attack:
            return Parameters.Defaults.env1Attack;
        case Parameters.env1Decay:
            return Parameters.Defaults.env1Decay;
        case Parameters.env1Sustain:
            return Parameters.Defaults.env1Sustain;
        case Parameters.env1Release:
            return Parameters.Defaults.env1Release;
        case Parameters.osc1Amp:
            return Parameters.Defaults.osc1Amp;
        case Parameters.osc1Tuning:
            return Parameters.Defaults.osc1Tuning;
            
        case Parameters.osc2Bypass:
            return Parameters.Defaults.osc2Bypass;
        case Parameters.osc2Oct:
            return Parameters.Defaults.osc2Oct;
        case Parameters.osc2Semi:
            return Parameters.Defaults.osc2Semi;
        case Parameters.env2Attack:
            return Parameters.Defaults.env2Attack;
        case Parameters.env2Decay:
            return Parameters.Defaults.env2Decay;
        case Parameters.env2Sustain:
            return Parameters.Defaults.env2Sustain;
        case Parameters.env2Release:
            return Parameters.Defaults.env2Release;
        case Parameters.osc2Amp:
            return Parameters.Defaults.osc2Amp;
        case Parameters.osc2Tuning:
            return Parameters.Defaults.osc2Tuning;
            
            
        case Parameters.osc1FilBypass:
            return Parameters.Defaults.osc1FilBypass;
        case Parameters.osc1FilCutoff:
            return Parameters.Defaults.osc1FilCutoff;
        case Parameters.osc1FilQ:
            return Parameters.Defaults.osc1FilQ;
            
        case Parameters.osc2FilBypass:
            return Parameters.Defaults.osc2FilBypass;
        case Parameters.osc2FilCutoff:
            return Parameters.Defaults.osc2FilCutoff;
        case Parameters.osc2FilQ:
            return Parameters.Defaults.osc2FilQ;
            
        }
        
    }
    
    /**
     Exhaustive function that sets a parameter value with a validity check.
     
     - Parameters:
     - param: The target parameter.
     - value: The value to set.
     */
    private func setParameter(param: AUParameter, value: AUValue){
        
        if(Parameters(rawValue: param.address) == nil) { return; }
        
        switch Parameters(rawValue: param.address)! {
        
        case Parameters.masterAmp:
            return masterAmp = value;
        case Parameters.masterTuning:
            return masterTuning = value;
            
        case Parameters.osc1Bypass:
            getOscillator(index: 0)!.setBypassed(value != 0);
        case Parameters.osc1Oct:
            getOscillator(index: 0)!.setOctShift(Int(value));
        case Parameters.osc1Semi:
            getOscillator(index: 0)!.setSemiShift(Int(value));
        case Parameters.env1Attack:
            getOscillator(index: 0)!.setEnvelopeAttack(value); return;
        case Parameters.env1Decay:
            getOscillator(index: 0)!.setEnvelopeDecay(value); return;
        case Parameters.env1Sustain:
            getOscillator(index: 0)!.setEnvelopeSustain(value); return;
        case Parameters.env1Release:
            getOscillator(index: 0)!.setEnvelopeRelease(value); return;
        case Parameters.osc1Amp:
            getOscillator(index: 0)!.setAmplitude(value); return;
        case Parameters.osc1Tuning:
            getOscillator(index: 0)!.setTuning(value); return;
            
            
        case Parameters.osc2Bypass:
            getOscillator(index: 1)!.setBypassed(value != 0);
        case Parameters.osc2Oct:
            getOscillator(index: 1)!.setOctShift(Int(value));
        case Parameters.osc2Semi:
            getOscillator(index: 1)!.setSemiShift(Int(value));
        case Parameters.env2Attack:
            getOscillator(index: 1)!.setEnvelopeAttack(value); return;
        case Parameters.env2Decay:
            getOscillator(index: 1)!.setEnvelopeDecay(value); return;
        case Parameters.env2Sustain:
            getOscillator(index: 1)!.setEnvelopeSustain(value); return;
        case Parameters.env2Release:
            getOscillator(index: 1)!.setEnvelopeRelease(value); return;
        case Parameters.osc2Amp:
            getOscillator(index: 1)!.setAmplitude(value); return;
        case Parameters.osc2Tuning:
            getOscillator(index: 1)!.setTuning(value); return;
            
        case Parameters.osc1FilBypass:
            getOscillator(index: 0)!.getFilter().setBypassed(value != 0); return;
        case Parameters.osc1FilCutoff:
            getOscillator(index: 0)!.getFilter().setCutoffFrequency(value); return;
        case Parameters.osc1FilQ:
            getOscillator(index: 0)!.getFilter().setQ(value); return;
            
        case Parameters.osc2FilBypass:
            getOscillator(index: 1)!.getFilter().setBypassed(value != 0); return;
        case Parameters.osc2FilCutoff:
            getOscillator(index: 1)!.getFilter().setCutoffFrequency(value); return;
        case Parameters.osc2FilQ:
            getOscillator(index: 1)!.getFilter().setQ(value); return;
            
        }
        
    }
    
    /**
     Exhaustive function that gets a parameter value with a validity check.
     
     - parameter param: The target parameter.
     
     - Returns: The param value if the input value is valid, otherwise 0.0.
     */
    private func getParameter(param: AUParameter) -> AUValue{
        
        if(Parameters(rawValue: param.address) == nil) { return 0.0; }
        
        switch Parameters(rawValue: param.address)! {
        
        case Parameters.masterAmp:
            return AUValue(masterAmp);
        case Parameters.masterTuning:
            return AUValue(masterTuning);
            
        case Parameters.osc1Bypass:
            return getOscillator(index: 0)!.bypassed ? 1.0 : 0.0;
        case Parameters.osc1Oct:
            return AUValue(getOscillator(index: 0)!.octShift);
        case Parameters.osc1Semi:
            return AUValue(getOscillator(index: 0)!.semiShift);
        case Parameters.env1Attack:
            return AUValue(getOscillator(index: 0)!.envAttack);
        case Parameters.env1Decay:
            return AUValue(getOscillator(index: 0)!.envDecay);
        case Parameters.env1Sustain:
            return AUValue(getOscillator(index: 0)!.envSustain);
        case Parameters.env1Release:
            return AUValue(getOscillator(index: 0)!.envRelease);
        case Parameters.osc1Amp:
            return AUValue(getOscillator(index: 0)!.amplitude);
        case Parameters.osc1Tuning:
            return AUValue(getOscillator(index: 0)!.tuning);
            
        case Parameters.osc2Bypass:
            return getOscillator(index: 1)!.bypassed ? 1.0 : 0.0;
        case Parameters.osc2Oct:
            return AUValue(getOscillator(index: 1)!.octShift);
        case Parameters.osc2Semi:
            return AUValue(getOscillator(index: 1)!.semiShift);
        case Parameters.env2Attack:
            return AUValue(getOscillator(index: 1)!.envAttack);
        case Parameters.env2Decay:
            return AUValue(getOscillator(index: 1)!.envDecay);
        case Parameters.env2Sustain:
            return AUValue(getOscillator(index: 1)!.envSustain);
        case Parameters.env2Release:
            return AUValue(getOscillator(index: 1)!.envRelease);
        case Parameters.osc2Amp:
            return AUValue(getOscillator(index: 1)!.amplitude);
        case Parameters.osc2Tuning:
            return AUValue(getOscillator(index: 1)!.tuning);
            
        case Parameters.osc1FilBypass:
            return getOscillator(index: 0)!.getFilter().bypassed() ? 1.0 : 0.0;
        case Parameters.osc1FilCutoff:
            return getOscillator(index: 0)!.getFilter().getCutoffFrequency();
        case Parameters.osc1FilQ:
            return getOscillator(index: 0)!.getFilter().getQ();
            
        case Parameters.osc2FilBypass:
            return getOscillator(index: 1)!.getFilter().bypassed() ? 1.0 : 0.0;
        case Parameters.osc2FilCutoff:
            return getOscillator(index: 1)!.getFilter().getCutoffFrequency();
        case Parameters.osc2FilQ:
            return getOscillator(index: 1)!.getFilter().getQ();
        }
        
    }
    
    /**
     Safe oscillator getter
     
     - parameter index: The target oscillator's index.
     
     - Returns: An optional oscillator value (nil if the index is invalid)
     */
    private func getOscillator(index: Int) -> Oscillator? {
        return index >= 0 && index < oscillators.count ? oscillators[index] : nil;
    }
    
    
    /**
     Adds an oscillator to the process array.
     
     - parameter osc: The new oscillator to add.
     
     */
    private func addOscillator(osc: Oscillator) -> Void{
        oscillators.append(osc);
    }
    
    /**
     Function called when a note is pressed on the MIDI Controller
     
     - parameters:
     - noteNumber: The pressed note number
     - velocity: The pressed note velocity
     */
    public func onNoteOn(noteNumber: Int, velocity: Int) -> Void{
        
        for osc in oscillators{
            osc.onNoteOn(noteNumber: noteNumber, velocity: velocity);
        }
        
    }
    
    /**
     Function called when a note is released on the MIDI Controller
     
     - parameter noteNumber: The released note number
     
     */
    public func onNoteOff(noteNumber: Int) -> Void{
        
        for osc in oscillators{
            osc.onNoteOff(noteNumber: noteNumber);
        }
        
    }
    
    /**
     Instantly stops all signals being played.
     */
    public func killAll() -> Void{
        
        for osc in oscillators {
            osc.killAll();
        }
        
    }
    
    /**
     Function called when the app quits.
     */
    public func onShutdown(){
        for osc in oscillators {
            osc.killAll();
        }
    }
    
    /**
     Sets up the internal parameter callbacks.
     */
    internal func setupParametersCallbacks() -> Void{
        
        parameterTree?.implementorValueObserver = { [slf = self] (param, value) in
            slf.setParameter(param: param, value: value);
        }
        
        parameterTree?.implementorValueProvider = { [slf = self] (param) in
            return slf.getParameter(param: param);
        }
        
        parameterTree?.implementorStringFromValueCallback = { (param, valuePtr) in
            
            let value = valuePtr == nil ? param.value : valuePtr!.pointee;
            return String(format: "%.f", value);
        }
        
    }
    
    // MARK: Overriden AUAudioUnit functions
    
    public override var internalRenderBlock: AUInternalRenderBlock {
        return kernelAdapter.internalRenderBlock()
    }
    
    public override func deallocateRenderResources() {
        kernelAdapter.deallocateRenderResources();
        super.deallocateRenderResources();
    }
    
    public override var canProcessInPlace: Bool {
        return true
    }
    
    public override var inputBusses: AUAudioUnitBusArray{
        return inputBusArray!;
    }
    
    public override var outputBusses: AUAudioUnitBusArray {
        return outputBusArray!;
    }
    
    public override func allocateRenderResources() throws {
        
        if(kernelAdapter.outputBus.format.channelCount != kernelAdapter.inputBus.bus.format.channelCount){
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(kAudioUnitErr_FailedInitialization), userInfo: nil);
        }
        
        kernelAdapter.allocateRenderResources();
        
        do{
            try super.allocateRenderResources();
        }
        catch let error as NSError{
            throw error;
        }
        
    }
    
}
