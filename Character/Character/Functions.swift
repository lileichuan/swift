//
//  Functions.swift
//  Character
//
//  Created by 李雷川 on 16/8/2.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

var kDocumentPath: String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as String
}

func strokesFolder()->String{
    let path = kDocumentPath + "/strokes"
    if(NSFileManager.defaultManager().fileExistsAtPath(path) == false){
        do{
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("\(path) 创建失败")
        }
    }
    return path
}

func saveStrokesWithCharacter(character:Character,key:String){
    var dic = [[String:AnyObject]]()
    for item in character.points{
        let stroke = item.stroke
        let strokeDic = ["id":stroke.id,"name":stroke.name]
        dic.append(strokeDic as! [String : AnyObject])
    }
    do{
        let jsonData = try NSJSONSerialization.dataWithJSONObject(dic, options: .PrettyPrinted)
        let json = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        
        let savePath = strokesFolder() + "/\(key).json"
        debugPrint(savePath)
        try json?.writeToFile(savePath, atomically: true, encoding: NSUTF8StringEncoding)
    }catch{
        
    }
 
    
    
}

func requestCharacterJson(key:String,success:(character:Character)->Void){
    let unicodeKey = key.toUnicode()
    let urlString = "http://101.201.113.247:88/website/index.php?keys=\(unicodeKey)"
    let url = NSURL(string:urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
      NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        if let data = data{
            let string = String.init(data: data, encoding: NSUTF8StringEncoding)
            let jsonString = (string! as NSString).substringWithRange(NSRange.init(location: 1, length: (string?.length)!-2))
            let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            var json:[AnyObject] = []
            do{
                json =  try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
                
            }
            catch{
                
            }
            var pointsJson = [String:AnyObject]()
            do{
                let pointJsonData = (json.first as! String).dataUsingEncoding(NSUTF8StringEncoding)
                pointsJson =  try NSJSONSerialization.JSONObjectWithData(pointJsonData!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                
            }
            catch{
                
            }
            dispatch_async(dispatch_get_main_queue(), {
                let character = Character()
                character.setValuesForKeysWithDictionary(pointsJson)
                success(character: character)
            })
            
            
        }
        }.resume()
}