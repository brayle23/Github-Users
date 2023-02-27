import UIKit
import SwiftUI
import CoreData

class HomeViewController: UIViewController {
    
    enum TableSection: Int {
        case userList
        case loader
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private let pageLimit = 25
    private var currentLastId: Int? = nil
    private var viewModel = UserViewModel()
        
    lazy var dataProvider: CoreUserProvider = {
        let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let provider = CoreUserProvider(with: managedContext!, fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.fetchData()
    }
    
    private func setupView() {
        title = "Github Users"
        
        viewModel.tableView = self.tableView
        
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        self.tableView.register(UINib(nibName: "InvertUserCell", bundle: nil), forCellReuseIdentifier: "InvertUserCell")
        self.tableView.register(UINib(nibName: "UserNoteCell", bundle: nil), forCellReuseIdentifier: "UserNoteCell")
        self.tableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBSegueAction func showDetails(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: DetailsView(viewModel: self.viewModel))
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let listSection = TableSection(rawValue: section) else { return 0 }
        let sectionInfo = dataProvider.fetchedResultsController.sections![0]
        switch listSection {
        case .userList:
            return sectionInfo.numberOfObjects
        case .loader:
            // inittial load
            if sectionInfo.numberOfObjects < pageLimit { return 1 }
            return sectionInfo.numberOfObjects >= pageLimit ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .userList:
            let user = dataProvider.fetchedResultsController.object(at: indexPath)
            let placement = indexPath.row + 1
            
            if(user.notes != nil && user.notes != "") {
                let userCell = tableView.dequeueReusableCell(withIdentifier: "UserNoteCell") as! UserNoteCell
                userCell.configure(user: user)
                return userCell
            }
            
            if placement % 4 != 0 {
                let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
                userCell.configure(user: user)
                return userCell
            } else {
                let userCell = tableView.dequeueReusableCell(withIdentifier: "InvertUserCell") as! InvertUserCell
                userCell.configure(user: user)
                return userCell
            }
        case .loader:
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = TableSection(rawValue: indexPath.section) else { return }
//        let sectionInfo = self.dataProvider.fetchedResultsController.sections![0]
//        guard sectionInfo.numberOfObjects != 0 else { return }
        
        if section == .loader {
            print("load new data..")
            viewModel.fetchData { [weak self] success in
                if !success {
                    self?.hideBottomLoader()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section != 1) {
            let user = dataProvider.fetchedResultsController.object(at: indexPath)
            viewModel.selectedUser = user
            performSegue(withIdentifier: "ShowDetails", sender: self)
        }
        
    }
    
    private func hideBottomLoader() {
        let sectionInfo = self.dataProvider.fetchedResultsController.sections![0]
        guard sectionInfo.numberOfObjects != 0 else { return }
        DispatchQueue.main.async {
            let lastListIndexPath = IndexPath(row: sectionInfo.numberOfObjects - 1, section: TableSection.userList.rawValue)
            self.tableView.scrollToRow(at: lastListIndexPath, at: .bottom, animated: true)
        }
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .none)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .none)
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .update:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath!) as? UserCell else { fatalError("xib doesn't exist") }
            let user = dataProvider.fetchedResultsController.object(at: indexPath!)
            cell.configure(user: user)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
