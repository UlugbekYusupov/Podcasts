//
//  Podcast.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/7/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//
// Podcast struct with parameters

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
    
    //saving data
    func encode(with aCoder: NSCoder) {
        print("trying to transform podcat into data")
        
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKey")

    }
    
    //fetching data
    required init?(coder aDecoder: NSCoder) {
        print("trying to turn data into Podcast")
        
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String? // url for image podcasts
    var trackCount: Int?
    var feedUrl: String? // url for each image episode in the podcasts
}

