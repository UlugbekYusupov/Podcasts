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
