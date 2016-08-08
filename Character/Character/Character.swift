//
//  Character.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class Point: NSObject {
    var T = [[String:String]]()
    var R = [[String:String]]()
    var stroke = Stroke()
}
class Atrribute: NSObject {

}
class Stroke: NSObject {
    var id = 0
    var name = ""
}

class  Character: NSObject {
    var unicode = ""
    var size = 512
    var points = [Point]()
    
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if(key == "points"){
            for item in value as! [[String:AnyObject]]{
                let point = Point()
                for r in item["R"] as! [[String:String]]{
                    point.R.append(r)
                }
                for t in item["T"] as! [[String:String]]{
                    point.T.append(t)
                }
                self.points.append(point)
                
            }
            
        }
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        debugPrint("forUndefinedKey \(key)")
   
    }
}

