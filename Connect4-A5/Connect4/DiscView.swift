//
//  DiscView.swift
//  Connect4
//
//  Created by Judith Smolenski on 10/12/2023.
//

import UIKit
import Alpha0C4

class DiscView: UIView {

    var radius: Int? = nil
    
    // set up with size and color
    init(frame: CGRect, isBot: Bool, num: Int, colum: Int) {
        super.init(frame: frame)
        radius = Int(frame.width / 2)
        layer.cornerRadius = frame.size.width / 2
        layer.backgroundColor = (isBot == true) ? UIColor.red.cgColor : UIColor.yellow.cgColor
        layer.borderWidth = 2
        layer.borderColor = UIColor.orange.cgColor
    }
    // required init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    // set shape to ellipse rather than rectangle
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
    
}

// an attempt to use hex code for colour but it didn't work
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        guard hex.hasPrefix("#"), hex.count == 8 else {
            return nil
        }
        
        let hexValue = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexValue)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        // calculate rgb values from hex number
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        
        // return hex as rgb
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

