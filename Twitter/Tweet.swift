//
//  Tweet.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?

    static private let _dateFormatter = NSDateFormatter()
    static private var dateFormatter: NSDateFormatter {
        _dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return _dateFormatter
    }

    convenience init(dictionary: NSDictionary) {
        self.init()

        self.text = dictionary["text"] as? String
        self.retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        self.favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        let userDictionary = dictionary["user"] as? NSDictionary
        if let userDictionary = userDictionary {
            self.user = User(dictionary: userDictionary)
        }

        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString {
            self.timestamp = Tweet.dateFormatter.dateFromString(timestampString)
        }
    }

    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        let tweets = dictionaries.map { (dictionary: NSDictionary) -> Tweet in
            Tweet(dictionary: dictionary)
        }

        return tweets
    }
}
