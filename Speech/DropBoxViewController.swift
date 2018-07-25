	//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit
import SwiftyDropbox
import Foundation //only needed for Time API

class DropBoxViewController : UIViewController {
    //MARK: variables
    var audioData: NSMutableData!
    var modelController = ModelController()
    var errorCard = CardView()
    
    var pathVar = ""

    static var numOfDownloads = 0
    var errorOccured = false
    var hasLogin = false
    var shouldSegue = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCueCard" {
            if let cueCardViewController = segue.destination as? CueCardViewController {
                //print(modelController.match.sentences[0])
                cueCardViewController.modelController = modelController
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        print("CHECKING SEGUE")
        print("shouldSegue: \(shouldSegue) and errorOccured:\(errorOccured)")
        return false
    }
    
    @IBOutlet weak var pathField: UITextField! {
        didSet {
            pathField.placeholder = "Enter path here"
            pathField.font = UIFont.systemFont(ofSize: 18)
            pathField.borderStyle = UITextBorderStyle.roundedRect
            pathField.autocorrectionType = UITextAutocorrectionType.no
            pathField.keyboardType = UIKeyboardType.default
            pathField.returnKeyType = UIReturnKeyType.done
            pathField.clearButtonMode = UITextFieldViewMode.whileEditing;
        }
    }
    @IBAction func editChange(_ sender: Any) {
        pathVar = pathField.text!
    }
    
    @IBAction func login(_ sender: UIButton) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)})
        hasLogin = true
    }
    
    //MARK: download
    @IBAction func download(_ sender: UIButton) {
        print(pathVar)
        var matchVC = self.modelController.match
        if errorOccured {
            errorCard.removeFromSuperview()
            errorOccured = false
            print("1")
        }
        if !hasLogin {
            errorCardInit(errorParam: "Have you logged in successfully? Try again after logging in.")
            errorOccured = true
            print("2")
            return
        }
        if pathVar.prefix(1) != "/" {
            print(pathVar.prefix(0))
            errorCardInit(errorParam: "Please preface path with \"/\"")
            errorOccured = true
            print("3")
            return
        }
        if pathVar.suffix(4) != ".txt" {
            errorCardInit(errorParam: "We only accept txt files at the moment.")
            errorOccured = true
            print("4")
            return
        }
        print("5")
        let client = DropboxClientsManager.authorizedClient
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL2 = directoryURL.appendingPathComponent("tempDir")//myTestFile will be the file name
        let destination2: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL2
        }
        client!.files.download(path: pathVar, overwrite: true, destination: destination2).response {response, error in
            if let response = response {
                print ("response is: \(response)")
                do {
                    var encoding: String.Encoding = .ascii
                    matchVC.fakeInit(document: try String(contentsOf: destURL2, usedEncoding: &encoding))
                    DropBoxViewController.numOfDownloads += 1
                    print("DOWNLOAD FINISH")
                    self.shouldSegue = true
                    self.modelController.color = "blue"
                    self.performSegue(withIdentifier: "showCueCard", sender: Any?)
                } catch {
                    self.errorOccured = true
                    self.errorCardInit(errorParam: error as! String)
                    print ("the error in response is \(error)")
                }
            } else if let error = error {
                self.errorOccured = true
                self.errorCardInit(errorParam: (error as! Error) as! String)
                print (error)
            }
            }
            .progress {progressData in print(progressData)
        }
    }
    
    func errorCardInit(errorParam: String) {
        self.errorCard = CardView(frame: CGRect(x:65, y:70, width: 270, height: 130)) //x:400/70y:200/340
        self.errorCard.backgroundColor = UIColor.red
        self.errorCard.setString(str: errorParam)
        self.view.addSubview(self.errorCard)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    

    //MARK: small start
    @IBAction func start(_ sender: UIButton) {
        //ADD BELOW FOR TESTING
        //match.fakeInit(document: "")
        //ADD ABOVE FOR TESTING
    }
    @IBAction func test1(_ sender: UIButton) {

    }
    @IBAction func test2(_ sender: UIButton) {

    }
}
