//
//  EpisodesController.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/17/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
   
    var podcast: Podcast? {
      
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes(){
        
        guard let feedUrl = podcast?.feedUrl else {return}
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    //MARK:- Setup Work
    
    fileprivate func setupNavigationBarButtons() {
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let hasFavorited = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) != nil
        
        if hasFavorited {
            // setting up our heart icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
            
        }
        else {
            navigationItem.rightBarButtonItems = [
                
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
                UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handlefetchSavedPodcasts))
            ]
        }
    }
    
    @objc fileprivate func handlefetchSavedPodcasts() {
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritePodcastKey) else {return}
        
        let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        
        savedPodcasts?.forEach({ (p) in
            print(p.trackName ?? "")
        })
    }
    
    @objc fileprivate func handleSaveFavorite() {
        
        guard let podcast = self.podcast else {return}
        
        
        // 1. transform Podcast into Data
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritePodcastKey)
        
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
    }
    
    fileprivate func showBadgeHighlight() {
        
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
        
    }
    fileprivate func showBadgeDownloadHighlight() {
        
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
        
    }
    fileprivate func setupTableView(){

        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
         tableView.tableFooterView = UIView()
    }
    
    //MARK:- UITableView
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            
            print("Downloading Episodes into UserDefualts")
            
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            //download the episodes using Alamofire
            APIService.shared.downloadEpisode(episode: episode)
            
            self.showBadgeDownloadHighlight()
        }
        return [downloadAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    // handles tappes when user click on the episode
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = self.episodes[indexPath.row]
        
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = self.episodes[indexPath.row]
        cell.episode = episode
     
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
