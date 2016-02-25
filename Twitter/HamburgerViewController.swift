//
//  HamburgerViewController.swift
//  HamburgerDemo
//
//  Created by Daniel Moreh on 2/25/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!

    var originalLeftMargin: CGFloat!
    var menuViewController: UIViewController! {
        didSet {
            self.view.layoutIfNeeded()
            self.menuView.addSubview(self.menuViewController.view)
        }
    }
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }

            self.view.layoutIfNeeded()

            self.contentViewController.willMoveToParentViewController(self)
            self.contentView.addSubview(self.contentViewController.view)
            self.contentViewController.didMoveToParentViewController(self)

            UIView.animateWithDuration(0.3) { () -> Void in
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onPanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translationInView(self.view)
        let velocity = panGestureRecognizer.velocityInView(self.view)

        switch panGestureRecognizer.state {
        case .Began:
            self.originalLeftMargin = self.leftMarginConstraint.constant
        case .Changed:
            self.leftMarginConstraint.constant = self.originalLeftMargin + translation.x
        case .Ended:
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width * 0.6
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        default:
            break
        }
    }

}

