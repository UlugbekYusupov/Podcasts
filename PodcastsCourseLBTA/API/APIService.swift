//
//  APIService.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/7/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import Alamofire
import FeedKit

extension NSNotification.Name {
    static  let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, espisodeTitle: String)
    
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    
    //singleton
    static let shared = APIService()
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episodes using Alamofire at stream url: ", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            
            // notify DownloadsController about download progress
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title,"progress": progress.fractionCompleted])
            
            }.response { (resp) in
                print(resp.destinationURL?.absoluteString ?? "")
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "", episode.title)
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                
                //update UseerDefaults downloaded episodes with this temp file
                
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.index(where: { $0.title == episode.title && $0.author == episode.author}) else {return}
                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    
                    UserDefaults.standard.set(data, forKey: UserDefaults.downdloadedEpisodeKey)
                    
                } catch let err {
                    print("Failed to encode downloaded episode with fileUrl update", err)
                }
        }
    }
    
    // actual fetching episodes from the net
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        //making secure domains
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        
        // creating url for parsing JSON object returned from feed search
        guard let url = URL(string: secureFeedUrl) else {return}
        
        DispatchQueue.global(qos: .background).async {
            
            let parser = FeedParser(URL: url)
            
            //parsing that obejct and assigning it into result var
            parser?.parseAsync(result: { (result) in
                print("done",result.isSuccess)
                
                // checking if result is correctly parsed or not
                if let err = result.error {
                    print("Failed to parse feed: ", err)
                    return
                }
                
                guard let feed = result.rssFeed else {return}
                
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            })
        }
    }
    
    // actual podcast fetching
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcasts...")
        
        let parameters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            
            if let err = dataResponse.error {
                print("Failed to contact yahoo", err)
                return
            }
            
            guard let data = dataResponse.data else { return }
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResult.results)
            } catch let decodeErr {
                print("Failed to decode:", decodeErr)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
}





