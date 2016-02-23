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
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    static private let _dateFormatter = NSDateFormatter()
    static private var dateFormatter: NSDateFormatter {
        _dateFormatter.dateStyle = .ShortStyle
        _dateFormatter.timeStyle = .ShortStyle
        return _dateFormatter
    }

    var tweet: Tweet!

    @IBAction func didTapRetweet(sender: AnyObject) {
        TwitterClient.sharedClient.retweet(self.tweet,
            success: { () -> Void in
                self.retweetButton.setBackgroundImage(UIImage(named: "retweet-action-on"), forState: .Normal)
            }) { (error: NSError) -> Void in
                print(error.localizedDescription)
        }
    }

    @IBAction func didTapFavorite(sender: AnyObject) {
        TwitterClient.sharedClient.favorite(self.tweet,
            success: { () -> Void in
                self.favoriteButton.setBackgroundImage(UIImage(named: "like-action-on"), forState: .Normal)
            }) { (error: NSError) -> Void in
                print(error.localizedDescription)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        let vc = navController.topViewController as! ComposeViewController
        vc.replyToTweet = self.tweet
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImageView.layer.cornerRadius = 5

        self.tweetTextView.text = tweet.text
        self.retweetCountLabel.text = String(tweet.retweetCount)
        self.favoriteCountLabel.text = String(tweet.favoritesCount)
        if let user = tweet.user {
            self.nameLabel.text = user.name
            self.screennameLabel.text = "@\(user.screenname!)"
            if let profileImageUrl = user.profileImageUrl {
                self.profileImageView.setImageWithURL(profileImageUrl)
            }
        }
        if let timestamp = tweet.timestamp {
            self.tweetedAtLabel.text = ReplyViewController.dateFormatter.stringFromDate(timestamp)
        }

        // Do any additional setup after loading the view.
    }
}
