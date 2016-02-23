//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!


    @IBAction func didTapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTapTweet(sender: AnyObject) {
        TwitterClient.sharedClient.tweet(tweetTextView.text,
            success: { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }) { (error: NSError) -> Void in
                print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = User.currentUser {
            self.nameLabel.text = user.name
            if let screenname = user.screenname {
                self.screennameLabel.text = "@\(screenname)"
            }
            if let profileImageUrl = user.profileImageUrl {
                self.profileImageView.setImageWithURL(profileImageUrl)
            }
        }

        tweetTextView.text = ""
        tweetTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        tweetTextView.resignFirstResponder()
    }
}
