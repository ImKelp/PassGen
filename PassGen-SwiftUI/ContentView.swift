//
//  ContentView.swift
//  PassGen-SwiftUI
//
//  Created by ColdBio on 11/06/2022.
//

import SwiftUI
import UIKit



struct ContentView: View {
    @State var passwordLength: Double = 0
    @State var generatedPassword = ""
    @State var includeNumbers = false
    @State var capitalLetters = false
    @State var specialCharaters = false
    @State var array: [String] = []
    @State var hidePasswords = false


    func passwordGenerator(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz0123456789"
        let upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let specialCharacters = "!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{}~"

        if specialCharaters && !capitalLetters {
            let result = (base + specialCharacters)
            return String(Array(0..<length).map { _ in result.randomElement()! })
        } else if capitalLetters && !specialCharaters {
            let result = base + upperCase
            return String(Array(0..<length).map { _ in result.randomElement()! })
        } else if specialCharaters && capitalLetters {
            let result = base + upperCase + specialCharacters
            return String(Array(0..<length).map { _ in result.randomElement()! })
        } else {
            return String(Array(0..<length).map { _ in base.randomElement()! })
        }
    }
    
    func copyToClipboard(input: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = input
    }
    
    func prevGeneratedPasswords() {
        if generatedPassword == "" {
            return
        }
        if array.contains(generatedPassword) {
            return
        }
        
        if array.count < 5 {
            array.append(generatedPassword)
        } else {
            array.removeFirst()
            array.append(generatedPassword)
        }
    }
    

    var body: some View {
        Form {
            Section(header: Text("Generate Password")) {
                VStack(alignment: .center) {
                    if !hidePasswords {
                        Text("\(generatedPassword)")
                        
                    } else {
                    SecureField("Enter Password..", text: $generatedPassword)
                        .disabled(true)
                    }
                }
            }
            
            Section(header: Text("Generate")) {
                    Button(action: {
                        copyToClipboard(input: generatedPassword)
                        prevGeneratedPasswords()
                    }) {
                        Text("Copy to Clipboard")
                }
            }
            
            Section(header: Text("Hide Passwords")) {
                Toggle(isOn: $hidePasswords) {
                    Text("Hide All Passwords")
                }
            }
            Section(header: Text("Password Length")) {
                HStack {
                    Slider(value: $passwordLength, in: 8...70)
                        .onChange(of: passwordLength) { newValue in
                            generatedPassword = passwordGenerator(length: Int(newValue))
                        }

                        
                    Text("\(passwordLength, specifier: "%0.0f")")
                }
            }

            Section(header: Text("Customise Password")) {
                Toggle(isOn: $capitalLetters) {
                    Text("Include Capital Letters")
                }
                Toggle(isOn: $specialCharaters) {
                    Text("Include Special Characters")
                }
            }
            
            Section(header: Text("Previously Generated Passwords")) {
                ForEach(array, id: \.self) { each in
                    HStack {
                        if !hidePasswords {
                            Text(each)
                        } else {
                            SecureField("Enter Password..", text: $generatedPassword)
                                .disabled(true)
                        }
                        Spacer()
                        Button(action: {print(each)}) {
                            Image(systemName: "doc.on.clipboard")
                        }
                    }
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}