//
//  SettingsView.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("OpenAIAPIKey") var apiKey: String = ""
    @AppStorage("isAPIKeyValid") var isAPIKeyValid: APIKeyStatus = .unknown
    @AppStorage("maxTokenAmount") var maxTokenCount: Int = 25
    @AppStorage("totalTokenUsage") var totalTokenUsage: Int = 0
    @AppStorage("numberOfUploadedImages") var numberOfUploadedImages: Int = 0
    @State private var keyStatusColor: Color = .yellow
    @State private var editingTokenCount: Bool = false
    
    var body: some View {
        TabView {
            VStack {
                VStack {
                    HStack {
                        Text("OpenAI API Key:")
                        TextField(text: $apiKey, label: {Text("")})
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                do {
                                    let status: ModelListResponse.OpenAIKeyResponse = try await fetchOpenAIModels(apiKey: apiKey)
                                    
                                    switch status {
                                    case .validKey:
                                        isAPIKeyValid = .valid
                                    case .invalidKey:
                                        isAPIKeyValid = .invalid
                                    default:
                                        isAPIKeyValid = .unknown
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            Text("Test API Key")
                        }
                        Circle()
                            .frame(width: 8)
                            .foregroundStyle(isAPIKeyValid == .valid ? .green : isAPIKeyValid == .invalid ? .red : .yellow)
                    }
                }
                HStack {
                    Text("Max token count:")
                    TextField("", value: $maxTokenCount, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                
                
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
            VStack {
                Form {
                    Section(
                        content: {
                            HStack {
                                Text("Total tokens")
                                Spacer()
                                Text("\(totalTokenUsage.formatted())")
                            }
                            HStack {
                                Text("Number of uploaded images")
                                Spacer()
                                Text("\(numberOfUploadedImages.formatted())")
                            }
                            HStack {
                               
                                Text("Total cost")
                                Spacer()
                                Text("\(Decimal((Double(totalTokenUsage) * 0.001 / 100.0)), format: .currency(code: "USD").precision(.fractionLength(2...10)))")
                            }
                        },
                        header: { Text("Stats") },
                        footer: {
                            Button {
                                totalTokenUsage = 0
                                numberOfUploadedImages = 0
                            } label: {
                                Text("Reset")
                            }
                        }
                    )
                }
                .formStyle(.grouped)
               
            }
            
            .tabItem {
                Label("Usage", systemImage: "chart.bar.fill")
            }
            
        }
    }
    func fetchOpenAIModels(apiKey: String) async throws -> ModelListResponse.OpenAIKeyResponse {
        let url = URL(string: "https://api.openai.com/v1/models")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return .invalidKey
            }
            let _ = try JSONDecoder().decode(ModelListResponse.OpenAIModels.self, from: data)
            return .validKey
        } catch {
            throw ModelListResponse.OpenAIKeyResponse.other(error)
        }
    }
    
    
    
    struct ModelListResponse: Codable {
        enum OpenAIKeyResponse: Error {
            case validKey
            case invalidResponse
            case invalidKey
            case other(Error)
        }
        
        struct OpenAIModels: Codable {
            let data: [Model]
        }
        
        struct Model: Codable {
            let id: String
        }
    }
}

#Preview {
    SettingsView()
}


enum APIKeyStatus: String {
    case valid, invalid, unknown
}
