//
//  PodcastCell.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/6/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            print("Loading image with url: ", podcast.artworkUrl600 ?? "")
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else {return}
            
            
            //Loading image from the url without caching
            
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//
//                guard let data = data else {return}
//
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//
//            }.resume()
            
            //loading image from the url with caching and wtih help of SDWebImage
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
