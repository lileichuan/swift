//
//  StrokeView.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class StrokeView: UIView {

    var stroke:Stroke!
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func drawRect(rect: CGRect) {
        debugPrint("drawStroke")
        let cxt = UIGraphicsGetCurrentContext()
        drawStroke(cxt!)
    }

    
    
    func drawStroke(cxt:CGContext){
        CGContextSetRGBStrokeColor(cxt, 1, 0, 0, 1)
        CGContextSetLineCap(cxt, .Round)
                CGContextScaleCTM(cxt, 0.2, 0.2)
        CGContextSetLineWidth(cxt, 2)
   
        let rs = stroke.R
        for rPoint in rs{
            if(rPoint["t"]?.toInt() == 0){
                CGContextMoveToPoint(cxt,rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
            else if(rPoint["t"]?.toInt() == 1){
                CGContextAddLineToPoint(cxt, rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
            else{
                debugPrint(rPoint["cx1"]!.toCGFloat())
                CGContextAddCurveToPoint(cxt, rPoint["cx1"]!.toCGFloat(), rPoint["cy1"]!.toCGFloat(),rPoint["cx2"]!.toCGFloat(), rPoint["cy2"]!.toCGFloat(),rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
        }
            
            
        CGContextSetFillColorWithColor(cxt, UIColor.blueColor().CGColor)
        CGContextFillPath(cxt)
        CGContextStrokePath(cxt)
        
        
    }
}
