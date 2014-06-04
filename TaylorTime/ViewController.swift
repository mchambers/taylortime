//
//  ViewController.swift
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

