//
//  FavoriteButton.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/23/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    var favorited: Bool = false {
        didSet {
            if favorited {
                self.setBackgroundImage(UIImage(named: "like-action-on"), forState: .Normal)
                self.setBackgroundImage(UIImage(named: "like-action-on-pressed"), forState: .Highlighted)
            } else {
                self.setBackgroundImage(UIImage(named: "like-action"), forState: .Normal)
                self.setBackgroundImage(UIImage(named: "like-action-pressed"), forState: .Highlighted)
            }
        }
    }
}
