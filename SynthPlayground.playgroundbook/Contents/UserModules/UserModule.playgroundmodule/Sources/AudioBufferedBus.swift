import AudioToolbox
import AVFoundation
import AudioUnit

/**
    This file is part of the AudioUnit basecode. I modified it to my needs and translated it to raw Swift in order to make it work in Swift Playgrounds.
 */

//MARK:- BufferedAudioBus Utility Class
// Utility classes to manage audio formats and buffers for an audio unit implementation's input and output audio busses.

// Reusable non-ObjC class, accessible from render thread.
class BufferedAudioBus {
    
    var bus : AUAudioUnitBus;
    var maxFrames: AUAudioFrameCount  = 0;
    
    var pcmBuffer : AVAudioPCMBuffer? = nil;
    var originalAudioBufferList: UnsafePointer<AudioBufferList>? = nil
    var mutableAudioBufferList : UnsafeMutablePointer<AudioBufferList>? = nil;

    public init(defaultFormat: AVAudioFormat, maxChannels: AVAudioChannelCount) {
        
        maxFrames = 0;
        pcmBuffer = nil;
        originalAudioBufferList = nil;
        mutableAudioBufferList = nil;
        
        bus = try! AUAudioUnitBus(format: defaultFormat);
        bus.maximumChannelCount = maxChannels;
        
    }

    public func allocateRenderResources(inMaxFrames: AUAudioFrameCount) -> Void  {
        
        maxFrames = inMaxFrames;
        pcmBuffer = AVAudioPCMBuffer(pcmFormat: bus.format, frameCapacity: maxFrames)!;
        originalAudioBufferList = pcmBuffer!.audioBufferList;
        mutableAudioBufferList = pcmBuffer!.mutableAudioBufferList;
        
    }
    
    public func deallocateRenderResources() -> Void {
        
        //originalAudioBufferList?.deallocate();
        //mutableAudioBufferList?.deallocate();
        
        pcmBuffer = nil;
        originalAudioBufferList = nil;
        mutableAudioBufferList = nil;

    }
    
};

// MARK:-  BufferedOutputBus: BufferedAudioBus
// MARK: prepareOutputBufferList()
/*
 BufferedOutputBus
 
 This class provides a prepareOutputBufferList method to copy the internal buffer pointers
 to the output buffer list in case the client passed in null buffer pointers.
 */
class BufferedOutputBus: BufferedAudioBus {
    
    public func prepareOutputBufferList(outBufferList: UnsafeMutablePointer<AudioBufferList>, frameCount: AVAudioFrameCount, zeroFill: Bool) {
        
        let byteSize = frameCount * UInt32(MemoryLayout.size(ofValue: Float.self));
        
        var bufA : UnsafeMutablePointer<AudioBuffer>? = nil;
        var bufB : UnsafePointer<AudioBuffer>? = nil;

        withUnsafeMutablePointer(to: &outBufferList.pointee.mBuffers, {ptr in
            bufA = ptr;
        })
        
        withUnsafePointer(to: originalAudioBufferList!.pointee.mBuffers, {ptr in
            bufB = ptr;
        })
        
        for i in 0 ..< outBufferList.pointee.mNumberBuffers {

            bufA!.advanced(by: Int(i)).pointee.mNumberChannels = bufB!.advanced(by: Int(i)).pointee.mNumberChannels;
            bufA!.advanced(by: Int(i)).pointee.mDataByteSize = byteSize;
            if (bufA!.advanced(by: Int(i)).pointee.mData == nil) {
                bufA!.advanced(by: Int(i)).pointee.mData = bufB!.advanced(by: Int(i)).pointee.mData;
            }
            if (zeroFill) {
                memset(bufA!.advanced(by: Int(i)).pointee.mData, 0, Int(byteSize));
            }
        }
    }
};

// MARK: -  BufferedInputBus: BufferedAudioBus
// MARK: pullInput()
// MARK: prepareInputBufferList()
/*
 BufferedInputBus
 
 This class manages a buffer into which an audio unit with input busses can
 pull its input data.
 */
class BufferedInputBus : BufferedAudioBus {
    /*
     Gets input data for this input by preparing the input buffer list and pulling
     the pullInputBlock.
     */
    func pullInput(_ actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                   _ timestamp: UnsafePointer<AudioTimeStamp>,
                   _ frameCount: AVAudioFrameCount,
                   _ inputBusNumber: Int,
                   _ pullInputBlock: AURenderPullInputBlock?) -> AUAudioUnitStatus {
        if (pullInputBlock == nil) {
            return kAudioUnitErr_NoConnection;
        }
        
        /*
         Important:
         The Audio Unit must supply valid buffers in (inputData.pointee.mBuffers[x].mData) and mDataByteSize.
         mDataByteSize must be consistent with frameCount.

         The AURenderPullInputBlock may provide input in those specified buffers, or it may replace
         the mData pointers with pointers to memory which it owns and guarantees will remain valid
         until the next render cycle.

         See prepareInputBufferList()
         */

        prepareInputBufferList(frameCount: frameCount);

        return pullInputBlock!(actionFlags, timestamp, frameCount, inputBusNumber, mutableAudioBufferList!);
    }
    
    /*
     prepareInputBufferList populates the mutableAudioBufferList with the data
     pointers from the originalAudioBufferList.
     
     The upstream audio unit may overwrite these with its own pointers, so each
     render cycle this function needs to be called to reset them.
     */
    
    func prepareInputBufferList(frameCount: UInt32) -> Void {
        
        let byteSize = min(frameCount, maxFrames) * UInt32(MemoryLayout.size(ofValue: Float.self));
        mutableAudioBufferList!.pointee.mNumberBuffers = originalAudioBufferList!.pointee.mNumberBuffers;

        for i in 0 ..< originalAudioBufferList!.pointee.mNumberBuffers {
            
            var bufA : UnsafeMutablePointer<AudioBuffer>? = nil;
            var bufB : UnsafePointer<AudioBuffer>? = nil;

            withUnsafeMutablePointer(to: &mutableAudioBufferList!.pointee.mBuffers, { ptr in
                bufA = ptr;
            })
            
            withUnsafePointer(to: originalAudioBufferList!.pointee.mBuffers, { ptr in
                bufB = ptr;
            })
            
            bufA!.advanced(by: Int(i)).pointee.mNumberChannels = bufB!.advanced(by: Int(i)).pointee.mNumberChannels;
            bufA!.advanced(by: Int(i)).pointee.mData = bufB!.advanced(by: Int(i)).pointee.mData;
            bufA!.advanced(by: Int(i)).pointee.mDataByteSize = byteSize;
            
        }
    }
};
