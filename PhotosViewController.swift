//
//  ViewController.swift
//  Instagram
//
//  Created by Kyou on 10/12/16.
//  Copyright © 2016 Kyou. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var photos = [NSDictionary]()
    let refreshControl = UIRefreshControl()
    var loadMoreControl = UIActivityIndicatorView()
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 414, height: 50))
        loadMoreControl = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadMoreControl.startAnimating()
        loadMoreControl.center = tableFooterView.center
        tableFooterView.addSubview(loadMoreControl)
        tableView.tableFooterView = tableFooterView
        
        loadPhotos()
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoDetailVC = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPathForSelectedRow
        
        let imageUrl = photos[indexPath!.row].value(forKeyPath: "images.standard_resolution.url") as! String
        
        photoDetailVC.photoUrl = imageUrl
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        loadPhotos()
    }
    
    func loadPhotos() {
        let accessToken = "435569061.c66ada7.d12d19c8687e427591f254586e4f3e47"
        let userId = "435569061"
        let url = URL(string: "https://api.instagram.com/v1/users/\(userId)/media/recent/?access_token=\(accessToken)")
        
        if let url = url {
            let request = URLRequest(
                url: url,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main)
            let task = session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error) in
                    if let data = dataOrNil {
                        if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            //                            print("response: \(responseDictionary)")
                            if let photoData = responseDictionary?["data"] as? [NSDictionary] {
                                self.photos = photoData
                                self.tableView.reloadData()
                                //                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
                    
                    self.refreshControl.endRefreshing()
                    self.loadMoreControl.stopAnimating()
                    
            })
            task.resume()
        }
        
        isMoreDataLoading = false
        
    }
    

}


extension PhotosViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
        
//        print((photos[indexPath.row].value(forKeyPath: "images.low_resolution.url")))
        
        let imageUrl = photos[indexPath.section].value(forKeyPath: "images.low_resolution.url") as! String
        
        photoCell.photoView.setImageWith(URL(string: imageUrl)!)
        
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let userPicture = photos[section].value(forKeyPath: "user.profile_picture") as! String
        let userName = photos[section].value(forKeyPath: "user.username") as! String

        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 414, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1
        
        let profileName = UILabel(frame: CGRect(x: 50, y: 10, width: 200, height: 30))
        profileName.text = userName
    
        
        profileView.setImageWith(URL(string: userPicture)!)
        
        headerView.addSubview(profileName)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the username here
        
        return headerView
    }
}

extension PhotosViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                loadMoreControl.startAnimating()
                // ... Code to load more results ...
                loadPhotos()
            }
        }

    }
}

