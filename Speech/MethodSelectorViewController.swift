//
//  MethodSelectorViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit

class MethodSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "combinedcolors")!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var dropbox: UIButton! {
        didSet {
            dropbox.setTitle("DropBox", for: UIControlState.normal)
            dropbox.setImage(resizeImage(image: UIImage(named:"Dropbox_Icon")!, newWidth: 100), for: UIControlState.normal)
            dropbox.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
            dropbox.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            dropbox.layer.cornerRadius = 10.0
        }
    }
    
    @IBOutlet weak var copypaste: UIButton! {
        didSet {
            copypaste.setTitle("CopyPaste", for: UIControlState.normal)
            copypaste.setImage(resizeImage(image: UIImage(named:"copyPaste")!, newWidth: 100), for: UIControlState.normal)
            copypaste.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
            copypaste.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            copypaste.layer.cornerRadius = 10.0
        }
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height: newHeight))
        image.draw(in: CGRect(x:0,y:0,width:newWidth,height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
