import UIKit
import SwiftUI
import CoreData

class UserViewModel: ObservableObject {
    
    @Published var selectedUser = CoreUser()
    @Published var tableView: UITableView? = nil
    @Published var pageLimit = 25
    @Published var currentLastId: Int? = nil
    
    private var imageLoader = ImageLoader()
    
    func fetchData(completed: ((Bool) -> Void)? = nil) {
        GithubAPIManager.shared.getUsers(perPage: pageLimit, sinceId: currentLastId) { [weak self] result in
            switch result {
            case .success(let users):
                self?.currentLastId = users.last?.id
                self?.processFectchedUsers(users: users)
                completed?(true)
            case .failure(let error):
                print(error.localizedDescription)
                
                completed?(false)
            }
        }
    }
    
    func getUser(completed: ((Bool) -> Void)? = nil) {
        GithubAPIManager.shared.getUser(userName: self.selectedUser.username!) { [weak self] result in
            switch result {
            case .success(let user):
                self?.processGetUser(user: user)
                completed?(true)
            case .failure(let error):
                print(error.localizedDescription)
                
                completed?(false)
            }
        }
    }
    
    func processFectchedUsers(users: [User]) {
        DispatchQueue.main.async {
            for item in users {
                self.imageLoader.obtainImageWithPath(imagePath: item.avatarURL) { (image) in
                    CoreUser.createOrUpdate(item: item, avatar: image.pngData()!, with: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)
                }
                
            }
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            
            self.tableView?.reloadData()
        }
    }
    
    func processGetUser(user: UserDetail) {
        DispatchQueue.main.async {
            self.selectedUser = CoreUser.createOrUpdate(item: user, with: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)!
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    }
    
    func saveNote(text: String) {
        DispatchQueue.main.async {
            self.selectedUser.addNotes(notes: text)
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            self.tableView?.reloadData()
        }
    }
    
}
