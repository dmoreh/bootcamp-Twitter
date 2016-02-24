//
//  ReplyButton.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/23/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class ReplyButton: UIButton {
    override func awakeFromNib() {
        self.setBackgroundImage(UIImage(named: "reply-action"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "reply-action-pressed"), forState: .Highlighted)
    }
}
