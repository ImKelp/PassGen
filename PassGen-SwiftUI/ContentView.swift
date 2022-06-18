//
//  ContentView.swift
//  PassGen-SwiftUI
//
//  Created by ColdBio on 11/06/2022.
//

import SwiftUI
import UIKit
import LocalAuthentication



struct ContentView: View {
    /*
     This copy was copy and pasted fom HackingWithSwift - Much Thanks
     https://www.hackingwithswift.com/books/ios-swiftui/using-touch-id-and-face-id-with-swiftui
     */

    @State private var isUnlocked = false
    @State var qoutesObject: QoutesModel?

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "FaceID Required to Access"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    isUnlocked = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }

    var body: some View {
        if isUnlocked {
            MainView()
        } else {
            VStack(alignment: .leading) {
                Text("\"\(qoutesObject?.content ?? "")\"")
                Text("- \(qoutesObject?.author ?? "")")

                Button(action: {
                    authenticate()
                }) {
                    Text("Sign In")
                }
                    .buttonStyle(.bordered)
            }
                .padding()
                .onAppear() {
                CallQoutesAPI().getAPI { (data) in
                    self.qoutesObject = data
                }
            }
        }
    }
}



struct MainView: View {
    @State var passwordLength: Double = 0
    @State var generatedPassword = ""
    @State var includeNumbers = false
    @State var capitalLetters = false
    @State var specialCharaters = false
    @State var array: [String] = []
    @State var hidePasswords = false
    @State var saveSheet = false


    @State var website = ""
    @State var username = ""



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
        VStack {
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

                Section(header: Text("Save to Clipboard")) {
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
                            Button(action: { print(each) }) {
                                Image(systemName: "doc.on.clipboard")
                            }
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
