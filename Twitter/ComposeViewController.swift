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
    @IBOutlet weak var tweetTextView: UITextView! {
        didSet {
            tweetTextView.delegate = self
            tweetTextView.text = ""
        }
    }
    @IBOutlet weak var charactersLeftLabel: UILabel!

    var replyToTweet: Tweet?
    static let kMaxTweetLength = 140

    @IBAction func didTapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTapTweet(sender: AnyObject) {
        TwitterClient.sharedClient.tweet(tweetTextView.text,
            inReplyToTweet: replyToTweet,
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
        if let screenname = self.replyToTweet?.user?.screenname {
            tweetTextView.text = "@\(screenname) "
        }
        tweetTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        tweetTextView.resignFirstResponder()
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return newText.characters.count <= ComposeViewController.kMaxTweetLength
    }

    func textViewDidChange(textView: UITextView) {
        self.charactersLeftLabel.text = String(ComposeViewController.kMaxTweetLength - textView.text.characters.count)
    }
}
