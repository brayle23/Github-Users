import Foundation

struct UserDetail: Codable {
    let username: String
    let id: Int
    let avatarURL: String
    let type: String
    let siteAdmin: Bool
    let followers: Int
    let following: Int
    let name: String
    let company: String = ""
    let blog: String = ""
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id
        case avatarURL = "avatar_url"
        case type
        case siteAdmin = "site_admin"
        case followers, following, name, company, blog
    }
}
