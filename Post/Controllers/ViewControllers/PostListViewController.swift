//
//  PostListViewController.swift
//  Post
//
//  Created by Will morris on 5/13/19.
//  Copyright © 2019 devmtn. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var postTableView: UITableView!
    
    let postController = PostController()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
        postTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postController.fetchPosts {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.reloadTableView()
            }
        }
        
    }
    
    @IBAction func newPostButtonTapped(_ sender: Any) {
        self.presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        alertController.addTextField { (username) in
            username.placeholder = "Username"
        }
        alertController.addTextField { (message) in
            message.placeholder = "Message..."
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { [unowned alertController] _ in
            let username = alertController.textFields?[0]
            let message = alertController.textFields?[1]
            
            guard let usernameText = username?.text, let messageText = message?.text else { return }
            
            if usernameText == "" || messageText == "" {
                self.presentErrorAlert()
            } else {
                self.postController.addNewPostWith(username: usernameText, text: messageText, completion: {
                    self.reloadTableView()
                })
            }
        }
        
        alertController.addAction(postAction)
        present(alertController, animated: true)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Cannot have an empty text field", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "If you say so...", style: .cancel)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.reloadTableView()
            }
        }
    }
    
    func reloadTableView() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.postTableView.reloadData()
    }
    
    //MARK - Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
            cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) \(Date().stringValue(timestamp: post.timestamp))"
        
        return cell
    }
}

extension PostListViewController {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= (postController.posts.count - 1) {
            postController.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
    }
    
}
