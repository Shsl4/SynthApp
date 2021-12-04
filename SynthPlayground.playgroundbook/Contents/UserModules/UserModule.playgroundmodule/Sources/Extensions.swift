//
//  Extensions.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import CoreAudio
import Accelerate
import AudioUnit

extension String{
    
    /// Returns the character at the input index (string[index])
    public func at(index: Int) -> Character{
        
        return self[self.index(self.startIndex, offsetBy: index)];
        
    }
    
    public mutating func removeSubrange(range: ClosedRange<Int>) {
        
        self.removeSubrange(Range<String.Index>(NSRange(range), in: self)!)
        
    }
    
    public mutating func keepSubrange(range: ClosedRange<Int>){
        
        if(range.min() == nil || range.max() == nil) { return; }
        
        if(range.max()! < self.count){
            self.removeSubrange(range: range.max()! ... self.count - 1);
        }
        if(range.min()! > 0){
            self.removeSubrange(range: 0 ... range.min()!);
        }
        
    }
    
    public func keeping(range: ClosedRange<Int>) -> String{
        
        var copy = String(self);
        copy.keepSubrange(range: range);
        return copy;
        
    }
    
}

extension Array{
    
    public func getSubrange(range: Range<Int>) -> [Element]{
        
        var sub: [Element] = []
        
        for i in range {
            sub.append(self[i]);
        }
        
        return sub
        
    }
    
}

@usableFromInline class Math{
    
    @inlinable public static func abs<T: FloatingPoint>(_ val: T) -> T{
        return val >= 0 ? val : -val;
    }
    
}

extension UnsafeMutableAudioBufferListPointer{
    
    @inlinable func add(sample: Int, value: Float){
        
        for channel in self {
            channel.mData?.assumingMemoryBound(to: Float.self).advanced(by: sample).pointee += value;
        }
        
    }
    
    @inlinable func get(channel: Int, sample: Int) -> Float {
        return (self[channel].mData?.assumingMemoryBound(to: Float.self).advanced(by: sample).pointee)!;
    }
    
    @inlinable func clear(startSample: AUAudioFrameCount, sampleCount: AUAudioFrameCount) -> Void{
        for channel in 0 ..< self.count {
            vDSP_vclr((self[channel].mData?.assumingMemoryBound(to: Float.self).advanced(by: Int(startSample)))!, 1, vDSP_Length(sampleCount));
        }
    }
}
