//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/25/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var user: User! {
        didSet {
            guard user != nil else { return }
            self.view.layoutIfNeeded()

            if let profileImageUrl = user.profileImageUrl {
                self.profilePhotoImageView.setImageWithURL(profileImageUrl)
            }
            if let profileBackgroundImageUrl = user.profileBackgroundImageUrl {
                self.profileBackgroundImageView.setImageWithURL(profileBackgroundImageUrl)
            }
            self.tweetsCountLabel.text = String(user.tweetsCount ?? 0)
            self.followersCountLabel.text = String(user.followersCount ?? 0 )
            self.followingCountLabel.text = String(user.followingCount ?? 0)
        }
    }

    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
