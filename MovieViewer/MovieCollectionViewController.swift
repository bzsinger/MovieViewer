//
//  MovieCollectionViewController.swift
//  MovieViewer
//
//  Created by Benny Singer on 1/30/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class MovieCollectionViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        getMovieData()

        // Do any additional setup after loading the view.
    }
    
    func getMovieData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.collectionView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.BZS.MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.row]
        
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        let imageUrl = baseUrl + posterPath

        let imageRequest = NSURLRequest(url: NSURL(string: imageUrl)! as URL)
        
        cell.image.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    //print("Image was NOT cached, fade in image")
                    cell.image.alpha = 0.0
                    cell.image.image = image
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        cell.image.alpha = 1.0
                    })
                } else {
                    //print("Image was cached so just update the image")
                    cell.image.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
