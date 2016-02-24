//
//  TweetCell.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    optional func tweetCellDidTapReply(tweetCell: TweetCell)
    optional func tweetCellDidTapRetweet(tweetCell: TweetCell)
    optional func tweetCellDidTapFavorite(tweetCell: TweetCell)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetedAtLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var replyButton: ReplyButton!
    @IBOutlet weak var retweetButton: RetweetButton!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!

    weak var delegate: TweetCellDelegate?

    static private let _dateFormatter = NSDateFormatter()
    static private var dateFormatter: NSDateFormatter {
        _dateFormatter.dateStyle = .ShortStyle
        return _dateFormatter
    }

    var tweet: Tweet! {
        didSet {
            guard let tweet = tweet else { return }

            self.tweetTextLabel.text = tweet.text
            self.favoriteButton.favorited = tweet.favorited
            self.retweetButton.retweeted = tweet.retweeted
            self.retweetCountLabel.text = String(tweet.retweetCount)
            self.favoriteCountLabel
                .text = String(tweet.favoritesCount)
            if let user = tweet.user {
                self.nameLabel.text = user.name
                self.screennameLabel.text = "@\(user.screenname!)"
                if let profileImageUrl = user.profileImageUrl {
                    self.profileImageView.setImageWithURL(profileImageUrl)
                }
            }
            if let timestamp = tweet.timestamp {
                self.tweetedAtLabel.text = timestamp.displayString()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.profileImageView.layer.cornerRadius = 5
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func didTapReply(sender: AnyObject) {
        delegate?.tweetCellDidTapReply?(self)
    }

    @IBAction func didTapRetweet(sender: AnyObject) {
        self.retweetButton.retweeted = true
        delegate?.tweetCellDidTapRetweet?(self)
    }

    @IBAction func didTapFavorite(sender: AnyObject) {
        self.favoriteButton.favorited = true
        delegate?.tweetCellDidTapFavorite?(self)
    }
}

extension NSDate {
    func displayString() -> String {
        let calendar = NSCalendar.currentCalendar()

        let seconds = calendar.components(.Second, fromDate: self, toDate: NSDate(), options: []).second
        if seconds < 60 {
            return "\(seconds)s"
        }

        let minutes = calendar.components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if minutes < 60 {
            return "\(minutes)m"
        }

        let hours = calendar.components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if hours < 24 {
            return "\(hours)h"
        }

        return TweetCell.dateFormatter.stringFromDate(self)
    }
}
