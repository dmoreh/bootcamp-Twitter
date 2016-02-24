//
//  TwitterClient.swift
//  Twitter
//
//  Created by Daniel Moreh on 2/22/16.
//  Copyright © 2016 Daniel Moreh. All rights reserved.
//

import BDBOAuth1Manager

@objc protocol TwitterClientDelegate {
    optional func twitterClient(twitterClient: TwitterClient, didPostTweet tweet: Tweet)
    optional func twitterClient(twitterClient: TwitterClient, didFavoriteTweet tweet: Tweet)
    optional func twitterClient(twitterClient: TwitterClient, didUnfavoriteTweet tweet: Tweet)
    optional func twitterClient(twitterClient: TwitterClient, didRetweetTweet tweet: Tweet)
    optional func twitterClient(twitterClient: TwitterClient, didUnretweetTweet tweet: Tweet)
}

class TwitterClient: BDBOAuth1SessionManager {

    typealias EmptySuccessCallback = () -> Void
    typealias FailureCallback = (NSError) -> Void

    private static let shouldMockPosts = true

    private static let twitterBaseURL = NSURL(string: "https://api.twitter.com")
    private static let twitterConsumerKey = "eILdArI1Y6zCs4yVydfUyaJJu"
    private static let twitterConsumerSecret = "qRTLDsHAeCK09sjlWcvNcDZC1YE0WNN2jVqIxdtPc9bW4Vtgso"

    static let sharedClient = TwitterClient(
        baseURL: twitterBaseURL,
        consumerKey: twitterConsumerKey,
        consumerSecret: twitterConsumerSecret
    )

    private var loginSuccess: EmptySuccessCallback?
    private var loginFailure: FailureCallback?

    var delegate: TwitterClientDelegate?

    func homeTimeline(beforeTweet lastTweet: Tweet? = nil, success: (([Tweet]) -> Void)?, failure: FailureCallback?) {

        var parameters: NSDictionary? = nil
        if let lastTweet = lastTweet {
            parameters = ["max_id": lastTweet.id - 1]
        }
        GET("1.1/statuses/home_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! Array)
                success?(tweets)
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    func tweet(text: String, inReplyToTweet tweet: Tweet?, success: EmptySuccessCallback, failure: FailureCallback) {
        guard !TwitterClient.shouldMockPosts else {
            let tweet = TwitterClient.fakeNewTweet(text)
            self.delegate?.twitterClient?(self, didPostTweet: tweet)
            success()
            return
        }

        var parameters = ["status": text]
        if let id = tweet?.id {
            parameters["in_reply_to_status_id"] = String(id)
        }

        POST("1.1/statuses/update.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let responseDictionary = response as! NSDictionary
                let tweet = Tweet(dictionary: responseDictionary)
                self.delegate?.twitterClient?(self, didPostTweet: tweet)
                success()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }

    func toggleRetweet(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        if tweet.retweeted {
            self.unretweet(tweet, success: success, failure: failure)
        } else {
            self.retweet(tweet, success: success, failure: failure)
        }
    }

    func retweet(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        guard !TwitterClient.shouldMockPosts else {
            self.delegate?.twitterClient?(self, didRetweetTweet: tweet)
            success?()
            return
        }

        POST("1.1/statuses/retweet/\(tweet.id).json",
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                self.delegate?.twitterClient?(self, didRetweetTweet: tweet)
                success?()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    func unretweet(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        guard !TwitterClient.shouldMockPosts else {
            self.delegate?.twitterClient?(self, didUnretweetTweet: tweet)
            success?()
            return
        }

        guard tweet.retweeted else {
            let error = NSError(
                domain: "TwitterClient",
                code: 0,
                userInfo: ["localizedDescription": "Could not unretweet a tweet that wasn't retweeted."])
            failure?(error)
            return
        }

        var originalTweetId = tweet.id
        if let retweetedStatus = tweet.retweetedStatus {
            originalTweetId = retweetedStatus["id_str"] as! Int
        }

        self.getFullTweet(originalTweetId,
            success: { (fullTweet: Tweet) -> Void in
                guard let retweetId = fullTweet.retweetId else { return }

                self.deleteTweet(retweetId, success: { () -> Void in
                    self.delegate?.twitterClient?(self, didUnretweetTweet: tweet)
                    success?()
                    }, failure: { (error: NSError) -> Void in
                        failure?(error)
                })

            }) { (error: NSError) -> Void in
                failure?(error)
        }
    }

    private func getFullTweet(tweetId: Int, success: (Tweet) -> Void, failure: FailureCallback?) {
        GET("1.1/statuses/show/\(tweetId).json",
            parameters: ["include_my_retweet": true],
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let responseDictionary = response as! NSDictionary
                let tweet = Tweet(dictionary: responseDictionary)
                success(tweet)
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    private func deleteTweet(tweetId: Int, success: EmptySuccessCallback?, failure: FailureCallback?) {
        POST("1.1/statuses/destroy/\(tweetId).json",
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                success?()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    func toggleFavorite(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        if tweet.favorited {
            self.unfavorite(tweet, success: success, failure: failure)
        } else {
            self.favorite(tweet, success: success, failure: failure)
        }
    }

    func favorite(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        guard !TwitterClient.shouldMockPosts else {
            self.delegate?.twitterClient?(self, didFavoriteTweet: tweet)
            success?()
            return
        }

        POST("1.1/favorites/create.json",
            parameters: ["id": tweet.id],
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                self.delegate?.twitterClient?(self, didFavoriteTweet: tweet)
                success?()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
    }

    func unfavorite(tweet: Tweet, success: EmptySuccessCallback?, failure: FailureCallback?) {
        guard !TwitterClient.shouldMockPosts else {
            self.delegate?.twitterClient?(self, didUnfavoriteTweet: tweet)
            success?()
            return
        }

        POST("1.1/favorites/destroy.json",
            parameters: ["id": tweet.id],
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                self.delegate?.twitterClient?(self, didUnfavoriteTweet: tweet)
                success?()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure?(error)
        }
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

extension TwitterClient {
    static func fakeNewTweet(text: String) -> Tweet {
        let fakeTweetDictionary = [
            "created_at": "Wed Feb 24 00:47:31 +0000 2016",
            "favorites_count": 0,
            "favorited": 0,
            "retweet_count": 0,
            "retweeted": 0,
            "text": text,
        ]
        
        let tweet = Tweet(dictionary: fakeTweetDictionary)
        tweet.timestamp = NSDate()
        tweet.user = User.currentUser

        return tweet

    }
}