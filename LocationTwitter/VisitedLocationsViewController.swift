//
//  VisistedLocationsViewController.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/16/20.
//

import UIKit
import CoreData

class VisitedLocationsViewController: UITableViewController {

    //MARK:-  Ins Vars
    let managedObjectContext : NSManagedObjectContext =  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let objContext = appDelegate.managedObjectContext
        return objContext
    }()
    lazy var fetchedResultsController : NSFetchedResultsController<Location> = {
        //
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        //
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]
        fetchRequest.fetchBatchSize = 20    //디폴트는 컨트롤러가 테이블뷰에 보이는 만큼을 홀드한다.
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations"
        )
        //
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
    
    // MARK:- View Set Up
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 33
        navigationItem.rightBarButtonItem = editButtonItem
        self.performFetch()
        tableView.reloadData()
    }
    //MARK:- Update Table View
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    //MARK:- De-initiallizer
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: - TableView Data Source & Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("num of section : \(fetchedResultsController.sections!.count)")
        return fetchedResultsController.sections!.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section] // section index의 오브젝트들
        print("number number of rows is \(sectionInfo.numberOfObjects) in \(section)")
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = fetchedResultsController.object(at: indexPath)
        cell.configureCell(for: location)
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            // MARK:- Write on the scratchpad
            managedObjectContext.delete(location)
            do {
                // MARK:- Commit Changes by save
                try managedObjectContext.save()
            } catch  {
                fatalCoreDataError(error)
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailViewController
            let indexPath = tableView.indexPath(for: ( sender as! UITableViewCell ) )
            controller.locationToEdit = fetchedResultsController.object( at: indexPath! )
            controller.managedObjectContext = self.managedObjectContext
            //
        }
    }
    
    //MARK:- Helper Methods
    func performFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalCoreDataError(error)
        }
    }
}

// MARK:- Delegating the FRController - real-time response to changes in queired objects
extension VisitedLocationsViewController : NSFetchedResultsControllerDelegate {
    
    // MARK:- Heads Up for Controller Changes Timing
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("***controller will change contents***")
        tableView.beginUpdates()
    }
    // MARK: - Item Changes -> TableView
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert :
                print("insert")
                tableView.insertRows( at: [newIndexPath!], with: .fade )
            case .delete :
                print("delete")
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update :
                print("update")
                if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                    let location = controller.object(at: indexPath!) as! Location
                    cell.configureCell(for: location)
                }
            case .move :
                print("move")
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            print("***fetched result controller alerted unknown changes occured.***")
        }
    }
    
    // MARK:- Section Changes -> TableView
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (section) ***")
                tableView.insertSections( IndexSet(integer: sectionIndex) , with: .fade)
            case .delete:
                print("*** NSFetchedResultsChangeDelete (section) ***")
                tableView.deleteSections( IndexSet(integer: sectionIndex) , with: .fade)
            case .update:
                print("*** NSFetchedResultsChangeUpdate (section) ***")
            case . move:
                print("*** NSFetchedResultsChangeMove (section) ***")
            @unknown default:
                print("*** NSFetchedResultsChangeUnknown (section) ***")
        }
    }
    
    // 4). MARK:- Heads Up for Controller Contents such as Section & Entry is over.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controller finished contents changing and configuring tableview***")
        self.tableView.endUpdates()
    }
    
    // End of VC
}
