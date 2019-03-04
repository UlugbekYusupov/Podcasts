//
//  UIApplication.swift
//  PodcastsCourseLBTA
//
//  Created by Ulugbek Yusupov on 3/4/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
