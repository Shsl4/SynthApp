import Foundation
import CoreMIDI
import UIKit

/**
    Class that manages MIDI connections and event reception.
 */
public class MIDIManager{
    
    private(set) var deviceID : Int = -1;
    private(set) var device : MIDIDeviceRef = 0;
    private(set) var entity : MIDIEntityRef = 0;
    private(set) var endpoint : MIDIEndpointRef = 0;
    private(set) var clientRef : MIDIClientRef = 0;
    private(set) var portRef : MIDIPortRef = 0;
    private(set) var deviceName : String = "None";
    
    public init() {
        
        // Setup a MIDI client
        MIDIClientCreate("SynthPlayground" as CFString, nil, nil, &clientRef);
        
        // Try to open the last known MIDI device on initialization.
        let devices = MIDIManager.getValidMIDIDevices();
        if(devices.count >= 1){
            _ = openMIDIDevice(deviceID: devices[devices.count - 1].1, entityID: devices[devices.count - 1].2);
            
        }
        
    }
    
    public func hasActiveDevice() -> Bool{
        return deviceID != -1;
    }
    
    public func closeActiveMIDIDevice() -> Void {
        
        MIDIPortDisconnectSource(portRef, endpoint);
        MIDIPortDispose(portRef);
        MIDIDeviceDispose(device);
        deviceName = "None";
        device = 0;
        entity = 0;
        endpoint = 0;
        portRef = 0;
        deviceID = -1;
        audioEngine.getAudioUnit().killAll();
        
    }
    
    public func hasActiveMIDIDevice() -> Bool{
        return device != 0;
    }
    
    public func openMIDIDevice(deviceID: Int, entityID: Int) -> Bool{
        
        if(internal_openMIDIDevice(deviceID: deviceID, entityID: entityID)){
            return true;
            
        }
        
        closeActiveMIDIDevice();
        return false;
        
    }
    
    func receiveMIDIEvents(a : UnsafePointer<MIDIEventList>, b: UnsafeMutableRawPointer?) -> Void{
        
        let packet = a.pointee.packet;
        let noteNumber = Int(MIDIManager.getNoteNumber(packet: packet));
        let velocity : Int = Int(MIDIManager.getVelocity(packet: packet));
        
        if(MIDIManager.isNoteOn(packet: packet)){
            audioEngine.getAudioUnit().onNoteOn(noteNumber: noteNumber, velocity: velocity);
        }
        else if(MIDIManager.isNoteOff(packet: packet)){
            audioEngine.getAudioUnit().onNoteOff(noteNumber: noteNumber)
        }
        
    }
    
    func internal_openMIDIDevice(deviceID: Int, entityID: Int) -> Bool{
        
        if(hasActiveMIDIDevice()){
            closeActiveMIDIDevice();
        }
        
        self.deviceID = deviceID;
        
        device = MIDIGetDevice(deviceID);
        
        if(device == 0) { return false; }
        
        entity = MIDIDeviceGetEntity(device, entityID);
        
        if(entity == 0) { return false; }
        
        endpoint = MIDIEntityGetSource(entity, 0);
        
        if(endpoint == 0) { return false; }
        
        let code = MIDIInputPortCreateWithProtocol(clientRef, "PlaygroundPort" as CFString, MIDIManager.getDeviceProtocolID(device: device), &portRef, receiveMIDIEvents);
        
        if(code != 0) { return false; }
        
        if(MIDIPortConnectSource(portRef, endpoint, &endpoint) != 0) { return false; }
        
        for tuple in MIDIManager.getValidMIDIDevices() {
            if(tuple.1 == deviceID && tuple.2 == entityID){
                deviceName = tuple.0;
                break;
            }
        }
        
        return true;
        
    }
    
    public static func uint32ToByteArray(num: UInt32) -> [UInt8]{
        
        var copy = num;
        let bytePtr = withUnsafePointer(to: &copy) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size) {
                UnsafeBufferPointer(start: $0, count: MemoryLayout<UInt32>.size)
            }
        }
        
        return Array(bytePtr);
        
    }
    
    public static func isNoteOn(packet: MIDIEventPacket) -> Bool {
        
        return uint32ToByteArray(num: packet.words.0)[2] == 144;
        
    }
    
    
    public static func isNoteOff(packet: MIDIEventPacket) -> Bool {
        
        let val = uint32ToByteArray(num: packet.words.0)[2];
        return val == 128;
        
    }
    
    public static func getNoteNumber(packet : MIDIEventPacket) -> UInt8 {
        
        return uint32ToByteArray(num: packet.words.0)[1];
        
    }
    
    
    public static func getVelocity(packet : MIDIEventPacket) -> UInt8 {
        
        return uint32ToByteArray(num: packet.words.0)[0];
        
    }
    
    
    public static func isDeviceOnline(device: MIDIDeviceRef) -> Bool {
        
        var returnCode : Int32 = 0;
        
        if (MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &returnCode) == noErr){
            return returnCode == 0;
        }
        
        return false;
        
        
    }
    
    public static func getDeviceProtocolID(device: MIDIDeviceRef) -> MIDIProtocolID{
        
        var protocolID : Int32 = 1;
        
        if (MIDIObjectGetIntegerProperty(device, kMIDIPropertyProtocolID, &protocolID) == noErr){
            return protocolID == 1 ? MIDIProtocolID._1_0 : MIDIProtocolID._2_0;
        }
        
        return MIDIProtocolID._1_0;
        
    }
    public static func getMIDINoteFrequencyInHertz(_ baseFrequency : Float = 440.0, noteNumber: Int) -> Float {
        
        return (baseFrequency * pow(2.0, (Float(noteNumber) - 68.0) / 12.0));
        
    }
    
    public static func getValidMIDIDevices() -> [(String, Int, Int)]{
        
        var returnValue : [(String, Int, Int)] = [];
        
        for i in 0 ..< MIDIGetNumberOfDevices(){
            
            let dev = MIDIGetDevice(i);
            
            if(!MIDIManager.isDeviceOnline(device: dev)) { continue; }
            
            let entityCount = MIDIDeviceGetNumberOfEntities(MIDIGetDevice(i));
            
            if(entityCount > 0){
                
                for j in 0 ..< MIDIDeviceGetNumberOfEntities(dev){
                    
                    let entity = MIDIDeviceGetEntity(dev, j)
                    let dest = MIDIEntityGetDestination(entity, 0);
                    
                    var destName : Unmanaged<CFString>?;
                    var devName : Unmanaged<CFString>?;
                    
                    MIDIObjectGetStringProperty(dest, kMIDIPropertyName, &destName);
                    MIDIObjectGetStringProperty(dev, kMIDIPropertyName, &devName);
                    
                    let a = String(devName!.takeUnretainedValue())
                    let b = String(destName!.takeUnretainedValue())
                    
                    returnValue.append(((String.localizedStringWithFormat("%@ (%@)", a, b)), i, j))
                    
                }
                
            }
            
        }
        
        return returnValue;
        
    }
    
}
