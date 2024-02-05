//
//  Alt_AIApp.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI
import SwiftData

@main
struct Alt_AIApp: App {
    
    var body: some Scene {
        WindowGroup {
            ScrollView {
                MainView()
                    .padding(45)
            }
            .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
            .frame(width: 350)
            .frame(maxHeight: 500)
            .background(VisualEffectView().ignoresSafeArea())
            
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        
        
        Settings {
            SettingsView()
                .frame(width: 400, height: 200)
        }
        .windowResizability(.automatic)
        
        
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
