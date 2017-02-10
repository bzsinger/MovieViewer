//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Benny Singer on 1/30/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    let refreshControl = UIRefreshControl()
    
    var endpoint = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        getMovieData(refresh: false)

        // Do any additional setup after loading the view.
    }

    func getMovieData(refresh: Bool) {
        if !isInternetAvailable() {
            if refresh {
                refreshControl.endRefreshing()
            }
            self.performSegue(withIdentifier: "internet", sender: self)
        }
        
        if !refresh {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    if (!refresh) { self.filteredMovies = self.movies }
                    self.tableView.reloadData()
                }
            }
        }
        if refresh {
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        getMovieData(refresh: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl! as URL)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty || movies == nil) {
            filteredMovies = movies
        } else {
            filteredMovies = []
            for i in 0...movies!.count - 1 {
                let title = movies![i]["title"] as! String
                if (title.range(of: searchText, options: .caseInsensitive) != nil) {
                    filteredMovies?.append(movies![i])
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    //source: http://stackoverflow.com/questions/39558868/check-internet-connection-ios-10
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "internet") {
            return
        }
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
     }
}
