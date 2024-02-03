//
//  SettingsView.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("OpenAIAPIKey") var apiKey: String = ""
    var body: some View {
        VStack {
            HStack {
                Text("OpenAI API Key:")
                TextField(text: $apiKey, label: {Text("")})
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Spacer()
                Button {
                    print("Test")
                } label: {
                    Text("Test API Key")
                }
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
