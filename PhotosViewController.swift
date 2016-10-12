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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        
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
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
//                            print("response: \(responseDictionary)")
                            if let photoData = responseDictionary["data"] as? [NSDictionary] {
                                self.photos = photoData
                                self.tableView.reloadData()
//                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
            })
            task.resume()
        }
        
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoDetailVC = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPathForSelectedRow
        
        let imageUrl = photos[indexPath!.row].value(forKeyPath: "images.standard_resolution.url") as! String
        
        photoDetailVC.photoUrl = imageUrl
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTaskWithRequest(myRequest,
                                                                      completionHandler: { (data, response, error) in
                                                                        
                                                                        // ... Use the new data to update the data source ...
                                                                        
                                                                        // Reload the tableView now that there is new data
                                                                        self.myTableView.reloadData()
                                                                        
                                                                        // Tell the refreshControl to stop spinning
                                                                        refreshControl.endRefreshing()	
        });
        task.resume()
    }

}


extension PhotosViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
        
//        print((photos[indexPath.row].value(forKeyPath: "images.low_resolution.url")))
        
        let imageUrl = photos[indexPath.row].value(forKeyPath: "images.low_resolution.url") as! String
        
        photoCell.photoView.setImageWith(URL(string: imageUrl)!)
        
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}

