//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Benny Singer on 2/6/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var releaseDate: UILabel!
    
    var movie: NSDictionary!
    var sender: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        titleLabel.sizeToFit()
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        
        infoView.isHidden = true
        
        var rawRating = movie["vote_average"] as? Double
        if (rawRating! > 8.0) {rawRating = 8.0}
        
        let adjustedRating = (rawRating! / 8.0) * 100
        rating.text = "\(Int(adjustedRating))%"
        
        if adjustedRating >= 80 {
            ratingImage.image = #imageLiteral(resourceName: "fresh")
        }
        else {
            ratingImage.image = #imageLiteral(resourceName: "rotten")
        }
        
        //http://stackoverflow.com/questions/35700281/date-format-in-swift
        let rawDateFormatter = DateFormatter()
        rawDateFormatter.dateFormat = "yyyy-MM-dd"
        
        let printDateFormatter = DateFormatter()
        printDateFormatter.dateFormat = "MMMM d, yyyy"
        
        let date = rawDateFormatter.date(from: (movie["release_date"] as? String)!)
        releaseDate.text = printDateFormatter.string(from: date!)
        
        infoView.frame.size.height = (10 * overviewLabel.frame.size.height) + titleLabel.frame.size.height
        infoView.layer.cornerRadius = 8.0

        scrollView.contentSize = CGSize(width: infoView.frame.size.width, height: infoView.frame.origin.y + overviewLabel.frame.size.height + (6.25 * (self.tabBarController?.tabBar.frame.size.height)!))
        scrollView.showsVerticalScrollIndicator = false
        
        self.navigationItem.title = movie["title"] as? String
        
        
        let lowResUrl = "https://image.tmdb.org/t/p/w45"
        let originalUrl = "https://image.tmdb.org/t/p/original"
        if let posterPath = movie["poster_path"] as? String {
            let smallImageRequest = NSURLRequest(url: NSURL(string: lowResUrl + posterPath)! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: originalUrl + posterPath)! as URL)
            
            posterImageView.setImageWith(
                smallImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                    }, completion: { (success) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWith(
                            largeImageRequest as URLRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage;
                                self.infoView.isHidden = false

                        },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                                self.infoView.isHidden = false
                        })
                    })
            },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
                    self.infoView.isHidden = false
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
