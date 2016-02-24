//
//  ReplyViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/23/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetedAtLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var retweetButton: RetweetButton!
    @IBOutlet weak var favoriteButton: FavoriteButton!

    static private let _dateFormatter = NSDateFormatter()
    static private var dateFormatter: NSDateFormatter {
        _dateFormatter.dateStyle = .ShortStyle
        _dateFormatter.timeStyle = .ShortStyle
        return _dateFormatter
    }

    var tweet: Tweet!

    @IBAction func didTapRetweet(sender: AnyObject) {
        TwitterClient.sharedClient.toggleRetweet(self.tweet,
            success: { () -> Void in
                self.refreshView()
            },
            failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
            }
        )
    }

    @IBAction func didTapFavorite(sender: AnyObject) {
        TwitterClient.sharedClient.toggleFavorite(self.tweet,
            success: { () -> Void in
                self.refreshView()
            },
            failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
            }
        )
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        let vc = navController.topViewController as! ComposeViewController
        vc.replyToTweet = self.tweet
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImageView.layer.cornerRadius = 5
        self.refreshView()
    }

    private func refreshView() {
        self.tweetTextView.text = self.tweet.text
        self.retweetCountLabel.text = String(self.tweet.retweetCount)
        self.favoritesCountLabel.text = String(self.tweet.favoritesCount)
        self.retweetButton.retweeted = self.tweet.retweeted
        self.favoriteButton.favorited = self.tweet.favorited
        if let user = self.tweet.user {
            self.nameLabel.text = user.name
            self.screennameLabel.text = "@\(user.screenname!)"
            if let profileImageUrl = user.profileImageUrl {
                self.profileImageView.setImageWithURL(profileImageUrl)
            }
        }
        if let timestamp = self.tweet.timestamp {
            self.tweetedAtLabel.text = ReplyViewController.dateFormatter.stringFromDate(timestamp)
        }
    }
}
