//
//  ViewController.swift
//  Character
//
//  Created by 李雷川 on 16/7/15.
//  Copyright © 2016年 李雷川. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var characterTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        for (index,stroke) in charater.strokes.enumerate() {
            let strokeView = StrokeView(frame: CGRectMake(20,CGFloat(96 * index),96,96))
            strokeView.stroke = stroke
            view.addSubview(strokeView)
        }
 */
    
    }
    @IBOutlet weak var characterView: CharacterView!

    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func segmentedChanged(sender: AnyObject) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
        characterView.playMode = PlayMode(rawValue: index)!
        characterView.reset()
        
    }

    @IBAction func doShowCharacterAction(sender: AnyObject) {
        let path = NSBundle.mainBundle().pathForResource("data", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)!
        var json:[String:AnyObject] = [:]
        do{
            json =  try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! [String : AnyObject]
            
        }
        catch{
            
        }
        let character = Character()
        character.setValuesForKeysWithDictionary(json)
        characterView.character = character
    }

}

extension MainViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField.text?.length > 1) {
            return false
        }
        return true
    }
}

