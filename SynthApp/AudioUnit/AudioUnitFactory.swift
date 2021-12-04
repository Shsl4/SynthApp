//
//  AudioUnitFactory.swift
//  SynthAU
//
//  Created by Pierre Juliot on 11/04/2021.
//

import CoreAudio
import AudioToolbox
import AVFoundation

public class AudioUnitFactory: NSObject, AUAudioUnitFactory {

    var audioUnit: SynthAudioUnit?
    var avAudioUnit: AVAudioUnit?

	public func beginRequest(with context: NSExtensionContext) {

	}

    @objc public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {

        AUAudioUnit.registerSubclass(SynthAudioUnit.self,
                                     as: componentDescription,
                                     name: "SynthAU",
                                     version: UInt32.max)

        AVAudioUnit.instantiate(with: componentDescription) { audioUnit, error in
            guard error == nil, let audioUnit = audioUnit else {
                fatalError("Could not instantiate audio unit: \(String(describing: error))")
            }
            self.avAudioUnit = audioUnit
            self.audioUnit = audioUnit.auAudioUnit as? SynthAudioUnit
        }

        return audioUnit!
    }

}
