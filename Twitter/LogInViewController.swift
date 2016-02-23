//
//  LogInViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LogInViewController: UIViewController {

    @IBAction func didTapLogInButton(sender: AnyObject) {
        let twitterClient = TwitterClient.sharedClient
        twitterClient.login(
            { () -> Void in
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
            }
        )
    }

}
