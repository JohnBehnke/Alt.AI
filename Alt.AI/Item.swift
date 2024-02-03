//
//  Item.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
