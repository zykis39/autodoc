//
//  Extensions.swift
//  autodoc
//
//  Created by Артём Зайцев on 13.05.2025.
//

import UIKit

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension UIImage {
    var isPortraitOriented: Bool {
        size.width < size.height
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

public protocol KeyPathSettable {}
public extension KeyPathSettable {
    @discardableResult
    func set<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var mutableSelf = self
        mutableSelf[keyPath: keyPath] = value
        return mutableSelf
    }
}
extension NSObject: KeyPathSettable {}
