//
//  StrokesViewController.swift
//  Character
//
//  Created by 李雷川 on 16/8/2.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
let collectionViewIdentifier = "collectionViewIdentifier"

class StrokeCollectionViewCell:UICollectionViewCell{
    
    let characterView = CharacterView()
    let nameLable = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(characterView)
        addSubview(nameLable)
        characterView.userInteractionEnabled = false
        
        characterView.backgroundColor = UIColor.clearColor()
        nameLable.textAlignment = .Center
        nameLable.text  = ""
        nameLable.font = UIFont.systemFontOfSize(10)
        characterView.snp_makeConstraints { (make) in
           make.leading.trailing.top.equalTo(0)
           make.height.equalTo(characterView.snp_width)

        }
        nameLable.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(characterView.snp_bottom)
            make.height.equalTo(24)
        }
        
    }
    
    func showCharacterStroke(character:Character,strokeIndex:Int){
         characterView.character = character
        let stroke = characterView.character.points[strokeIndex].stroke
        nameLable.text = stroke.name
        if(stroke.name.length == 0){
            characterView.fillStrokeColor = UIColor.blackColor()
        }
        else{
             characterView.fillStrokeColor = UIColor.redColor()
        }
        characterView.showWithStroke(strokeIndex)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StrokesViewController: UIViewController {
    var characterIndex:Int = 0{
        willSet{
            debugPrint(self.characterIndex)
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshTitle()
                self.refreshBtnstate()
                self.refreshCenterCharacterView()
            })
        }
        didSet{
            NSUserDefaults.standardUserDefaults().setValue(characterIndex, forKey: kStrokeIndexUserDefault)
        }

    }
    var characters = [String]()
    let centerCharacterView = CharacterView()
    let previousCharacterBtn = UIButton(type: .RoundedRect)
    let nextCharacterBtn = UIButton(type: .RoundedRect)
    var strokeViews = [StrokeView]()
    var characterViews = [Character]()
    var startFrame = CGRectZero
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var strokes = [Stroke]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.translucent = false
        initData()
        setupStrokeLibraryView()
        setupCenterCharacterView()
        setupButtons()
        setupSplitStrokesView()
   
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        layoutStrokeLibrayView()
    }
    
    //笔画库视图
    func setupStrokeLibraryView(){
        for (index,item) in strokes.enumerate(){
            let strokeView  = StrokeView(type: .Custom)
            view.addSubview(strokeView)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(StrokesViewController.handlePanGesture(_:)))
            strokeView.addGestureRecognizer(panGesture)
            strokeView.addTarget(self, action: #selector(StrokesViewController.handleTapGesture(_:)), forControlEvents: .TouchUpInside)
            strokeView.tag = index
            strokeView.setImage(UIImage(named:"\(item.id)"), forState: .Normal)
            strokeView.setTitle(item.name, forState: .Normal)
            strokeView.setTitleColor(UIColor.blueColor(), forState: .Normal)
            strokeView.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 12, 0)
            strokeView.titleLabel?.font = UIFont.systemFontOfSize(10)
            strokeView.titleLabel?.textAlignment = .Center
            strokeView.titleEdgeInsets = UIEdgeInsetsMake(52, -(strokeView.titleLabel?.bounds.size.width)!-60,0,0)
            strokeViews.append(strokeView)
        }
        layoutStrokeLibrayView()
    }
    
    //当前汉字视图
    func setupCenterCharacterView(){
        view.addSubview(centerCharacterView)
        centerCharacterView.isOnlyShowStroke = true
        centerCharacterView.backgroundMode = BackgroundMode.Tian
        centerCharacterView.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.width.equalTo(view.snp_width).multipliedBy(0.3)
        }
        centerCharacterView.characterComplete = {
          [unowned self]  in
            let key = self.characters[self.characterIndex].toUnicode()
            saveStrokesWithCharacter(self.centerCharacterView.character, key: key)
            self.centerCharacterView.fillCompleteStroke()
        }
    }
    
    //上一个汉字、下一个汉字按钮
    func setupButtons(){
        previousCharacterBtn.setTitle("上一个", forState: .Normal)
        previousCharacterBtn.addTarget(self, action: #selector(StrokesViewController.handlePrevious(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(previousCharacterBtn)
        previousCharacterBtn.snp_makeConstraints { (make) in
            make.centerY.equalTo(centerCharacterView)
            make.right.equalTo(centerCharacterView.snp_left).offset(-24)
        }
        
        nextCharacterBtn.setTitle("下一个", forState: .Normal)
        nextCharacterBtn.addTarget(self, action: #selector(StrokesViewController.handleNext(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(nextCharacterBtn)
        nextCharacterBtn.snp_makeConstraints { (make) in
            make.centerY.equalTo(centerCharacterView)
            make.left.equalTo(centerCharacterView.snp_right).offset(24)
        }
    }
    
    //当前汉字拆完笔画后的视图
    func setupSplitStrokesView(){
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(StrokeCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(centerCharacterView.snp_bottom).offset(8)
            make.bottom.equalTo(view).offset(-8)
        }
    }
    
    //布局StrokeLibraryView
    func layoutStrokeLibrayView(){
        let rowNum = 10
        var lastView:UIView!
        let width = CGRectGetWidth(view.frame)/CGFloat(rowNum+1)
        let space = width/CGFloat(rowNum+1)
        for (index,item) in strokeViews.enumerate(){
            if(index % rowNum == 0){
                item.snp_updateConstraints(closure: { (make) in
                    make.left.equalTo(view).offset(space)
                })
            }
            else{
                item.snp_updateConstraints(closure: { (make) in
                    make.left.equalTo(lastView.snp_right).offset(space)
                })
            }
            let top = (width + space) * CGFloat(index/rowNum) + space + 12
            item.snp_updateConstraints(closure: { (make) in
                make.width.height.equalTo(width)
                make.top.equalTo(top)
            })
            lastView = item
        }
    }
    
    //初始化汉字数据库
    func initData(){
        do{
            let jsonData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("characters", ofType: "json")!)
            try  characters = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as! [String]
            if(characters.count > 0){
//                characterIndex = 20
//                refreshCenterCharacterView()
//                refreshTitle()
                if let index = NSUserDefaults.standardUserDefaults().valueForKey(kStrokeIndexUserDefault) as? Int{
                    characterIndex = index
                }
//                previousCharacterBtn.enabled = false
//                nextCharacterBtn.enabled = true
            }
        }
        catch{
            
        }
        do{
            let strokesData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("strokes", ofType: "json")!)
            let strokeArr = try NSJSONSerialization.JSONObjectWithData(strokesData!, options: .AllowFragments) as! [AnyObject]
            for item in strokeArr{
                let stroke = Stroke()
                stroke.setValuesForKeysWithDictionary(item as! [String:AnyObject])
                strokes.append(stroke)
            }
            
        }
        catch{
            
        }
   
    }

    func handlePanGesture(gesture:UIPanGestureRecognizer){
        switch gesture.state {
        case .Began:
            startFrame = (gesture.view?.frame)!
        case .Cancelled,.Failed,.Ended:
            if (CGRectIntersectsRect(centerCharacterView.frame, (gesture.view?.frame)!) ==  true) {
                let stroke = strokes[(gesture.view?.tag)!]
                self.centerCharacterView.updateCurrenPointStroke(stroke)
                self.centerCharacterView.showNextStroke()
                collectionView.reloadData()
            }
            gesture.view?.frame = startFrame
            centerCharacterView.backgroundColor = UIColor.whiteColor()
        default:
            let location = gesture.locationInView(view)
            gesture.view?.center = location
            if (CGRectIntersectsRect(centerCharacterView.frame, (gesture.view?.frame)!) ==  true) {
                centerCharacterView.backgroundColor = UIColor.orangeColor()

            }
            else{
                centerCharacterView.backgroundColor = UIColor.whiteColor()
                
            }
           
        }
     
    }
    
    func handleTapGesture(sender:UIButton){
        let stroke = strokes[sender.tag]
        self.centerCharacterView.updateCurrenPointStroke(stroke)
        self.centerCharacterView.showNextStroke()
        collectionView.reloadData()
    }
    
    func handlePrevious(sender:UIButton){
         characterIndex = characterIndex - 1
    }
    
    func handleNext(sender:UIButton){
        characterIndex = characterIndex + 1
    }
    
    func refreshBtnstate(){
        if(characterIndex == 0){
            previousCharacterBtn.enabled = false
        }
        else{
             previousCharacterBtn.enabled = true
        }
    }
    
    func refreshTitle(){
        self.navigationItem.title = "\(characterIndex+1)/\(characters.count)"
    }
    
    //刷新汉字笔画显示
    func refreshCenterCharacterView(){
        let key = characters[characterIndex]
        requestCharacterJson(key) { [unowned self] (character) in
            debugPrint("request finish")
            self.centerCharacterView.character = character
            self.centerCharacterView.showWithStroke(0)
            self.collectionView.reloadData()
        }
        

    }
    
    func makeSelectStrokeView(selectView:StrokeView){
        let newView = StrokeView(frame: selectView.frame)
        view.addSubview(newView)
        newView.transform = CGAffineTransformScale(newView.transform, 2.1, 2.1)
        newView.backgroundColor = UIColor.blueColor()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(StrokesViewController.handlePanGesture(_:)))
        newView.addGestureRecognizer(panGesture)

    }
    
}

extension StrokesViewController:UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSize(width:64, height: 88)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  insetForSectionAtIndex indexPath: NSIndexPath) -> UIEdgeInsets{
        return UIEdgeInsetsMake(32, 32, 32, 32)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        debugPrint(indexPath.row)
        centerCharacterView.showWithStroke(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.whiteColor()
    }
}

extension StrokesViewController:UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return centerCharacterView.character.points.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewIdentifier, forIndexPath: indexPath) as! StrokeCollectionViewCell
        collectionViewCell.showCharacterStroke(centerCharacterView.character, strokeIndex: indexPath.row)
        return collectionViewCell
    }
}
