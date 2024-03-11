//
//  DiscBehavior.swift
//  Connect4
//
//  Created by Judith Smolenski on 11/12/2023.
//

import UIKit

class DiscBehavior: UIDynamicBehavior {
    // gravity and collision setup
    var gravity = UIGravityBehavior()
    
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        collider.collisionMode = UICollisionBehavior.Mode.everything
        return collider
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        gravity.magnitude = 1
        
        gravity.action = {
            for item in self.gravity.items {
                if (item.center.y > UIScreen.main.bounds.height + item.bounds.height){
                    self.removeDisc(item as! UIView)
                }
            }
        }
    }
    
    // add behaviour to new disc when added to game
    func addDisc(_ disc: UIView) {
        dynamicAnimator?.referenceView?.addSubview(disc)
        dynamicAnimator?.referenceView?.sendSubviewToBack(disc)
        gravity.addItem(disc)
        collider.addItem(disc)
    }
    
    func removeDisc(_ disc: UIView) {
        gravity.removeItem(disc)
        collider.removeItem(disc)
        disc.removeFromSuperview()
    }
    
    // add collision for given path - walls and bar of game board
    func addBarrier(_ path: UIBezierPath, named name: String) {
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }
    
    // for when the board is cleared -- doesn't work
    func falling() {
        removeChildBehavior(collider)
    }
    func notFalling() {
        addChildBehavior(collider)
    }
    

    
}
