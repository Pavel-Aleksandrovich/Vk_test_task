//
//  File.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 27/3/24.
//

import UIKit

extension CGSize {
    
    func multiply(_ x: CGFloat) -> CGSize {
        return CGSize(width: width * x, height: height * x)
    }
    
    
}

extension Comparable {
    
    func clamp(_ minVal: Self, _ maxVal: Self) -> Self {
        let v = min(self, maxVal)
        return max(v, minVal)
    }
    
}

extension UIColor {
    
    static let baseGreen = #colorLiteral(red: 0.07026626915, green: 0.5732991695, blue: 0.2115154266, alpha: 1)
    static let baseOrange = #colorLiteral(red: 0.9107758403, green: 0.3140987158, blue: 0.03607605025, alpha: 1)
}
