//
//  CMTime.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 2/25/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d",minutes,seconds)
        
        return timeFormatString
    }
}
