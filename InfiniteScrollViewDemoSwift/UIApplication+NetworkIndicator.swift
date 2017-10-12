//
//  UIApplication+NetworkIndicator.swift
//  InfiniteScrollViewDemoSwift
//
//  Created by Riddhi Ojha on 10/13/17.
//  Copyright © 2017 Riddhi Ojha. All rights reserved.
//

import Foundation

private var networkActivityCount = 0

extension UIApplication {
    
    func startNetworkActivity() {
        networkActivityCount += 1
        isNetworkActivityIndicatorVisible = true
    }
    
    func stopNetworkActivity() {
        if networkActivityCount < 1 {
            return;
        }
        
        networkActivityCount -= 1
        if networkActivityCount == 0 {
            isNetworkActivityIndicatorVisible = false
        }
    }
    
}
