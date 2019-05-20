//
//  AppDelegate.swift
//  RadarSwiftDemo
//
//  Created by asnail on 2019/5/20.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

import UIKit
import Radar

class WebViewController: UIViewController {
    var webUrl: String = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RadarDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let radarConfig = RadarConfig.init()
        radarConfig.delegate = self
        radarConfig.channel = "v2"
        radarConfig.customAppVersion = "1.0.1"
        Radar.start(withAppId: "your-app-id", enableOptions: RAPerformanceDetectorEnableOption.all, config: radarConfig)
        return true
    }
    
    // MARK: - RadarDelegate
    func alias(for viewController: UIViewController) -> String {
        if let vc = viewController as? WebViewController {
            return vc.webUrl
        }
        return "";
    }
    
}

