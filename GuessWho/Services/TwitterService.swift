//
//  TwitterRequest.swift
//  GuessWho
//
//  Created by Siraj Hamza on 2019-04-02.
//  Copyright © 2019 devHamza. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON


class TwitterService {
    
    private let timelineEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    
    private var client: TWTRAPIClient!
    private(set) var tweetsArray: Array<String>!
    
    
    init() {
        
        self.client = TWTRAPIClient()
        self.tweetsArray = Array<String>()
    }
    
    
    public func getUserInfo(_ screenName: String, _ completion: @escaping (_ photoUrl: String) -> Void){

        
        let url = "https://api.twitter.com/1.1/users/show.json"
        let params = ["screen_name": screenName]
        var clientError : NSError?
        
        let request = self.client.urlRequest(withMethod: "GET", urlString: url, parameters: params as [AnyHashable : Any], error: &clientError)
        
        self.client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            
            if connectionError != nil {
                
                print("Error: \(connectionError!)")
            }
            
            if let result = data {
                
                do {
                    
                    let results = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as! NSDictionary
                    
                    completion(results["profile_image_url_https"]! as! String)
                }
                catch {
                    
                    
                }
            }
        }
    }
    
    
    private func clean(tweet: String) -> String {
        
        var text = tweet
        
        text = text.replacingOccurrences(
            of: "(https?://([-\\w\\.]+[-\\w])+(:\\d+)?(/([\\w/_\\.#-]*(\\?\\S+)?[^\\.\\s])?)?)",
            with: "",
            options: .regularExpression,
            range: text.startIndex ..< text.endIndex
        )
        
        text = text.replacingOccurrences(
            of: "@([A-Za-z]+[A-Za-z0-9_]+)(?![A-Za-z0-9_]*\\.)",
            with: "",
            options: .regularExpression,
            range: text.startIndex ..< text.endIndex
        )
        
        text = text.replacingOccurrences(
            of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}",
            with: "",
            options: .regularExpression,
            range: text.startIndex ..< text.endIndex
        )
        
        return text
    }
    
    
    public func fetchTweets(_ username: String, _ completion: @escaping (_ textResult: String) -> Void) {
        
        let requestGroup = DispatchGroup()
        
        for pageNum in 0 ... 5 {
            
            requestGroup.enter()
            
            let params = ["screen_name": username, "exclude_replies": "false", "count" : "200", "page" : "\(pageNum)"]
            
            var clientError : NSError?
            
            let request = self.client.urlRequest(withMethod: "GET", urlString: self.timelineEndpoint, parameters: params as [AnyHashable : Any], error: &clientError)
            
            self.client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                
                if connectionError != nil {
                    
                    print("Error: \(connectionError!)")
                }
                
                if let data = data {
                    
                    let tweets = JSON(data)
                    
                    if let items = tweets.array {
                        
                        for item in items {
                            
                            if let tweet = item["text"].string, let user = item["user"]["screen_name"].string {
                                
                                if user == username.replacingOccurrences(of: "@", with: "") {
                                    
                                    self.tweetsArray.append(self.clean(tweet: tweet))
                                }
                            }
                        }
                    }
                    
                    requestGroup.leave()
                }
            }
        }
        
        requestGroup.notify(queue: .main) {
            
            completion(self.tweetsArray.joined(separator: ". "))
        }
    }
}
