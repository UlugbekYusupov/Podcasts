//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by Ulugbek Yusupov on 2/6/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .purple
        setupViewController()
    }
    
    //MARK:- Setup funcitons
    
    func setupViewController() {
        
        viewControllers = [
            generateNavigationController(with: ViewController(), title: "Favourites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: ViewController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    //MARK: Helper functions
    
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        rootViewController.navigationItem.title = title
        
        return navController
    }
    
    
    
    
}
