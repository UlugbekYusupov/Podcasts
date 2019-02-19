//
//  Podcast.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/7/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//


// Podcast struct with parameters
import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String? // url for image podcasts
    var trackCount: Int?
    var feedUrl: String? // url for each image episode in the podcasts
}

