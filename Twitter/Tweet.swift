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
    private(set) var retweetCount = 0
    private(set) var favoritesCount = 0
    private(set) var favorited = false
    private(set) var retweeted = false
    var retweetedStatus: NSDictionary?
    var retweetId: Int? {
        get {
            guard let retweetedStatus = self.retweetedStatus,
                currentUserRetweet = retweetedStatus["current_user_retweet"],
                id = currentUserRetweet["id_str"]  else {
                    return nil
            }

            return id as? Int
        }
    }
    var user: User?
    var id: Int!

    static private let _dateFormatter = NSDateFormatter()
    static private var dateFormatter: NSDateFormatter {
        _dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return _dateFormatter
    }

    convenience init(dictionary: NSDictionary) {
        self.init()

        self.text = dictionary["text"] as? String
        self.retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        self.favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        self.id = dictionary["id"] as? Int
        self.favorited = dictionary["favorited"] as? Bool ?? false
        self.retweeted = dictionary["retweeted"] as? Bool ?? false
        self.retweetedStatus = dictionary["retweeted_status"] as? NSDictionary

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

    func markRetweeted() {
        self.retweeted = true
        self.retweetCount += 1
    }

    func markUnretweeted() {
        self.retweeted = false
        self.retweetCount -= 1
    }

    func markFavorited() {
        self.favorited = true
        self.favoritesCount += 1
    }

    func markUnfavorited() {
        self.favorited = false
        self.favoritesCount -= 1
    }
}
