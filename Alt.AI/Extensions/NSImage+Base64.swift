//
//  NSImage+Base64.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import Foundation
import SwiftUI

extension NSImage {
    var base64: String? {
        guard let tiff = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let jpg = bitmap.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
        return jpg.base64EncodedString()
    }
}
