//
//  ViewController.swift
//  Character-iOS
//
//  Created by 李雷川 on 16/7/25.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: JSBridgeWebView!
    @IBOutlet weak var strokeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWebView()
    }
    
    func setupWebView(){
       
        
        let urlPath =  NSBundle.mainBundle().bundlePath + "/html5/index.html"
        debugPrint(urlPath)
        webView.loadRequest(NSURLRequest.init(URL: NSURL(fileURLWithPath:urlPath )))
        webView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:JSBridgeWebViewDelegate{
    func webView(webview: UIWebView!, didReceiveJSNotificationWithDictionary dictionary: [NSObject : AnyObject]!) {
        debugPrint(dictionary)
        if(dictionary["stepbegin"] != nil){
            strokeLabel.text = "开始播放第\(dictionary["stepbegin"]!)笔"
        }
        if(dictionary["stepend"] != nil){
         
             strokeLabel.text = "第\(dictionary["stepend"]!)笔播放结束"
        }
        if(dictionary["complete"] != nil){
           strokeLabel.text = "文字播放结束"
            
        }
    }
}

