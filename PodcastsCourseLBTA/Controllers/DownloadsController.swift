//
//  DownloadsController.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 3/15/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        
        print(progress, title)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
    }
    //MARK:- Setup
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
    }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episodes = self.episodes[indexPath.row]
        
        if episodes.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episodes, playlistEpisodes: self.episodes)
        }
        else {
            
            let alertController = UIAlertController(title: "File URL not found", message: "Cannot find file, play using stream url instead", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episodes, playlistEpisodes: self.episodes)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alertController,animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let episode = self.episodes[indexPath.row]
        
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteDownloadedEpisode(episode: episode)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
