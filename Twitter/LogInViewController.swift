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
                self.performSegueWithIdentifier("LoginSegue", sender: nil)
            }, failure: { (error: NSError) -> Void in
                print(error.localizedDescription)
            }
        )
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let hvc = segue.destinationViewController as! HamburgerViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mvc = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        mvc.hamburgerViewController = hvc
        hvc.menuViewController = mvc
    }
}
