//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

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

        self.tweetsTableView.dataSource = self
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 120

        self.fetchTweets()
    }

    private func fetchTweets() {
        TwitterClient.sharedClient.homeTimeline(
            { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
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
        return cell
    }
}
