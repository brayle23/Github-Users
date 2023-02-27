import Foundation

struct User: Codable {
    let username: String
    let id: Int
    let avatarURL: String
    let type: String
    let siteAdmin: Bool
    
    let followers: Int = 0
    let following: Int = 0
    let name: String = ""
    let company: String = ""
    let blog: String = ""
    
    var notes: String = ""
    

    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id
        case avatarURL = "avatar_url"
        case type
        case siteAdmin = "site_admin"
    }
}
