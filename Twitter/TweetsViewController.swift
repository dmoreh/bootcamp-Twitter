//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit
import SVPullToRefresh

class TweetsViewController: UIViewController {

    var mentionsOnly: Bool = false

    @IBOutlet weak var tweetsTableView: UITableView!
    var tweets: [Tweet]! {
        didSet {
            self.tweetsTableView.reloadData()
        }
    }

    @IBAction func didTapLogout(sender: AnyObject) {
        TwitterClient.sharedClient.logout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TwitterClient.sharedClient.delegate = self

        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 120

        self.tweetsTableView.addPullToRefreshWithActionHandler { () -> Void in
            self.fetchTweets()
        }

        self.tweetsTableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.fetchMoreTweets(beforeTweet: self.tweets.last)
        }

        self.fetchTweets()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailsSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tweetsTableView.indexPathForCell(cell)!
            let vc = segue.destinationViewController as! ReplyViewController
            vc.tweet = self.tweets[indexPath.row]
        } else if segue.identifier == "ComposeSegue" {
            if let cell = sender as? TweetCell {
                let navController = segue.destinationViewController as! UINavigationController
                let vc = navController.topViewController as! ComposeViewController
                vc.replyToTweet = cell.tweet
            }
        }
    }

    func fetchTweets() {
        TwitterClient.sharedClient.timeline(mentionsOnly: self.mentionsOnly,
            success: { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
                self.tweetsTableView.pullToRefreshView.stopAnimating()
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
                self.tweetsTableView.pullToRefreshView.stopAnimating()
            }
        )
    }

    func fetchMoreTweets(beforeTweet lastTweet: Tweet? = nil) {
        TwitterClient.sharedClient.timeline(mentionsOnly: self.mentionsOnly,
            beforeTweet: lastTweet,
            success: { (tweets: [Tweet]) -> Void in
                self.tweets.appendContentsOf(tweets)
                self.tweetsTableView.infiniteScrollingView.stopAnimating()
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
                self.tweetsTableView.infiniteScrollingView.stopAnimating()
            }
        )
    }
}

extension TweetsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension TweetsViewController: TweetCellDelegate {
    func tweetCellDidTapFavorite(tweetCell: TweetCell) {
        TwitterClient.sharedClient.toggleFavorite(tweetCell.tweet,
            success: nil) { (error: NSError) -> Void in
                print(error.localizedDescription)
        }
    }

    func tweetCellDidTapRetweet(tweetCell: TweetCell) {
        TwitterClient.sharedClient.toggleRetweet(tweetCell.tweet,
            success: nil,
            failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
            }
        )
    }

    func tweetCellDidTapReply(tweetCell: TweetCell) {
        self.performSegueWithIdentifier("ComposeSegue", sender: tweetCell)
    }

    func tweetCellDidTapProfileImage(tweetCell: TweetCell) {
        let user = tweetCell.tweet.user
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pvc = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        pvc.user = user
        self.navigationController?.pushViewController(pvc, animated: true)
    }
}

extension TweetsViewController: TwitterClientDelegate {
    func twitterClient(twitterClient: TwitterClient, didPostTweet tweet: Tweet) {
        self.tweets.insert(tweet, atIndex: 0)
        self.tweetsTableView.reloadData()
    }

    func twitterClient(twitterClient: TwitterClient, didRetweetTweet tweet: Tweet) {
        tweet.markRetweeted()
        self.tweetsTableView.reloadData()
    }

    func twitterClient(twitterClient: TwitterClient, didUnretweetTweet tweet: Tweet) {
        tweet.markUnretweeted()
        self.tweetsTableView.reloadData()
    }

    func twitterClient(twitterClient: TwitterClient, didFavoriteTweet tweet: Tweet) {
        tweet.markFavorited()
        self.tweetsTableView.reloadData()
    }

    func twitterClient(twitterClient: TwitterClient, didUnfavoriteTweet tweet: Tweet) {
        tweet.markUnfavorited()
        self.tweetsTableView.reloadData()
    }
}
