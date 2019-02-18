//
//  Episode.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/19/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.description ?? ""
    }
}
