//
//  SynthDSPKernel.swift
//  SynthAU
//
//  Created by Pierre Juliot on 11/04/2021.
//

import Foundation
import AudioToolbox
import CoreAudio

/**
    This file is part of the AudioUnit basecode. I modified it to my needs and translated it to raw Swift in order to make it work in Swift Playgrounds.
 */

class SynthDSPKernel: DSPKernel {

    private var channelCount: Int = 0
    private var sampleRate: Float = 0
    private var inBufferList: UnsafeMutableAudioBufferListPointer?
    private var outBufferList: UnsafeMutableAudioBufferListPointer?
    private var audioUnit: SynthAudioUnit
    public var bypassed: Bool = false

    public init(audioUnit: SynthAudioUnit) {
        self.audioUnit = audioUnit
    }

    public func initialize(channelCount: Int, inSampleRate: Float, inAudioUnit: SynthAudioUnit) {
        self.channelCount = channelCount
        self.sampleRate = inSampleRate
    }

    public func reset() {
    }

    public func setBuffers(_ inBufferList: UnsafeMutablePointer<AudioBufferList>?, _ outBufferList: UnsafeMutablePointer<AudioBufferList>?) {
        self.inBufferList = UnsafeMutableAudioBufferListPointer(inBufferList)
        self.outBufferList = UnsafeMutableAudioBufferListPointer(outBufferList)
    }

    public override func process(_ frameCount: AUAudioFrameCount, _ bufferOffset: AUAudioFrameCount) {

        if bypassed { return; }

        outBufferList!.clear(startSample: bufferOffset, sampleCount: frameCount)

        for oscillator in audioUnit.oscillators {
            oscillator.fillBuffer(outBufferList!, frameCount, bufferOffset)
        }

    }

}
