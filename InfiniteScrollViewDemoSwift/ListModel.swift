//
//  ListModel.swift
//  InfiniteScrollViewDemoSwift
//
//  Created by Riddhi Ojha on 10/13/17.
//  Copyright © 2017 Riddhi Ojha. All rights reserved.
//

import Foundation

private struct ListModelAttributes {
    static let url = "thumbnail"
    static let title = "title"
    static let author = "subject"
    static let price_value = "price_value"
    static let bedrooms = "bedrooms"
}

class ListModel {
    var title: String?
    var author: String?
    var url: URL
    var price_value: Double?
    var priceInString: String?
    var bedrooms: Int?
    
    init?(_ dictionary: [String: Any]) {
        // sometimes HN returns some trash
        guard let urlString = dictionary[ListModelAttributes.url] as? String,
              let urlObject = URL(string: urlString)
        else {
            return nil
        }
    
        title = dictionary[ListModelAttributes.title] as? String
        author = dictionary[ListModelAttributes.author] as? String
        url = urlObject
        
        priceInString = dictionary[ListModelAttributes.price_value] as? String
        price_value = Double((priceInString?.replacingOccurrences(of: ",", with: ""))!)
        
        bedrooms = dictionary[ListModelAttributes.bedrooms] as? Int
    }

}
