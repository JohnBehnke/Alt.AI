//
//  Prompt.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import Foundation
import SwiftData

@Model
class Prompt {
    var text: String
    
    init(text: String) {
        self.text = text
    }
}
