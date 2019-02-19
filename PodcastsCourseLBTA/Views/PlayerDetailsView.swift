//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/20/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        
        didSet {
            
            titleLabel.text = episode.title
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            
        }
        
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func handledDismiss(_sender: Any){
        
        self.removeFromSuperview()
        
    }
    
}
