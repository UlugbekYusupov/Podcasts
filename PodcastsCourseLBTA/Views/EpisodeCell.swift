//
//  EpisodeCellTableViewCell.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/19/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    
    var episode: Episode! {
        
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text =  dateFormatter.string(from: episode.pubDate)
        }
    }
    
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
}
