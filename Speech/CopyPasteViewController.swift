//
//  CopyPasteViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit

class CopyPasteViewController: UIViewController {

    var modelController = ModelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var copyPaste: UITextView! 
    
    
    
    @IBAction func saveSpeech(_ sender: UIButton) {
        var matchVC = self.modelController.match
        matchVC.fakeInit(document: copyPaste.text)
        modelController.color = "orange"
        
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

