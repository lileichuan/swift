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
    case None = 2
}
enum BackgroundMode:Int {
    case None = 0
    case Tian = 1
    case Mi = 2
    case Image = 3
}

class  CharacterView: UIView {
    var character:Character = Character(){
        didSet{
            self.reset()
        }
    }
    var pointIndex = 0     //当前播放的笔画
    var rPointIndex = 0     //当前播放的r节点
    var smallStepIndex = 1  //当前播放的点之间的小步
    var distance = 4        //每次移动距离
    var cxt:CGContext!
    var displayLink:CADisplayLink!
    var playMode = PlayMode.Auto
    var backgroundMode = BackgroundMode.None
    var isPlaying = false
    var isOnlyShowStroke = false
    var borderWidth:CGFloat = 2
    var fillStrokeColor = UIColor.redColor()  //笔画填充颜色
    var strokeBegin:((stroke:Int)->Void)? //笔画开始播放
    var strokeEnd:((stroke:Int)->Void)?   //笔画结束播放
    var characterComplete:(()->Void)?       //汉字播放结束
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configDefaultSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        configDefaultSetting()
    }
    deinit{
        displayLink.invalidate()
    }
    
    override func drawRect(rect: CGRect) {
        guard character.points.count > 0  else{
            return
        }
        if((self.cxt) == nil){
             self.cxt = UIGraphicsGetCurrentContext()
        }
        drawBackground()
        CGContextScaleCTM(cxt, rect.size.width/CGFloat(character.size) ,  rect.size.height/CGFloat(character.size))
        fillBackgroundCharacter()
        CGContextSaveGState(cxt)
        if(isOnlyShowStroke){
            fillWithStroke(pointIndex)
        }
        else{
            if(isPlaying){
                fillToStroke(pointIndex)
                CGContextRestoreGState(cxt)
                if(pointIndex == character.points.count){
                    if let doclouse = characterComplete{
                        doclouse()
                    }
                    pause()
                }
                else{
                    playCharacter()
                }
            }
        }
   
    }
    
    private func configDefaultSetting(){
        backgroundColor = UIColor.whiteColor()
        displayLink = CADisplayLink(target: self, selector: #selector(CharacterView.play))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
    }
    
    func reset(){
        isPlaying = false
        displayLink.paused = true
        pointIndex = 0
        rPointIndex = 0
        setNeedsDisplay()
    }
    
    func fillCompleteStroke(){
        pointIndex = character.points.count - 1
        isPlaying = true
        isOnlyShowStroke = false
        displayLink.paused = false
        setNeedsDisplay()
    }
    
    func play(){
        self.setNeedsDisplay()
    }
    
    func pause(){
        displayLink.paused = true
    }

    func showWithStroke(index:Int){
        isOnlyShowStroke = true
        pointIndex = index
        setNeedsDisplay()
    }
    func updateCurrenPointStroke(stroke:Stroke){
        self.character.points[pointIndex].stroke = stroke
    }
    func showNextStroke(){
        rPointIndex = 0
        pointIndex = pointIndex + 1
        guard pointIndex < character.points.count else{
            if let doClouse = characterComplete{
                doClouse()
            }
            pointIndex = 0
            return
        }
        setNeedsDisplay()
    }
    
    func showPreviousStroke(){
        rPointIndex = 0
        pointIndex = pointIndex - 1
        guard pointIndex > 0 else{
            pointIndex = 0
            return
        }
        setNeedsDisplay()
    }
    
    //填充笔画
    private func fillWithStroke(index:Int){
        let point = character.points[index]
        for rPoint in point.R{
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
        CGContextSetFillColorWithColor(cxt, fillStrokeColor.CGColor)
        CGContextFillPath(cxt)
    }

    private func drawTian(){
        let rect = bounds
        CGContextSetRGBStrokeColor(cxt, 1, 0, 0, 1.0)
        CGContextSetLineWidth(cxt, borderWidth)
        //绘制边框
        CGContextStrokeRect(cxt, bounds)
        //设置画笔为虚线
        CGContextSetLineDash(cxt, 0, [10,10], 1)
        
        //绘制+
        CGContextMoveToPoint(cxt,rect.size.width/2,0)
        CGContextAddLineToPoint(cxt,rect.size.width/2,rect.size.height)
        CGContextMoveToPoint(cxt,0,rect.size.height/2)
        CGContextAddLineToPoint(cxt,rect.size.width,rect.size.height/2)
        CGContextStrokePath(cxt)
    }
    
    private func drawMi(){
        drawTian()
        let rect = bounds
        //绘制交叉线
        CGContextMoveToPoint(cxt,0,0)
        CGContextAddLineToPoint(cxt,rect.size.width,rect.size.height)
        CGContextMoveToPoint(cxt,rect.size.width,0)
        CGContextAddLineToPoint(cxt,0,rect.size.height)
        CGContextStrokePath(cxt)
    }
    
    private func drawImage(){
        let rect = bounds
        let image =  UIImage.init(named: "background.jpg")?.CGImage
        CGContextDrawImage(cxt, rect,image)
    }
    
    private func drawBackground(){
        switch backgroundMode {
        case .None:
            break
        case .Tian:
            drawTian()
        case .Mi:
            drawMi()
        case .Image:
            drawImage()
        }
    }
    
    //填充汉字底色
    private func fillBackgroundCharacter(){
        let cxt = UIGraphicsGetCurrentContext()
        CGContextSaveGState(cxt)
        for point in character.points{
            let rs = point.R
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
    private func fillToStroke(toIndex:Int){
        for index in 0..<toIndex{
            fillWithStroke(index)
        }
     
    }
    
    func pointInfo(point:Point,index:Int) -> (maxStep:Int,xOffSet:Float,yOffSet:Float,tPoint:CGPoint){
        let curPoint = point.T[index]
        let nextPoint = point.T[index+1]
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
    private func drawStroke(){
        //开始播放当前笔画
        if(rPointIndex == 0){
            if let doclouse = strokeBegin{
                doclouse(stroke: pointIndex)
            }
        }
        let point = self.character.points[pointIndex]
        for step in 0...rPointIndex{
            let currenPointInfo = pointInfo(point, index:step)
            if(step == 0){
                CGContextMoveToPoint(cxt, currenPointInfo.tPoint.x, currenPointInfo.tPoint.y)
            }
            else{
                var toMaxStep = currenPointInfo.maxStep
                if(step == rPointIndex){
                    toMaxStep = smallStepIndex
                }
                for step in 1...toMaxStep{
                    let x = currenPointInfo.tPoint.x + CGFloat(step) * CGFloat(currenPointInfo.xOffSet)
                    let y = currenPointInfo.tPoint.y + CGFloat(step) * CGFloat(currenPointInfo.yOffSet)
                    CGContextAddLineToPoint(cxt, x,y)
                }
            }
        }
        CGContextStrokePath(cxt)
        smallStepIndex = smallStepIndex + 1
        let currenPointInfo = pointInfo(point, index:rPointIndex)
        if(smallStepIndex > currenPointInfo.maxStep){
            smallStepIndex = 1
            rPointIndex = rPointIndex + 1
        }
        
    }
    
    //裁剪当前要播放的笔画
    private func clipStrokeFrame(){
        CGContextBeginPath(cxt)
        let point = character.points[pointIndex]
        for rPoint in point.R{
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
    private func isStrokeEnd() -> Bool{
        let curStroke = self.character.points[pointIndex]
        let totalStep = curStroke.T.count
        if(rPointIndex == totalStep - 1){
            return true
        }
        return false
    }
    //播放汉字笔画
    private func playCharacter(){
        clipStrokeFrame()
        CGContextSetRGBStrokeColor(cxt, 0, 0, 0, 1.0)
        CGContextSetLineWidth(cxt, 70)
        CGContextSetLineCap(cxt, .Round)
        CGContextSetLineJoin(cxt,.Round)
        CGContextSetStrokeColorWithColor(cxt, fillStrokeColor.CGColor)
        drawStroke()
        //当前笔画绘制完成
        if(isStrokeEnd()){
            if let doclouse = strokeEnd{
                doclouse(stroke: pointIndex)
            }
            rPointIndex = 0
            pointIndex = pointIndex + 1
            //一笔一画播放
            if(playMode == PlayMode.OneStoke){
                pause()
            }
        }
 
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch playMode {
        case .OneStoke,.Auto:
            if(displayLink.paused == true){
                isPlaying = true
                displayLink.paused = false
            }
        default:
            break
        
        }
      
    }
    
}
