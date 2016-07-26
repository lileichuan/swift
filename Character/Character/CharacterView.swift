//
//  DrawView.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

enum PlayMode:Int {
    case Auto = 0
    case OneStoke = 1
}

class  CharacterView: UIView {
    var character:Character = Character(){
        didSet{
            debugPrint("didSet")
            self.setNeedsDisplay()
        }
    }
    var strokeIndex = 0   //当前播放的笔画
    var pointIndex = 0     //当前播放点
    var smallStepIndex = 1 //当前播放的点之间的小步
    var distance = 4   //每次移动距离
    var cxt:CGContext!
    var displayLink:CADisplayLink!
    var bOpenSmallStepMode = false
    var playMode = PlayMode.Auto
    var isPlaying = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        backgroundColor = UIColor.whiteColor()
//        fatalError("init(coder:) has not been implemented")
        displayLink = CADisplayLink(target: self, selector: #selector(CharacterView.play))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
    }
    
    override func drawRect(rect: CGRect) {
        guard character.strokes.count > 0  else{
            return
        }
        if((self.cxt) == nil){
             self.cxt = UIGraphicsGetCurrentContext()
        }
        CGContextScaleCTM(cxt, rect.size.width/CGFloat(character.size) ,  rect.size.height/CGFloat(character.size))
    
        fillBackgroundCharacter()
        CGContextSaveGState(cxt)
        if(isPlaying){
            fillStoke(strokeIndex)
            CGContextRestoreGState(cxt)
            if(strokeIndex == character.strokes.count){
                stop()
            }
            else{
                playCharacter()
            }
        }
    
 
       
    }
    
    func reset(){
        isPlaying = false
        displayLink.paused = true
        strokeIndex = 0
        pointIndex = 0
        setNeedsDisplay()
    }
    
    func play(){
        self.setNeedsDisplay()
    }
    
    func pause(){
        displayLink.paused = true
    }
    func stop(){
        displayLink.invalidate()
    }
    
    //填充汉字底色
    func fillBackgroundCharacter(){
        let cxt = UIGraphicsGetCurrentContext()
        CGContextSaveGState(cxt)
        for stroke in character.strokes{
            let rs = stroke.R
            for rPoint in rs{
                if(rPoint["t"]?.toInt() == 0){
                    CGContextMoveToPoint(cxt,rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
                else if(rPoint["t"]?.toInt() == 1){
                    CGContextAddLineToPoint(cxt, rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
                else{
                    CGContextAddCurveToPoint(cxt, rPoint["cx1"]!.toCGFloat(), rPoint["cy1"]!.toCGFloat(),rPoint["cx2"]!.toCGFloat(), rPoint["cy2"]!.toCGFloat(),rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
                
            }
        }
        CGContextSetFillColorWithColor(cxt, UIColor.lightGrayColor().CGColor)
        CGContextFillPath(cxt)
        CGContextRestoreGState(cxt)
    }
    
    //填充已经播放笔画
    func fillStoke(toIndex:Int){
        for index in 0..<toIndex{
            let stroke = character.strokes[index]
            for rPoint in stroke.R{
                if(rPoint["t"]?.toInt() == 0){
                    CGContextMoveToPoint(cxt,rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
                else if(rPoint["t"]?.toInt() == 1){
                    CGContextAddLineToPoint(cxt, rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
                else{
                    CGContextAddCurveToPoint(cxt, rPoint["cx1"]!.toCGFloat(), rPoint["cy1"]!.toCGFloat(),rPoint["cx2"]!.toCGFloat(), rPoint["cy2"]!.toCGFloat(),rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
                }
            }
        }
        CGContextSetFillColorWithColor(cxt, UIColor.blackColor().CGColor)
        CGContextFillPath(cxt)
    }
    
    
    func pointInfo(stroke:Stroke,index:Int) -> (maxStep:Int,xOffSet:Float,yOffSet:Float,point:CGPoint){
        let curPoint = stroke.T[index]
        let nextPoint = stroke.T[index+1]
        let xLength = (nextPoint["x"]?.toInt())! - (curPoint["x"]?.toInt())!
        let yLength =  (nextPoint["y"]?.toInt())! - (curPoint["y"]?.toInt())!
        let l = sqrt(pow(fabs(Float((xLength))), 2) + pow(fabs(Float(yLength)), 2))
 
        let stepCount = floor(l / Float(distance))
        let xOffSet = Float((xLength)) / stepCount
        let yOffSet = Float((yLength)) / stepCount
        let maxStep = Int(stepCount)
        return(maxStep,xOffSet,yOffSet,CGPoint(x: (curPoint["x"]?.toCGFloat())!,y: (curPoint["y"]?.toCGFloat())!))
    }
    
    //绘制当前动画的笔画
    func drawStroke(){
        let stroke = self.character.strokes[strokeIndex]
        for step in 0...pointIndex{
            let currenPointInfo = pointInfo(stroke, index:step)
            if(step == 0){
                CGContextMoveToPoint(cxt, currenPointInfo.point.x, currenPointInfo.point.y)
            }
            else{
                var toMaxStep = currenPointInfo.maxStep
                if(step == pointIndex){
                    toMaxStep = smallStepIndex
                }
                for step in 1...toMaxStep{
                    let x = currenPointInfo.point.x + CGFloat(step) * CGFloat(currenPointInfo.xOffSet)
                    let y = currenPointInfo.point.y + CGFloat(step) * CGFloat(currenPointInfo.yOffSet)
                    CGContextAddLineToPoint(cxt, x,y)
                }
            }
        }
        CGContextStrokePath(cxt)
        smallStepIndex = smallStepIndex + 1
        let currenPointInfo = pointInfo(stroke, index:pointIndex)
        if(smallStepIndex > currenPointInfo.maxStep){
            smallStepIndex = 1
            pointIndex = pointIndex + 1
        }
        
    }
    
    //裁剪当前要播放的笔画
    func clipStrokeFrame(){
        CGContextBeginPath(cxt)
        let stroke = character.strokes[strokeIndex]
        for rPoint in stroke.R{
            if(rPoint["t"]?.toInt() == 0){
                CGContextMoveToPoint(cxt,rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
            else if(rPoint["t"]?.toInt() == 1){
                CGContextAddLineToPoint(cxt, rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
            else{
                CGContextAddCurveToPoint(cxt, rPoint["cx1"]!.toCGFloat(), rPoint["cy1"]!.toCGFloat(),rPoint["cx2"]!.toCGFloat(), rPoint["cy2"]!.toCGFloat(),rPoint["x"]!.toCGFloat(), rPoint["y"]!.toCGFloat())
            }
        }
        CGContextClosePath(cxt)
        CGContextClip(cxt)
    }

    //当前笔画是否结束
    func isStrokeEnd() -> Bool{
        let curStroke = self.character.strokes[strokeIndex]
        let totalStep = curStroke.T.count
        if(pointIndex == totalStep - 1){
            return true
        }
        return false
    }
    
    
    //播放汉字笔画
    func playCharacter(){
        
        clipStrokeFrame()
        
        CGContextSetLineWidth(cxt, 55)
        CGContextSetLineCap(cxt, .Round)
        CGContextSetLineJoin(cxt,.Round)
        drawStroke()
        
        //当前笔画绘制完成
        if(isStrokeEnd()){
            strokeIndex = strokeIndex + 1
            pointIndex = 0
            //一笔一画播放
            if(playMode == PlayMode.OneStoke){
                pause()
            }
        }
 
    }

   
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(displayLink.paused){
            isPlaying = true
            displayLink.paused = false
        }
 
    }
    
}