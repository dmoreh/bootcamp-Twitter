//
//  RetweetButton.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/23/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class RetweetButton: UIButton {
    var retweeted: Bool = false {
        didSet {
            guard !disabled else { return }
            
            if retweeted {
                self.setBackgroundImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                self.setBackgroundImage(UIImage(named: "retweet-action-on-pressed"), forState: .Highlighted)
            } else {
                self.setBackgroundImage(UIImage(named: "retweet-action"), forState: .Normal)
                self.setBackgroundImage(UIImage(named: "retweet-action-pressed"), forState: .Highlighted)
            }
        }
    }

    var disabled: Bool = false {
        didSet {
            if disabled {
                self.setBackgroundImage(UIImage(named: "retweet-action-inactive"), forState: .Normal)
            }
        }
    }
}
