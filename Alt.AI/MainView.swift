//
//  MainView.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @AppStorage("OpenAIAPIKey") var apiKey: String = ""
    @AppStorage("isAPIKeyValid") var isAPIKeyValid: APIKeyStatus = .unknown
    @AppStorage("maxTokenAmount") var maxTokenCount: Int = 25
    @AppStorage("totalTokenUsage") var totalTokenUsage: Int = 0
    @AppStorage("numberOfUploadedImages") var numberOfUploadedImages: Int = 0
    @AppStorage("prompt") var prompt: String = "What is in this image? This description will be used as alt text. Don't be overly descriptive, don't write in the first person, don't be overly descriptive or wordy."
    
    @State private var image = Image(systemName: "photo")
    @State private var selectedNSImage: NSImage?
    @State private var selectedImage: Image?
    @State private var alt: String?
    @State private var tokenCount: Int?
    @State private var fetchingResponse: Bool = false
    
    
    var body: some View {
        VStack(spacing: 10) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .dropDestination(for: Data.self) { items, location in
                    guard let item = items.first else { return false }
                    selectedNSImage = NSImage(data: item)
                    image = Image(nsImage: selectedNSImage!)
                    return true
                }
            
            GroupBox {
                ScrollView {
                    if let alt {
                        Text(alt)
                            .padding(.horizontal)
                    } else if fetchingResponse {
                        HStack {
                            Text("Generating alt text")
                                .italic()
                            Image(systemName: "sparkles")
                                .symbolEffect(.pulse.byLayer)
                                .foregroundStyle(.purple)
                        }
                    } else {
                        Text("Upload an image")
                    }
                }
                .padding()
                .frame(maxWidth: 300)
            }
            .frame(maxHeight: 300)
            HStack(spacing: 5){
                Text("^[\(tokenCount ?? 0) token](inflect: true)")
                Text("(\(Decimal((Double(tokenCount ?? 0) * 0.001 / 100.0)), format: .currency(code: "USD").precision(.fractionLength(2...10))))")
                Spacer()
                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(alt ?? "", forType: .string)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .disabled(alt == nil)
                Button {
                    Task {
                        if let selectedNSImage {
                            alt = nil
                            tokenCount = 0
                            selectedImage = Image(nsImage: selectedNSImage)
                            fetchingResponse = true
                            let resp = await sendImageToOpenAI(imageBase64: selectedNSImage.base64!)
                            fetchingResponse = false
                            alt = resp.0
                            tokenCount = resp.1
                            
                        }
                    }
                } label: {
                    Image(systemName: "repeat")
                }
                .disabled(alt == nil)
                
            }
            
            .font(.caption2)
            .fontWeight(.light)
            
        }
        .padding(.top, -30)
        .onChange(of: selectedNSImage) {
            Task {
                
                if let selectedNSImage {
                    selectedImage = Image(nsImage: selectedNSImage)
                    alt = nil
                    tokenCount = 0
                    fetchingResponse.toggle()
                    let resp = await sendImageToOpenAI(imageBase64: selectedNSImage.base64!)
                    fetchingResponse.toggle()
                    alt = resp.0
                    tokenCount = resp.1
                    
                }
            }
        }
    }
    
    func sendImageToOpenAI(imageBase64: String) async -> (String, Int) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "\(prompt)"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(imageBase64)"]]
                    ]
                ]
            ],
            "max_tokens": maxTokenCount
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return ("Error", 0)
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                let extract = extractContent(from: responseString)
                numberOfUploadedImages += 1
                totalTokenUsage += extract.1
                return extract
            }
        } catch {
            print("Error sending request to OpenAI: \(error)")
        }
        return ("Error", 0)
    }
    func extractContent(from jsonString: String) -> (String, Int) {
        let jsonData = Data(jsonString.utf8)
        
        do {
            let chatCompletion = try JSONDecoder().decode(VisionAPIResponse.ChatCompletion.self, from: jsonData)
            let text = chatCompletion.choices.first?.message.content ?? "Unknown"
            print(chatCompletion.usage.totalTokens)
            let cost = chatCompletion.usage.totalTokens
            return (text, cost)
        } catch {
            print("Error decoding JSON: \(error)")
            return ("Error", 0)
        }
    }
}

#Preview {
    MainView()
}

