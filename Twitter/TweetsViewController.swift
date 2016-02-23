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

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchTweets:", forControlEvents: .ValueChanged)
        self.tweetsTableView.addSubview(refreshControl)

        self.fetchTweets(nil)
    }

    func fetchTweets(refreshControl: UIRefreshControl?) {
        TwitterClient.sharedClient.homeTimeline(
            { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
                refreshControl?.endRefreshing()
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
                refreshControl?.endRefreshing()
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
