//
//  MainView.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var prompts: [Prompt]
    
    @State private var image = Image(systemName: "photo")
    @State private var selectedNSImage: NSImage?
    @State private var selectedImage: Image?
    @State private var alt: String?
    @State private var cost: String?
    
    

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .dropDestination(for: Data.self) { items, location in
                    guard let item = items.first else { return false }
                    selectedNSImage = NSImage(data: item)
                    image = Image(nsImage: selectedNSImage!)
                    return true
                }
            Text(alt ?? "Waiting").textSelection(.enabled)
            Text(cost ?? "$0.00")
        }
        .onChange(of: selectedNSImage) {
            Task {
                
                if let selectedNSImage {
                    selectedImage = Image(nsImage: selectedNSImage)
//                    alt = await sendImageToOpenAI(imageBase64: selectedNSImage.base64!)
                }
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Prompt.self, inMemory: true)
}
