//
//  UserDefaults.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 3/14/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritePodcastKey = "favoritePodcastKey"
    static let downdloadedEpisodeKey = "downdloadedEpisodeKey"
    
    func deleteDownloadedEpisode(episode: Episode) {
        
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downdloadedEpisodeKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
        
    }
    
    func downloadEpisode(episode: Episode) {
        
        var episodes = downloadedEpisodes()
        episodes.append(episode)
        
        do {
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downdloadedEpisodeKey)
            
        } catch let encodeErr {
            print("Failed to encode episode",encodeErr)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.downdloadedEpisodeKey) else {return []}
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: data)
            return episodes
            
        } catch let episodeErr {
            print("Failed to decode the Episode", episodeErr)
        }
        
        return []
    }
    
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritePodcastKey) else {return [] }
        
        guard let savedPodcast = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return [] }
        
        return savedPodcast
    }
    
    func deletePodcast(podcast: Podcast) {
        
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritePodcastKey)
    }
}
