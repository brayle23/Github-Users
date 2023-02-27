import Foundation

enum APIError: Error {
    case invalidUrl
    case errorDecode
    case failed(error: Error)
    case unknownError
}

struct GithubAPIManager {
    static let shared = GithubAPIManager()
    
    func getUsers(perPage: Int = 30, sinceId: Int? = nil, completion: @escaping (Result<[User], APIError>) -> Void) {
        
        var components = URLComponents(string: "https://api.github.com/users")!
        components.queryItems = [
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "since", value: (sinceId != nil) ? "\(sinceId!)" : "")
        ]
        guard let url = components.url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error  in
            if error != nil {
                print("dataTask error: \(error!.localizedDescription)")
                completion(.failure(.failed(error: error!)))
            } else if let data = data {
                
                do {
                    
                    let users = try JSONDecoder().decode([User].self, from: data)
                    print("success")
                    completion(.success(users))
                } catch {
                    
                    print("decoding error")
                    completion(.failure(.errorDecode))
                }
            } else {
                
                completion(.failure(.unknownError))
            }
        }
        .resume()
    }
    
    func getUser(userName: String = "", completion: @escaping (Result<UserDetail, APIError>) -> Void) {
        let components = URLComponents(string: "https://api.github.com/users/\(userName)")!
        guard let url = components.url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error  in
            if error != nil {
                print("dataTask error: \(error!.localizedDescription)")
                completion(.failure(.failed(error: error!)))
            } else if let data = data {
                
                do {
                    
                    let user = try JSONDecoder().decode(UserDetail.self, from: data)
                    print("success")
                    completion(.success(user))
                } catch {
                    
                    print("decoding error")
                    completion(.failure(.errorDecode))
                }
            } else {
                
                completion(.failure(.unknownError))
            }
        }
        .resume()
    }
}
