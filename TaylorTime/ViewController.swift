//
//  ViewController.swift
//  TaylorTime
//
//  Created by Marc Chambers on 6/3/14.
//  Copyright (c) 2014 Approach Labs. All rights reserved.
//

import UIKit

/*
    Load up Taylor Swift's twitter feed.
    Pick a tweet at random.
    Display it.
    [BOOM]!
*/

class ViewController: UIViewController {
    
    @IBOutlet var quoteLabel : UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Seed the random number generator.
        // We'd prefer to use arc4random_uniform, but having trouble with that in Swift.
        srandom(CUnsignedInt(time(nil)))
    }
    
    @IBAction func newQuoteButton(sender : UIButton) {
        quoteLabel.text="Fetching more Taylor feels from Twitter..."
        
        let client=TwitterClient()
        
        client.apiKey="LgR07ZJtDtm7obY2DGR6riCjK"
        client.apiSecret="OJHQNI5sRtQZi0s1AYIyIiIGtG070uKXcFUMyQx5KjbSQAGS54"
        
        client.getBearerToken {
            (success: Bool, bearerToken: String?) -> () in
            
            client.getLatestTweetsForUser("taylorswift13") {
                (tweets: Array<TwitterClient.Tweet>?) -> () in
                
                if tweets {
                    let randomTweetIndex = random() % tweets!.count
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quoteLabel.text=tweets![randomTweetIndex].text
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

