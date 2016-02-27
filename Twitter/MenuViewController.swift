//
//  MenuViewController.swift
//  HamburgerDemo
//
//  Created by Daniel Moreh on 2/25/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var hamburgerViewController: HamburgerViewController!
    var viewControllers: [UIViewController]!
    var menuNames: [UIViewController: String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tnvc = storyboard.instantiateViewControllerWithIdentifier("TweetsNavigationController")
        let pnvc = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
        let pvc = pnvc.topViewController as! ProfileViewController
        pvc.user = User.currentUser
        let mnvc = storyboard.instantiateViewControllerWithIdentifier("TweetsNavigationController") as! UINavigationController
        let mvc = mnvc.topViewController as! TweetsViewController
        mvc.mentionsOnly = true
        self.viewControllers = [tnvc, pnvc, mnvc]
        self.menuNames = [
            tnvc: "Home",
            pnvc: "Profile",
            mnvc: "Mentions"
        ]

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.hamburgerViewController.contentViewController = self.viewControllers.first
    }

}

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        }
        cell?.textLabel?.text = self.menuNames[viewControllers[indexPath.row]]
        return cell!
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
}
