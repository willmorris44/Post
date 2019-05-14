//
//  PostController.swift
//  Post
//
//  Created by Will morris on 5/13/19.
//  Copyright © 2019 devmtn. All rights reserved.
//

import Foundation

class PostController {
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        guard let url = baseURL else { completion(); return }
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let newURL = urlComponents?.url else { return }
        
        let getterEndpoint = newURL.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
                return
            }
            
            guard let data = data else { completion(); return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: { $0.timestamp > $1.timestamp })
                if reset == true {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                completion()
                return
            } catch {
                print(error.localizedDescription)
                completion()
                return
            }
            
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void) {
        let post = Post(text: text, username: username)
        var postData: Data
        
        do {
            postData = try JSONEncoder().encode(post)
        } catch {
            print(error)
            return
        }
        
        guard let url = baseURL else { return }
        
        let postEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            self.fetchPosts(completion: {
                completion()
            })
        }
        dataTask.resume()
        
    }
}
