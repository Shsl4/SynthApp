//
//  DSPKernel.swift
//  SynthAU
//
//  Created by Pierre Juliot on 11/04/2021.
//

import Foundation
import AudioToolbox

/**
    This file is part of the AudioUnit basecode. I modified it to my needs and translated it to raw Swift in order to make it work in Swift Playgrounds.
 */

class DSPKernel{
    
    public var maxFramesToRender : AUAudioFrameCount = 1024;
    
    public func process(_ frameCount: AUAudioFrameCount, _ bufferOffset: AUAudioFrameCount) -> Void{
        
    }
    
    public func handleMIDIEvent(_ midiEvent: AUMIDIEvent) -> Void { }
    public func handleParameterEvent(_ parameterEvent: AUParameterEvent) -> Void { }
    
    public func processWithEvents(_ timestamp: UnsafePointer<AudioTimeStamp>, _ frameCount: AUAudioFrameCount, _ events: UnsafePointer<AURenderEvent>?, _ midiOut: AUMIDIOutputEventBlock?) -> Void {
        var now : AUEventSampleTime = AUEventSampleTime(timestamp.pointee.mSampleTime);
        var framesRemaining = frameCount;
        let event = events;
        
        while (framesRemaining > 0) {
            // If there are no more events, we can process the entire remaining segment and exit.
            if (event == nil) {
                let bufferOffset = frameCount - framesRemaining;
                process(framesRemaining, bufferOffset);
                return;
            }

            // **** start late events late.
            let timeZero = AUEventSampleTime(0);
            let headEventTime = event!.pointee.head.eventSampleTime;
            let framesThisSegment = AUAudioFrameCount(max(timeZero, headEventTime - now));

            // Compute everything before the next event.
            if (framesThisSegment > 0) {
                let bufferOffset = frameCount - framesRemaining;
                process(framesThisSegment, bufferOffset);

                // Advance frames.
                framesRemaining -= framesThisSegment;

                // Advance time.
                now += AUEventSampleTime(framesThisSegment);
            }

            performAllSimultaneousEvents(now, event!, midiOut);
        }
        
        
    }
    
    private func handleOneEvent(_ event: AURenderEvent){
        switch event.head.eventType {
            case .parameter:
                handleParameterEvent(event.parameter)
            case .MIDI:
                handleMIDIEvent(event.MIDI)
            default:
                break
        }
    }
    
    private func performAllSimultaneousEvents(_ now: AUEventSampleTime, _ event: UnsafePointer<AURenderEvent>, _ midiOut: AUMIDIOutputEventBlock?) {
        
        var nextEvent : AURenderEvent = event.pointee;
        
        repeat {
            handleOneEvent(nextEvent)

            if nextEvent.head.eventType == AURenderEventType.MIDI && midiOut != nil {
                
                var dataPtr : UnsafePointer<UInt8>? = nil;
                
                withUnsafePointer(to: nextEvent.MIDI.data.0, { ptr in dataPtr = ptr; })
                
                _ = midiOut!(now, 0, Int(nextEvent.MIDI.length), dataPtr!)
            }
            
            if(nextEvent.head.next == nil) { break; }
            
            // Go to next event.
            nextEvent = event.pointee.head.next!.pointee;
            
            // While event is not null and is simultaneous (or late).
        } while event.pointee.head.eventSampleTime <= now
    }
    
}
