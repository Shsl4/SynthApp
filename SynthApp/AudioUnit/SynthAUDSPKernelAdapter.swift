//
//  SynthAUDSPKernelAdapter.swift
//  SynthAU
//
//  Created by Pierre Juliot on 11/04/2021.
//

import Foundation
import AudioToolbox
import AVFoundation

/**
    This file is part of the AudioUnit basecode. I modified it to my needs and translated it to raw Swift in order to make it work in Swift Playgrounds.
 */

class SynthAUDSPKernelAdapter {

    let kernel: SynthDSPKernel
    var maximumFramesToRender: AUAudioFrameCount = 0
    let inputBus: BufferedInputBus
    var outputBus: AUAudioUnitBus
    var audioUnit: SynthAudioUnit?

    public init(audioUnit: SynthAudioUnit) {

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        self.audioUnit = audioUnit
        kernel = SynthDSPKernel(audioUnit: audioUnit)
        kernel.initialize(channelCount: Int(format.channelCount), inSampleRate: Float(format.sampleRate), inAudioUnit: audioUnit)
        inputBus = BufferedInputBus(defaultFormat: format, maxChannels: 8)
        outputBus = try! AUAudioUnitBus(format: format)
        outputBus.maximumChannelCount = 8

    }

    public func allocateRenderResources() {
        inputBus.allocateRenderResources(inMaxFrames: self.maximumFramesToRender)
        kernel.initialize(channelCount: Int(self.outputBus.format.channelCount), inSampleRate: Float(self.outputBus.format.sampleRate), inAudioUnit: audioUnit!)
        kernel.reset()
    }

    public func deallocateRenderResources() {
        inputBus.deallocateRenderResources()
    }

    public func internalRenderBlock() -> AUInternalRenderBlock {

        return { [state = kernel, input = inputBus] (_, timestamp, frameCount, _, outputData, realtimeEventListHead, _) in

            if frameCount > state.maxFramesToRender {
                return kAudioUnitErr_TooManyFramesToProcess
            }

            let inAudioBufferList = input.mutableAudioBufferList
            let outAudioBufferList = outputData

            state.setBuffers(inAudioBufferList, outAudioBufferList)
            state.processWithEvents(timestamp, frameCount, realtimeEventListHead, nil)

            return noErr

        }
    }
}
