//
//  EpisodesController.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/17/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
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
        
    }
    
    //MARK:- Setup Work
    fileprivate func setupTableView(){

        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
         tableView.tableFooterView = UIView()
    }
    
    //MARK:- UITableView
    
    
    // handles tappes when user click on the episode
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        print("lfjsdlkfjlsdkfjsdlf", episode.title)
        
        let window = UIApplication.shared.keyWindow
        
        let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
        
        playerDetailsView.episode = episode
        
        playerDetailsView.frame = self.view.frame
        window?.addSubview(playerDetailsView)
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
