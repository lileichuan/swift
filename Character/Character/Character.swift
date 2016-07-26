//
//  Character.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class  Character: NSObject {
    var unicode = ""
    var size = 512
    var strokes = [Stroke]()
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        debugPrint("forUndefinedKey \(key)")
        if(key == "points"){
            for item in value as! [[String:AnyObject]]{
                let stroke = Stroke()
                for r in item["R"] as! [[String:String]]{
                    stroke.R.append(r)
                }
                for t in item["T"] as! [[String:String]]{
                    stroke.T.append(t)
                }
                self.strokes.append(stroke)
                
            }
        
        }
    }
}

class Stroke: NSObject {
    var T = [[String:String]]()
    var R = [[String:String]]()
}
