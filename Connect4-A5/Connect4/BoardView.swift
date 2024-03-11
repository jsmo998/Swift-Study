//
//  BoardView.swift
//  Connect4
//
//  Created by Judith Smolenski on 11/12/2023.
//

import UIKit

class BoardView: CALayer {
    
    // vars
    var boardWidth: CGFloat? = nil
    var boardHeight: CGFloat? = nil
    var discRadius: CGFloat? = nil
    var parentView: UIView? = nil
    
    lazy var cellWidth: CGFloat = {
        return boardWidth! / 7
    }()
    
    lazy var cellHeight: CGFloat = {
        return self.discRadius! * 2
    }()
    
    init(_ view: UIView, discRadius: CGFloat) {
        super.init()
        self.parentView = view
        self.boardWidth = view.frame.width
        self.boardHeight = view.frame.height
        self.discRadius = discRadius
        
        frame = view.bounds
        backgroundColor = UIColor.systemCyan.cgColor
        bounds = CGRect(x: 0, y: 0, width: view.frame.width, height: cellHeight * 6)
        
        addHolesToBoard()
    }
    
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder: NSCoder) { fatalError("init(coder:) was not implemented") }
    
    // get walls of board to add barriers and bottom bar
    func getWalls() -> [UIBezierPath] {
        var walls: [UIBezierPath] = []
        let top = boardHeight! / 2 - cellHeight * 3
        for i in 0...7{
            let barrier = drawWall(beginX: CGFloat(i) * cellWidth, beginY: top, finishY: boardHeight!)
            walls.append(barrier)
        }
        return walls
    }
    
    func getBottom() -> UIBezierPath {
        let bottomLine = UIBezierPath()
        bottomLine.move(to: CGPoint(x: 0, y: position.y + frame.height / 2 ))
        bottomLine.addLine(to: CGPoint(x: parentView!.bounds.width, y: position.y + frame.height / 2))
        return bottomLine
    }
    
    func drawWall(beginX: CGFloat, beginY: CGFloat, finishY: CGFloat) -> UIBezierPath {
        let wall = UIBezierPath()
        wall.lineWidth = 0
        wall.move(to: CGPoint(x: beginX, y: beginY))
        wall.addLine(to: CGPoint(x: beginX, y: finishY))
        return wall
    }
    
    // use CAShapeLayer to cut holes into the board to see discs fall behind
    // found on: https://copyprogramming.com/howto/calayer-with-transparent-hole-in-it
    private func addHolesToBoard() {
        let holesLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(bounds)
        
        // build it using board rectangle and disc dimensions
        let diameter = cellWidth - 10
        let padding = cellWidth / 2 - diameter / 2
        let top = cellHeight / 2 - diameter / 2
        
        // build grid
        for i in 0...6{
            for j in 0...5{
                let maskRect = CGRect(x: (CGFloat(i) * cellWidth) + padding, y: (CGFloat(j) * cellHeight) + top, width: diameter, height: diameter)
                path.addEllipse(in: maskRect)
            }
        }
        holesLayer.path = path
        holesLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        mask = holesLayer
    }
    
}
