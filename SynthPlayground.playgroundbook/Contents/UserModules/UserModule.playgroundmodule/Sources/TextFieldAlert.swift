//
//  TextFieldAlert.swift
//  SynthApp
//
//  Created by Pierre Juliot on 17/04/2021.
//

import SwiftUI

struct TextFieldAlert: View {
    
    let title : String;
    let subtitle : String;
    let defaultText : String;
    let onSubmit : (String) -> Void;
    @State var input : String = "";
    @Binding var showingAlert : Bool;
    
    var body: some View {

        VStack{
            
            Text(title)
                .padding()
            
            Text(subtitle)
                
            TextField(defaultText, text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Divider()
            
            HStack{
                
                Button(action: { showingAlert = false; }, label: {
                    Text("Cancel");
                })
                
                Divider()
                
                Button(action: { onSubmit(input); showingAlert = false; }, label: {
                    Text("Submit");
                })
                
            }
            
            
        }
        
    }
}

struct TextFieldAlert_Previews: PreviewProvider {
    static var previews: some View {
        //TextFieldAlert()
        EmptyView()
    }
}
