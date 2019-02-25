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

        guard let url = URL(string: episode.streamUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        }
        else {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
            shrinkEpisodeImageView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        observePlayerCurrentTime()
        
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        //player has a reference to self
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
        }
    }
    
    deinit {
        print("PlayerDetailsView memory being reclaimed ...")
    }
    
    //MARK:- PlayerCurrentTime and updateCurrentSlider
    
    fileprivate func observePlayerCurrentTime() {
        
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime =  self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    //MARK:- Enlarge and Shrink methods
    
    fileprivate let  shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate func enlargeEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }

    fileprivate func shrinkEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }
    
   

    //MARK:- IBoutlets
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
   
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func handledDismiss(_sender: Any){
        self.removeFromSuperview()
        //enlargeEpisodeImageView()
    }
}
