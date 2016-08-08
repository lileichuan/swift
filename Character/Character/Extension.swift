//
//  Extension.swift
//  Moodle
//
//  Created by zhuxuhong on 15/11/6.
//  Copyright © 2015年 李雷川. All rights reserved.
//

import UIKit





extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Int{
    //将数字字符转换为字符串
    func toFileSizeString()->String{
        let units = ["bytes","KB","MB","GB","TB"]
        var index = 0
        var result = Double(self)
        let unitSize = Double(1000)
        while (result>unitSize) {
            result /= unitSize
            index = index+1
            if(index >= units.count){
                break
            }
        }
        return "\( result.format(".2"))\(units[index])"
    }
	static func toFormatedTimeStringMaxHour(seconds: Int) -> String{
		let h = seconds / 3600
		let m = seconds % 3600 / 60
		let s = seconds % 60
		
		return NSString(format: "%02d:%02d:%02d", h,m,s) as String
	}
	static func toFormatedTimeStringMaxMinute(seconds: Int) -> String{
		let m = seconds % 3600 / 60
		let s = seconds % 60
		
		return NSString(format: "%02d:%02d", m,s) as String
	}
}

// 字符串
extension String{
	// 转基本类型
	func toInt() -> Int{
		return NSString(string: self).integerValue
	}
	
	func toFloat() -> Float{
		return NSString(string: self).floatValue
	}
	
	func toDouble() -> Double{
		return NSString(string: self).doubleValue
	}
    func toCGFloat() -> CGFloat{
        return CGFloat(NSString(string: self).integerValue)
    }
	func toDateWithFormat(format: String) -> NSDate{
		let df = NSDateFormatter()
		df.dateFormat = format
		return df.dateFromString(self)!
	}
    
    var length: Int{
        return  self.characters.count
    }
    func isUrl() -> Bool {
        guard self.hasPrefix("http://") == false else{
            return true
        }
        return false
    }
    func stringToInt() ->String{
        return String(lroundf(self.toFloat()))
    }
    func toUnicode()->String{
        let length = self.length
        let s = NSMutableString(capacity: 0)
        let string = self as NSString
        for i in 0..<length {
           let  _char = string.characterAtIndex(i)
            //判断是否为英文和数字
            if (_char <= 9 && _char >= 0) {
                s.appendFormat("%@",string.substringWithRange(NSRange(location: i,length: 1)))
            }else if(_char >= 97 && _char <= 122)
            {
                 s.appendFormat("%@",string.substringWithRange(NSRange(location: i,length: 1)))
            }else if(_char >= 65 && _char <= 90)
            {
                 s.appendFormat("%@",string.substringWithRange(NSRange(location: i,length: 1)))
            }else
            {
                 s.appendFormat("%x",_char)
            }
            
        }
        return s as String;
    }
    
	func toUTF8String() -> UnsafePointer<Int8> {
		return (self as NSString).UTF8String
	}
    
    
	static func utf8StringFromData(data: NSData) -> String {
		return String(NSString(data: data, encoding: NSUTF8StringEncoding))
	}
    
}

// NSTimeInterval
extension NSTimeInterval{
	// 转格式化日期字符串
	func toStringWithDateFormat(format: String) -> String{
		let date = NSDate(timeIntervalSince1970: self)
		let df = NSDateFormatter()
		df.dateFormat = format
		return df.stringFromDate(date)
	}
}

// NSDate
extension NSDate{
	func toStringWithFormat(format: String) -> String{
		let df = NSDateFormatter()
		df.dateFormat = format
		return df.stringFromDate(self)
	}
	
	func formatDate() -> String{
		let calendar = NSCalendar.currentCalendar()
		let df = NSDateFormatter()
		df.locale = NSLocale(localeIdentifier: "zh_CN")
		let isInYesterday = calendar.isDateInYesterday(self)
		let isInToday = calendar.isDateInToday(self)
		if isInToday{
			df.dateFormat = "HH:mm"
		}else if isInYesterday{
			df.dateFormat = "昨天 HH:mm"
		}else{
			df.dateFormat = "yyyy年MM月dd日 HH:mm"
		}
		return df.stringFromDate(self)
	}
    
}
extension String{
  static func timeStamp(time:Double) ->String{
        let timeInterval = time
        let detaildate = NSDate(timeIntervalSince1970: timeInterval)
        return detaildate.formatDate()
    }
    static func time(time:Double) ->String{
        let timeInterval = time
        let detaildate = NSDate(timeIntervalSince1970: timeInterval)
        return detaildate.toStringWithFormat("yy-MM-dd HH:mm")
    }
    

}
extension UIViewController{
	func setNavBackButtonTitle(title: String){
		// 直接子类返回按钮文字
		self.navigationItem.setValue(title, forKeyPath: "_backButtonTitle")
		
	}
}

// 打印信息
private let PRINT_LOG = true
class PrintUtil: NSObject{
	
	static func Log(info: String, args: [AnyObject]?){
//		let arg = (args == nil) ? [] : args!
		if PRINT_LOG {
			if args != nil {
				print(info,"-----",args!)
			}else{
				print(info,"*****")
			}
		}
	}
}

// 导航栏
extension UINavigationBar{
	func setTitleColor(color: UIColor?){
		if color != nil {
//			self.titleTextAttributes = [NSForegroundColorAttributeName: color!]
		}
	}
}

extension UINavigationController{
	func setNavBarStyle(translucent: Bool, titleColor: UIColor?, tintColor: UIColor?, barTintColor: UIColor?, backgroundColor: UIColor?, bacIndicatorImage: UIImage?) {
		
		navigationBar.setTitleColor(titleColor)
		navigationBar.translucent = translucent
		navigationBar.tintColor = tintColor
		navigationBar.barTintColor = barTintColor
		navigationBar.backIndicatorImage = bacIndicatorImage
		navigationBar.backIndicatorTransitionMaskImage = bacIndicatorImage
	}
}

// 滑块
extension UISlider{
	static func createSlider(minValue: Float,
	                  maxValue: Float,
	                  thumbImage: UIImage?,
	                  minTrackImage: UIImage?,
	                  maxTrackImage: UIImage?) -> UISlider {
		let slider = UISlider()
		
		slider.minimumValue = minValue
		slider.maximumValue = maxValue
		slider.setThumbImage(thumbImage, forState: .Normal)
		slider.setMinimumTrackImage(minTrackImage, forState: .Normal)
		slider.setMaximumTrackImage(maxTrackImage, forState: .Normal)
		return slider
	}
}
extension NSObject{
    func isEmpty(view:UIView?) -> Bool {
        if (view == nil) {
            return true
        }
        return false
    }
}

extension String {
    func urlEncode() -> String? {
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString
    }
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.urlEncode() {
                if let encodedValue = value.urlEncode() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
}

extension NSString{
    func isIp() ->Bool {
        
        let urlRegEx = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
        
        let portEx = "^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9]):[1-9][0-9]*$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let portTest = NSPredicate(format: "SELF MATCHES %@", portEx)
        return urlTest.evaluateWithObject(self) || portTest.evaluateWithObject(self)
    }
}