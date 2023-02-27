import CoreData
import Foundation

public extension CoreUser {
    internal class func createOrUpdate(item: User, avatar: Data, with context: NSManagedObjectContext) {
        let userId = item.id
        var currentCoreUser: CoreUser? // Entity name
        let coreUserFetch: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
        let userIdPredicate = NSPredicate(format: "%K == %i", #keyPath(CoreUser.userId), userId)
        coreUserFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userIdPredicate])
        do {
            let results = try context.fetch(coreUserFetch)
            if results.isEmpty {
                // News post not found, create a new.
                currentCoreUser = CoreUser(context: context)
                currentCoreUser?.userId = Int64(userId)
            } else {
                // News post found, use it.
                currentCoreUser = results.first
            }
            currentCoreUser?.update(item: item, avatar: avatar)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    internal class func createOrUpdate(item: UserDetail, with context: NSManagedObjectContext) -> CoreUser? {
        let userId = item.id
        var currentCoreUser: CoreUser? // Entity name
        let coreUserFetch: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
        let userIdPredicate = NSPredicate(format: "%K == %i", #keyPath(CoreUser.userId), userId)
        coreUserFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userIdPredicate])
        do {
            let results = try context.fetch(coreUserFetch)
            if results.isEmpty {
                // News post not found, create a new.
                currentCoreUser = CoreUser(context: context)
                currentCoreUser?.userId = Int64(userId)
            } else {
                // News post found, use it.
                currentCoreUser = results.first
            }
            currentCoreUser?.update(item: item)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return currentCoreUser
    }

    internal func update(item: User, avatar: Data) {
        self.avatar = avatar
        self.avatarURL = item.avatarURL
        self.username = item.username
        self.type = item.type
        self.siteAdmin = item.siteAdmin
    }
    
    internal func update(item: UserDetail) {
        self.followers = Int64(item.followers)
        self.following = Int64(item.following)
        self.name = item.name
        self.blog = item.blog
        self.company = item.company
    }
    
    internal func addNotes(notes: String) {
        self.notes = notes
    }
}
