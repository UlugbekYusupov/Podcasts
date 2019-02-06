//
//  PodcastSearchController.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/6/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import Alamofire

class PodcastSearchController: UITableViewController, UISearchBarDelegate {
    
    var podcast = [
        Podcast(trackName: "Let's Build That App", artistName: "Brian Voong"),
         Podcast(trackName: "News of iOS", artistName: "Ulugbek Yusupov")
    ]
    
    let cellId = "cellId"
    
    // implementation if UISearchController
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
    }
    
    // MARK:- Setup functions
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText, "media": "podcast"]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponce) in
                
                if let err = dataResponce.error {
                    print("Failed to connect", err)
                    return
                }
                guard let data = dataResponce.data else {return}
                
                do {
                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    
                    self.podcast = searchResult.results
                    self.tableView.reloadData()
                    
                }
                catch let decoderErr {
                    print("Failed to decode:", decoderErr)
            }
        }
    }
    
    struct SearchResult: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    fileprivate func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
     //MARK:- UITableView
    
    // determines how many cells is gonna be in the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let podcast = self.podcast[indexPath.row]
        
        // setting the name and artist name of podcasts and image icon on the cell
        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
        cell.textLabel?.numberOfLines = -1
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        
        return cell
    }
    
}
