//
//  CopyPasteViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import Foundation
import PopupDialog

class CopyPasteViewController: UIViewController {
    var modelController = ModelController()
    var errorCard = CardView(isError: true, frame: CGRect(x:55, y:610, width: 270, height: 70))
    var errorOcc = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "orange")!)
        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }

    @IBOutlet weak var copyPaste: UITextView! {
        didSet {
            copyPaste.layer.cornerRadius = 10.0
        }
    }
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 16.0
        }
    }
    
    @IBAction func saveSpeech(_ sender: UIButton) {
        var matchVC = self.modelController.match
        if errorOcc {
            errorCard.removeFromSuperview()
            errorOcc = false
        }
        if copyPaste.text == nil || copyPaste.text == "" {
            
            // Create the dialog
            let popup = PopupDialog(title: "OOPS!", message: "This field cannot be empty", image: UIImage(named: "error"))
            popup.addButton(CancelButton(title: "OK", height: 50, dismissOnTap: true, action: nil))
            self.present(popup, animated: true, completion: nil)
            errorOcc = true
        } else if copyPaste.text.wordCount() < Match.threshold {
            let popup = PopupDialog(title: "OOPS!", message: "Text has to be minimum 40 words long", image: UIImage(named: "error"))
            popup.addButton(CancelButton(title: "OK", height: 50, dismissOnTap: true, action: nil))
            self.present(popup, animated: true, completion: nil)
            errorOcc = true
        } else {
            matchVC.fakeInit(document: String(copyPaste.text)) //escape any injection attacks
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

