//
//  NSImage+JPGRepresentation.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import Foundation
import SwiftUI

extension NSImage {
    var jpgRepresentation: Data? {
        guard let tiff = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let jpgRepresentation = bitmap.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
    return jpgRepresentation
    }
}

