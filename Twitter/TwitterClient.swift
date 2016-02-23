//
//  TwitterClient.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

    typealias EmptySuccessCallback = () -> Void
    typealias FailureCallback = (NSError) -> Void

    static let shouldMockTweet = true

    static let twitterBaseURL = NSURL(string: "https://api.twitter.com")
    static let twitterConsumerKey = "eILdArI1Y6zCs4yVydfUyaJJu"
    static let twitterConsumerSecret = "qRTLDsHAeCK09sjlWcvNcDZC1YE0WNN2jVqIxdtPc9bW4Vtgso"

    static let sharedClient = TwitterClient(
        baseURL: twitterBaseURL,
        consumerKey: twitterConsumerKey,
        consumerSecret: twitterConsumerSecret
    )

    private var loginSuccess: EmptySuccessCallback?
    private var loginFailure: FailureCallback?

    func homeTimeline(success: (([Tweet]) -> Void)?, failure: FailureCallback?) {
        GET("1.1/statuses/home_timeline.json",
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! Array)
                success?(tweets)
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    func tweet(text: String, success: EmptySuccessCallback, failure: FailureCallback) {
        guard !TwitterClient.shouldMockTweet else {
            success()
            return
        }

        POST("1.1/statuses/update.json",
            parameters: ["status": text],
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                success()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }

    func retweet(success: EmptySuccessCallback, failure: FailureCallback) {
        
    }

    func login(success: EmptySuccessCallback, failure: FailureCallback) {
        self.loginSuccess = success
        self.loginFailure = failure

        let twitterClient = TwitterClient.sharedClient
        twitterClient.deauthorize()
        twitterClient.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "twitterdemo://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("token")
                let url = NSURL(string: "\(TwitterClient.twitterBaseURL!)/oauth/authorize?oauth_token=\(requestToken.token)")!
                UIApplication.sharedApplication().openURL(url)

            }) { (error: NSError!) -> Void in
                print("error: \(error.localizedDescription)")
        }
    }

    func logout() {
        User.currentUser = nil
        deauthorize()

        NSNotificationCenter.defaultCenter().postNotificationName(User.kLogoutNotificationName, object: nil)
    }

    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        self.fetchAccessTokenWithPath("oauth/access_token",
            method: "POST",
            requestToken: requestToken,
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                print("access")
                self.GET("1.1/account/verify_credentials.json",
                    parameters: nil,
                    progress: nil,
                    success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                        self.currentAccount({ (user: User) -> Void in
                            User.currentUser = user
                            self.loginSuccess?()
                            }, failure: { (error: NSError) -> Void in
                                self.loginFailure?(error)
                        })
                    },
                    failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                        self.loginFailure?(error)
                    }
                )
            }) { (error: NSError!) -> Void in
                print("error: \(error.localizedDescription)")
        }
    }

    func currentAccount(success: (User) -> Void, failure: FailureCallback) {
        GET("1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let userDictionary = response as! NSDictionary
                let user = User(dictionary: userDictionary)
                success(user)
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }
}
