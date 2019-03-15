//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/20/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupAudioSession()
            playEpisode()
            
            setupNowPlayingInfo()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url)
            
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                let image = self.episodeImageView.image ?? UIImage()
                
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                    return image
                })
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    fileprivate func playEpisode() {
        
        if episode.fileUrl != nil {
            
            playEpisodeUsingFileURL()
        }
            
        else {
        
            print("attept to play episode with streamUrl: ", episode.streamUrl)
            
            guard let url = URL(string: episode.streamUrl) else {return}
            let playerItem = AVPlayerItem(url: url)
            
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }
    
    fileprivate func playEpisodeUsingFileURL() {
        
        print("attempt tp play episode with file url: ", episode.fileUrl ?? "")
        
        // file name episode file irl
        
        guard let fileURL = URL(string: episode.fileUrl ?? "") else {return}
        
        let fileName = fileURL.lastPathComponent
        
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        trueLocation.appendPathComponent(fileName)
        
        print("true location of our episode: ",trueLocation.absoluteString)
        
        let playerItem = AVPlayerItem(url: trueLocation)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    //MARK:- Handle Methods
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
            
        }
        else {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }

    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }
        else if gesture.state == .ended {
            
            let translation = gesture.translation(in: superview)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.maximizedStackView.transform = .identity
                
                if translation.y > 50 {
                    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabBarController?.minimizePlayerDetails()
                }
            })
        }
    }
    
    var playListEpisodes = [Episode]()
    
    @objc func handlePrevTrack() {
        
        if playListEpisodes.isEmpty {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else {return}
        
        let prevEpisode: Episode
        
        if index == 0 {
            let count = playListEpisodes.count
            prevEpisode = playListEpisodes[count - 1]
        }
        else {
            prevEpisode = playListEpisodes[index - 1]
        }
        
        self.episode = prevEpisode
    }
    
    @objc func handleNextTrack() {
        
        if playListEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else {return}
        
        let nextEpisode: Episode
        
        if index == playListEpisodes.count - 1 {
            nextEpisode = playListEpisodes[0]
        }
        else {
            nextEpisode = playListEpisodes[index + 1]
        }
        
        
        self.episode = nextEpisode
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        }
        else {
            
            guard let options = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    
    // MARK: Awake From NIb
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestures()
        setupRemoteControl()
        setupInterruptionObserver()
        
        observePlayerCurrentTime()
        
        observeBoundaryTime()
    }
    
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }

    //MARK:- Set up Methods
    
    fileprivate func setupNowPlayingInfo() {
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
  
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan
            ))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
       
    }

    // configuring audi player to show on command center
    fileprivate func setupAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
        
    }
    
    //configuring music remote controller in command center
    fileprivate func setupRemoteControl() {
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        //handling play button on the commmand center
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.setupElapsedTime(playbackRate: 1)
            
            return .success
        }
        
        //handling pause button on the command center
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            
            return .success
        }
        
        //enabling to use play pause button when using earphones or headphones
        commandCenter.togglePlayPauseCommand.isEnabled = true
        
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    }
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        
        let elapsed = CMTimeGetSeconds(player.currentTime())
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        
    }
  
    fileprivate func setUpLockScreenDuration() {
        
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = durationInSeconds
    }
    
    fileprivate func setupInterruptionObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
    }
  
    //MARK:- Time configuring Methods
    
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
    
    
    fileprivate func observeBoundaryTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        //player has a reference to self
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
            self?.setUpLockScreenDuration()
            
        }
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
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniFastForwardButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
   
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }
   
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
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleMiniFastForward(_ sender: Any) {
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
       let mainTabBarController =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }
}
