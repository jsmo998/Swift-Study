//
//  CoreDataSession+CoreDataClass.swift
//  Connect4
//
//  Created by Judith Smolenski on 05/12/2023.
//

import CoreData
import Alpha0C4

typealias DiscColor = GameSession.DiscColor

public class CoreDataSession: NSManagedObject 
{
    static func save(botPlays botColor: DiscColor, first botStarts: Bool, layout: (rows: Int, columns: Int), positions: [(row: Int, column: Int)], winningPositions: [(row: Int, column: Int)] = [(Int, Int)](), in moc: NSManagedObjectContext?) -> CoreDataSession? {
        
        // get entity
        guard let managedContext = moc else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: "CoreDataSession", in: managedContext)
        else { return nil }
        
        // insert and config new gamesSession
        let sessionItem = NSManagedObject(entity: entity, insertInto: managedContext) as! CoreDataSession
        sessionItem.botColor = Int16(botColor.rawValue)
        sessionItem.botIsFirst = botStarts
        (sessionItem.rows, sessionItem.columns) = (Int16(layout.rows), Int16(layout.columns))
        
        // log
        var board = [[String]](repeating: [String](repeating:"'  '", count: layout.columns), count: layout.rows)
//        _ = positions.enumerated().map {
//            board[ layout.rows - $0.element.row ][ $0.element.column - 1 ] = "'\($0.offset < 9 ? " " : "\(sessionItem.log = (botStarts ? "‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐\n" : board.map({ "|\($0.joined(separator: ", "))|"}).joined(separator: "\n") + (botStarts ? "-----------------------------------" : "+++++++++++++++++++++++++++++++++++++")))")'"
//        }
        _ = positions.enumerated().map { board[layout.rows -
                                               $0.element.row][$0.element.column - 1] = "'\($0.offset < 9 ? " " : "")\($0.offset + 1)'"}
        sessionItem.log = (botStarts ? "‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐\n" : "++++++++++++++++++++++++++++++++++++++++++\n") + board.map({ "|\($0.joined(separator: ", "))|"}).joined(separator: "\n") + "\n" + (botStarts ? "‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐" : "++++++++++++++++++++++++++++++++++++++++++")

        // add discs
        guard let discs = CoreDataDisc.save(positions: positions, winningPositions: winningPositions, in: managedContext)
        else { return nil }
        _ = discs.map { sessionItem.addToDiscs($0) }
        sessionItem.discCount = Int64(discs.count)
        
        // save
        do {
            try managedContext.save()
            #if DEBUG
            print(sessionItem.log!)
            #endif
        }
        catch let error as NSError { print("Could not save. \(error), \(error.userInfo)") }
        
        // return core data session
        return sessionItem
    }
    
    var winningColor: DiscColor? {
        guard winningDiscs.count >= 4 else { return nil }
//        let discArray = discs!.allObjects as! [CoreDataDisc]
        let color = DiscColor(rawValue: Int(botColor))!
        let positions = (discs!.allObjects as! [CoreDataDisc]).map({ (Int($0.row), Int($0.column)) })
        let isBotWinner = (botIsFirst && (positions.count % 2 == 1)) || (!botIsFirst && (positions.count % 2 == 0))
        return (isBotWinner ? color : !color)
    }
    
    var winningDiscs: [Int] { get { (discs!.allObjects as! [CoreDataDisc]).filter({
        $0.isWinning }).map({ Int($0.index) }) }}
}

