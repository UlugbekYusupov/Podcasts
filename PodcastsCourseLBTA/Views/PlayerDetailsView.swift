//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/20/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        
        didSet {
            
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            playEpisode()
            
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            
        }
        
    }
    
    let player: AVPlayer = {
        
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func playEpisode() {
        
        print("Trying to play episode ar url: ", episode.streamUrl)
        
        guard let url = URL(string: episode.streamUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    //MARK:- IBActions and IBoutlets
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @objc func handlePlayPause() {
        print("Trying to play pause")
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
        }
        else {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
        }
        
    }
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    @IBAction func handledDismiss(_sender: Any){
        self.removeFromSuperview()
    }
    
}
