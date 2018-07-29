//
//  CopyPasteViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import Foundation

class CopyPasteViewController: UIViewController {

    var modelController = ModelController()
    var errorCard = CardView(isError: true, frame: CGRect(x:55, y:610, width: 270, height: 70))
    var errorOcc = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }

    @IBOutlet weak var copyPaste: UITextView!
    
    
    @IBAction func saveSpeech(_ sender: UIButton) {
        var matchVC = self.modelController.match
        if errorOcc {
            errorCard.removeFromSuperview()
            errorOcc = false
        }
        if copyPaste.text == nil || copyPaste.text == "" {
            //errorCard = CardView(frame: CGRect(x:45, y:650, width: 270, height: 70)) //x:400/70y:200/340
            //errorCard.backgroundColor = UIColor.red
            errorCard.backgroundColor = UIColor(white: 1, alpha: 0) //sets the square background of the view to be white but the alpha is 0 so it is transparent. So the result is just the rounded rect. 
            errorCard.setString(str: "Where is your speech?")
            self.view.addSubview(errorCard)
            errorOcc = true
        } else {
            matchVC.fakeInit(document: copyPaste.text)
            modelController.color = "orange"
            self.performSegue(withIdentifier: "showCueCard", sender: Any?)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCueCard" {
            if let cueCardViewController = segue.destination as? CueCardViewController {
                cueCardViewController.modelController = modelController
            }
        }
    }
}

