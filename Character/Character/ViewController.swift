//
//  ViewController.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var characterFlagLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var strokesContainerView: UIScrollView!
    @IBOutlet weak var characterTextField: UITextField!
    var characterIndex = 0
    var characters = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        characterTextField.keyboardType = .NamePhonePad
        characterTextField.delegate = self
        characterTextField.returnKeyType = .Go
        initData()
   
    }
    
    func initData(){
        do{
            let jsonData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("characters", ofType: "json")!)
            try  characters = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as! [String]
        }
        catch{
            
        }
        if(characters.count > 0){
            characterIndex = 0
            showCharacter()
            previousButton.enabled = false
        }
      
    }
    
    func showCharacter(){
        characterTextField.resignFirstResponder()
        characterTextField.text = characters[characterIndex]
        requestCharacterJson(characterTextField.text!.toUnicode())
        characterFlagLabel.text = "\(characterIndex+1)/\(characters.count)"
    }
    
    @IBOutlet weak var characterView: CharacterView!

    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
      
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backgroundSegmentedChanged(sender: AnyObject) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
        characterView.backgroundMode = BackgroundMode(rawValue: index)!
        characterView.reset()
    }
    
    @IBAction func segmentedChanged(sender: AnyObject) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
        characterView.playMode = PlayMode(rawValue: index)!
        characterView.reset()
        
    }

    @IBAction func doShowCharacterAction(sender: AnyObject) {
        if(characterTextField.text?.length == 1){
            requestCharacterJson(characterTextField.text!.toUnicode())
        }
        characterTextField.resignFirstResponder()
    }
    
    @IBAction func previousCharacter(sender: AnyObject) {
        characterIndex = characterIndex - 1
        showCharacter()
        if(characterIndex == 0){
            previousButton.enabled = false
        }
        nextButton.enabled = true
        
    }
    @IBAction func nextCharacter(sender: AnyObject) {
        characterIndex = characterIndex + 1
        showCharacter()
        if(characterIndex == characters.count-1){
            nextButton.enabled = false
        }
       previousButton.enabled = true
    }
    @IBAction func doShowStrokesAction(){
//        strokesContainerView.hidden = strokesContainerView.hidden
      
        for index in 0..<characterView.character.points.count{
            let strokeView = CharacterView(frame: CGRectMake(64*CGFloat(index),10,64,64))
            strokeView.translatesAutoresizingMaskIntoConstraints = false
            strokesContainerView.addSubview(strokeView)
            strokeView.character = characterView.character
            strokeView.showWithStroke(index)
//            if(index == 0){
//                let leftConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Left, relatedBy: .Equal, toItem:strokesContainerView , attribute: .Left, multiplier: 1, constant: 8)
//                strokesContainerView.addConstraints([leftConstraint])
//            }
//            else{
//                let leftConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Left, relatedBy: .Equal, toItem:lastStrokeView , attribute: .Right, multiplier: 1, constant: 8)
//                strokesContainerView.addConstraints([leftConstraint])
//            }
//            if(index == characterView.character.strokes.count - 1){
//                let rightConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Right, relatedBy: .Equal, toItem:strokesContainerView , attribute: .Right, multiplier: 1, constant: 8)
//                strokesContainerView.addConstraints([rightConstraint])
//            }
//
//            let topConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Top, relatedBy: .Equal, toItem:strokesContainerView , attribute: .Top, multiplier: 1, constant: 8)
//            let bottomConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Bottom, relatedBy: .Equal, toItem:strokesContainerView , attribute: .Bottom, multiplier: 1, constant: 8)
//            let widthConstraint = NSLayoutConstraint.init(item: strokeView, attribute: .Width, relatedBy: .Equal, toItem:strokeView , attribute: .Height, multiplier: 1, constant: 0)
//            strokesContainerView.addConstraints([topConstraint,bottomConstraint,widthConstraint])
//
//            lastStrokeView = strokeView
        }
        characterTextField.resignFirstResponder()
    }
    
    
    func requestCharacterJson(key:String){
        let urlString = "http://101.201.113.247:88/website/index.php?keys=\(key)"
        let url = NSURL(string:urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        NSURLSession.sharedSession().dataTaskWithURL(url!) {[unowned self] (data, response, error) in
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
                    self.characterView.character = character
                    self.doShowStrokesAction()
                })
                

            }
            }.resume()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        characterTextField.resignFirstResponder()
    }
    
}

extension MainViewController:UITextFieldDelegate{

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.text?.length == 1) {
            characterIndex = characters.indexOf(textField.text!)!
            showCharacter()

            return true
        }
        return false
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        let inputMode = UITextInputMode.activeInputModes().first
//    
//        debugPrint(inputMode)
//        if (textField.text?.length > 1) {
//            return false
//        }
        return true
    }
}

