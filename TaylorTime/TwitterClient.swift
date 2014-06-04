//
//  TwitterClient.swift
//  TaylorTime
//
//  Created by Marc Chambers on 6/3/14.
//  Copyright (c) 2014 Marc Chambers
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this
//  list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.//

import Foundation

// Here, we've got our Twitter client. This goes and fetches the tweets
// of the user we request. It also handles fetching the application token.

class TwitterClient {
    
    // Our Swift-y Tweet model. Not exactly "comprehensive."
    // Have you seen all the data Twitter stuffs into a tweet JSON blob? It's kinda silly.
    struct Tweet {
        var text:String?
    }
    
    var apiKey:String
    var apiSecret:String
    var accessToken:String?
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    
    init(apiKey: String, apiSecret: String)
    {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }
    
    // A quick way to get the latest tweets for the specified Twitter handle.
    // Requires you've already let it go fetch the bearer token.
    // If something goes wrong, and I mean anything, just returns a nil array.
    func getLatestTweetsForUser(screenName:String, completion:(tweets:Array<Tweet>?) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name="+screenName))
        
        request.HTTPMethod="GET"
        
        if accessToken
        {
            request.setValue("Bearer "+accessToken!, forHTTPHeaderField: "Authorization")
        }
        
        let task = session.dataTaskWithRequest(request) {
            (data: NSData!, response: NSURLResponse!, 😞: NSError!) -> () in
            
            // Decode the data, which we're expecting to be an array.
            // We're relying on the toll-free bridge between Swift and Cocoa's collection types here.
            
            if 😞
            {
                completion(tweets:nil)
            }
            else
            {
                if let timelineData:NSArray?=NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSArray {
                    
                    // We're getting back an NSArray of NSDictionary objects. Gross!
                    // Let's give our Swifty application the Swift objects it deserves.
                    
                    // Let's iterate the objects and Swiftify them.
                    var tweets=Array<Tweet>()
                    
                    for timelineObject:AnyObject in timelineData! {
                        
                        // Safely unpack it as a dictionary so we can access the juicy data within.
                        // All of our tweets are from the same person, so we can omit the "sender" model
                        // and just be like, hey, here's the text of the tweet. That's what you really want.

                        let timelineDict:Dictionary<NSString,AnyObject>? = timelineObject as? Dictionary<NSString,AnyObject>
                        if timelineDict
                        {
                            if let tweetText:AnyObject=timelineDict!["text"]
                            {
                                tweets+=Tweet(text: tweetText as? String)
                            }
                        }
                    }
                    
                    completion(tweets: tweets)
                }
                else
                {
                    completion(tweets: nil)
                }
            }
        }
        
        task.resume()
    }
    
    func getBearerToken(completion: (success: Bool, bearerToken: String?) -> ())
    {
        if apiKey == "" || apiSecret == ""
        {
            completion(success: false, bearerToken:nil)
            return
        }
        
        // Twitter wants us to URL-encode the API key and secret before concatenation.
        // but we're not.
        let unencodedCredential=apiKey+":"+apiSecret
        let unencodedCredentialData=unencodedCredential.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let encodedCredential:String=unencodedCredentialData.base64EncodedStringWithOptions(nil)
        
        // Create the request for the bearer token.
        var request=NSMutableURLRequest(URL: NSURL(string: "https://api.twitter.com/oauth2/token"))
        
        request.setValue("Basic "+encodedCredential, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody="grant_type=client_credentials".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPMethod="POST"
        
        // Send 'er up and hope for the best. We can use "trailing closure" syntax here,
        // because the closure is the last parameter of the function.
        
        let task=session.dataTaskWithRequest(request) {
            (data: NSData!, response: NSURLResponse!, 😞: NSError!) -> () in
            
            if 😞
            {
                println(😞)
                completion(success: false, bearerToken: nil)
            }
            else
            {
                
                // Decode the response. We do an awful lot of checking here.
                // If this operation failed, the JSON decoding will fail and we'll
                // simply fall through to "couldn't decode JSON data."
                
                if let tokenResponse:Dictionary<NSString,AnyObject>?=NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? Dictionary<NSString,AnyObject>
                {
                    if let bearerToken:AnyObject=tokenResponse!["access_token"]
                    {
                        self.accessToken=bearerToken as? String // Store the access token for later use.
                        completion(success: true, bearerToken: bearerToken as? String)
                    }
                    else
                    {
                        println("Couldn't fetch the bearer token")
                        completion(success: false, bearerToken: nil)
                    }
                }
                else
                {
                    println("Couldn't decode JSON data")
                    completion(success: false, bearerToken: nil)
                }
            }
        }
        task.resume()
    }
}