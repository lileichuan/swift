//
//  ViewController.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = NSBundle.mainBundle().pathForResource("data", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)!
        var json:[String:AnyObject] = [:]
        do{
             json =  try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! [String : AnyObject]
           
        }
        catch{
            
        }
        let charater = Charater()
        charater.setValuesForKeysWithDictionary(json)

        let charaterView = CharaterView(frame: CGRectMake(100,100,512,512))
        charaterView.character = charater
        charaterView.center = view.center
        view.addSubview(charaterView)
        /*
        for (index,stroke) in charater.strokes.enumerate() {
            let strokeView = StrokeView(frame: CGRectMake(20,CGFloat(96 * index),96,96))
            strokeView.stroke = stroke
            view.addSubview(strokeView)
        }
 */
    
    }

    
    override func viewDidAppear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

