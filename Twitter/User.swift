//
//  User.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class User: NSObject {
    static let kLogoutNotificationName = "UserDidLogout"

    var name: String?
    var screenname: String?
    var profileImageUrl: NSURL?
    var profileBackgroundImageUrl: NSURL?
    var tagline: String?
    var location: String?
    var followersCount: Int?
    var tweetsCount: Int?
    var followingCount: Int?

    var dictionary: NSDictionary?

    static let kCurrentUserDataKey = "CurrentUserData"
    static var _currentUser: User?
    static var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey(self.kCurrentUserDataKey) as? NSData
                if let userData = userData {
                    let userDictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: userDictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = NSUserDefaults.standardUserDefaults()

            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: self.kCurrentUserDataKey)
                defaults.synchronize()
            } else {
                defaults.setObject(nil, forKey: self.kCurrentUserDataKey)
            }
        }
    }

    convenience init(dictionary: NSDictionary) {
        self.init()
        self.dictionary = dictionary
        self.name = dictionary["name"] as? String
        self.screenname = dictionary["screen_name"] as? String
        self.tagline = dictionary["description"] as? String
        self.location = dictionary["location"] as? String
        self.followersCount = dictionary["followers_count"] as? Int
        self.followingCount = dictionary["friends_count"] as? Int
        self.tweetsCount = dictionary["statuses_count"] as? Int

        let profileImageURLString = dictionary["profile_image_url_https"] as? String
        if let profileImageURLString = profileImageURLString {
            self.profileImageUrl = NSURL(string: profileImageURLString)
        }
        let profileBackgroundImageURLString = dictionary["profile_background_image_url_https"] as? String
        if let profileBackgroundImageURLString = profileBackgroundImageURLString {
            self.profileBackgroundImageUrl = NSURL(string: profileBackgroundImageURLString)
        }
    }
}
