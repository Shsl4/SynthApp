//
//  MIDIDevicesView.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import SwiftUI

struct MIDIDevicesView : View{
    
    @State private var showingAlert = false
    @State private var tryOpen : (String, Int, Int) = ("None", -1, -1)
    @State var devices : [(String, Int, Int)] = MIDIManager.getValidMIDIDevices();
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View{
        
        List{
            
            Section(header: Text("Active Device")){
            
                HStack(alignment: .center){
                    Text(midiInstance.deviceName).foregroundColor(Color(UIColor.secondaryLabel))
                }

            }
            
            Section(header: Text("Devices")){
                
                if(devices.count > 0){
                    
                    ForEach(devices, id: \.0){ id in
                        Button(action: {
                            
                            tryOpen = id;
                            
                            if(midiInstance.openMIDIDevice(deviceID: tryOpen.1, entityID: tryOpen.2)){
                                
                                presentationMode.wrappedValue.dismiss()
                                
                            }
                            else{
                                showingAlert = true;
                            }
                            
                        })
                        {
                            Text(id.0)
                        }
                        .foregroundColor(Color.primary)
                        .alert(isPresented: $showingAlert){
                            Alert(title: Text("Failed to open device"), message: Text("Failed to open the device ".appending(tryOpen.0)), dismissButton: .default(Text("Dismiss")) {
                                presentationMode.wrappedValue.dismiss();
                            })
                        }
                        
                    }
                }
                else{
                    
                    Text("No devices available.")
                    
                }
                
            }
            
            if(midiInstance.hasActiveDevice()){
                
                Section(header: Text("Reset")){
                    
                    Button(action: {
                        
                        midiInstance.closeActiveMIDIDevice();
                        presentationMode.wrappedValue.dismiss();
                        
                    })
                    {
                        
                        HStack{
                            Spacer()
                            Text("Close Active Device")
                            Spacer()
                        }

                    }
                    .foregroundColor(Color.primary)
                    
                }
                
            }
            
        }
        .padding()
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("MIDI Device")
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color(colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground))

    }
    
}

struct MIDIDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        MIDIDevicesView().colorScheme(.dark)
        
    }
}
