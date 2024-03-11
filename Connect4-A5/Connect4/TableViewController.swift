//
//  TableViewController.swift
//  Connect4
//
//  Created by Judith Smolenski on 10/12/2023.
//

import UIKit
import CoreData
import Alpha0C4

class TableViewController: UITableViewController {
    var fetchedResultsController: NSFetchedResultsController<CoreDataSession>!
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "CoreDataSession") as! NSFetchRequest<CoreDataSession>
        let discCountSort = NSSortDescriptor(key: "discCount", ascending: true)
        let logSort = NSSortDescriptor(key: "log", ascending: true)
        request.sortDescriptors = [discCountSort, logSort]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moc = appDelegate.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do { try fetchedResultsController.performFetch() }
        catch { fatalError("Failed to initialize FetchedResultsController: \(error)") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Data Source

extension TableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameSessionCell", for: indexPath)
        
        // set up the cell
        guard let sessionItem = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        cell.textLabel?.text = sessionItem.log
        cell.contentView.backgroundColor = .white
        cell.detailTextLabel?.text = "Draw"
        if let color = sessionItem.winningColor {
            cell.contentView.backgroundColor = ((color == .red) ? UIColor.red : UIColor.yellow).withAlphaComponent(0.5)
            let botColor = DiscColor(rawValue: Int(sessionItem.botColor))
            var result = sessionItem.botIsFirst ? "Bot \(botColor == .red ? "(R)" : "(Y)") starts" : "User \(botColor == .red ? "(Y)" : "(R)") starts"
            result += botColor == color ? "\nBot Wins" : "\nUser Wins"
            result += "\n\(sessionItem.winningDiscs)"
            cell.detailTextLabel?.text = result
        }
        return cell
    }
    
    // override to support editing in the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete the row from the data source
            
            if let item = fetchedResultsController?.object(at: indexPath), let moc = item.managedObjectContext {
                moc.delete(item)
            }
        }
    }
}
