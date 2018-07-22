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
import AVFoundation
import googleapis
import SwiftyDropbox
import Foundation //only needed for Time API

let SAMPLE_RATE = 16000

class ViewController : UIViewController, AudioControllerDelegate {
    //MARK: variables
    var audioData: NSMutableData!
    lazy var match = Match()
    var firstString = ""
    var secondString = ""
    var thirdString = ""
    var fourthString = ""
    var index = 0
    var Card1 = CardView()
    var Card2 = CardView()
    var Card3 = CardView()
    var Card4 = CardView()
    var errorCard = CardView()
    
    var pathVar = ""
    
    var disappearing: Bool = true //CHANGE IF CARDS ARE DISAPPEARING THEN APPEARING

    static var numOfDownloads = 0
    var errorOccured = false
    var hasLogin = false
    
    @IBOutlet weak var pathField: UITextField! {
        didSet {
            pathField.placeholder = "Enter path here"
            pathField.font = UIFont.systemFont(ofSize: 15)
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
        if ViewController.numOfDownloads > 0 {
            Card1.removeFromSuperview()
            Card2.removeFromSuperview()
            Card3.removeFromSuperview()
            Card4.removeFromSuperview()
            ViewController.numOfDownloads = 0
        }
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
                    self.match.fakeInit(document: try String(contentsOf: destURL2, usedEncoding: &encoding))
                    self.cardInit()
                    ViewController.numOfDownloads += 1
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
        AudioController.sharedInstance.delegate = self
    }
    
    //MARK: big start
    @IBAction func recordAudio(_ sender: UIButton) {
        cardInit()
        startStream()
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(timeController), userInfo: nil, repeats: true)
    }
    
    @objc func timeController() {
        print("called timecontroller")
        stopStream()
        startStream()
    }
    
    private func startStream() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    private func stopStream(){
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        stopStream()
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        print(error.localizedDescription)
                        print(error.localizedDescription)
                    } else if let response = response {
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    if let result = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                        let presentedText = self?.match.compareStringWithSentences(googleString: result.transcript!)
                                        self?.firstString = (presentedText?.current)!
                                        self?.secondString = (presentedText?.ahead)!
                                        self?.thirdString = (presentedText?.third)!
                                        self?.fourthString = (presentedText?.fourth)!
                                        print ("DD")
                                        self?.index = (presentedText?.idx)!
                                        self?.animate()
                                        print("FF")
                                    }
                                }
                            }
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
    

    
    

    

    //MARK: animate
    var isAni = true
    @objc func standInAnimate() {
        print("FORWARD")
        index += 1
        print(index)
        isAni = true
        print("isAni is \(isAni)")
        animate()
    }
    @objc func standInAnimateBack() {
        print("BACKWARD")
        if index-1 <= -1 {
            index = 0
            if isAni {
                animateBack()
            }
        } else {
            index -= 1
            print(isAni)
            if index == 0 {
                isAni = false
            }
            animateBack()
        }
        print(index)
    }
    
    func animateBack() {
        let frame = Card1.frame
        //if string1 == Card1.getString() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {self.Card4.transform = CGAffineTransform.identity.translatedBy(x: 345, y: 0)},
            //animations: {self.Card1.frame = CGRect(x:-self.Card1.frame.origin.x, y:0, width:self.Card1.frame.size.width, height:self.Card1.frame.size.height)},
            completion: {finished in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0,
                    options: UIViewAnimationOptions.curveEaseIn,
                    animations: {self.Card1.transform = CGAffineTransform.identity.translatedBy(x: 0, y: frame.size.height+20)},
                    completion: {finished in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.6,
                            delay: 0,
                            options: UIViewAnimationOptions.curveEaseIn,
                            animations: {self.Card2.transform = CGAffineTransform.identity.translatedBy(x: frame.size.width+60, y: 0)},
                            completion: {finished in
                                if self.index > 0 {
                                    self.Card2.setString(str: self.match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK")
                                    self.Card1.setString(str: self.match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD1 IS BACK")
                                    self.Card4.setString(str: self.match.sentences[self.index-1])
                                    self.Card4.transform = CGAffineTransform.identity
                                    print("CARD4 IS BACK")
                                } else {
                                    self.Card2.setString(str: self.match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK")
                                    self.Card1.setString(str: self.match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD4 IS BACK")
                                    self.Card4.setString(str: self.match.sentences[self.index])
                                    self.Card4.transform = CGAffineTransform.identity
                                }
                        })
                })
        })
    }
    
    func animate() {
        let frame = Card1.frame
        //self.index+=1
        //ABOVE
        //if string1 == Card1.getString() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {self.Card1.transform = CGAffineTransform.identity.translatedBy(x: -frame.size.width-70, y: 0)},
            //animations: {self.Card1.frame = CGRect(x:-self.Card1.frame.origin.x, y:0, width:self.Card1.frame.size.width, height:self.Card1.frame.size.height)},
            completion: {finished in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0,
                    options: UIViewAnimationOptions.curveEaseIn,
                    animations: {self.Card2.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -frame.size.height-20)},
                    completion: {finished in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.6,
                            delay: 0,
                            options: UIViewAnimationOptions.curveEaseIn,
                            animations: {self.Card3.transform = CGAffineTransform.identity.translatedBy(x: -frame.size.width-65, y: 0)},
                            completion: {finished in
                                if self.disappearing {
                                    self.Card4.setString(str: self.Card1.getString())
                                    self.Card3.setString(str: self.match.sentences[self.index+2])
                                    self.Card3.transform = CGAffineTransform.identity
                                    print("CARD3 IS BACK and: \(self.match.sentences[self.index+2])")
                                    self.Card2.setString(str: self.match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK and: \(self.match.sentences[self.index+1])")
                                    self.Card1.setString(str: self.match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD1 IS BACK and: \(self.match.sentences[self.index])")
                                } else if !(self.disappearing) {
                                    self.Card4.setString(str: self.Card1.getString())
                                    self.Card1.setString(str: self.match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    self.Card2.setString(str: self.match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card3.setString(str: self.match.sentences[self.index+2])
                                    self.Card3.transform = CGAffineTransform.identity
                                }
                        })
                })
        })
    }
    //}
    
    func cardInit() {
        //ADD BELOW FOR TESTING
        //match.fakeInit(document: "")
        //ADD ABOVE FOR TESTING
        var string1 = match.sentences[0]
        var string2 = match.sentences[1]
        var string3 = match.sentences[2]
        Card1 = CardView(frame: CGRect(x:65, y:70, width: 270, height: 130)) //x:400/70y:200/340
        Card1.backgroundColor = UIColor(white: 1, alpha: 0)
        Card2 = CardView(frame: CGRect(x:65, y:225, width: 270, height: 130)) //x:400/70y:200/340
        Card2.backgroundColor = UIColor(white: 1, alpha: 0)
        Card3 = CardView(frame: CGRect(x:400, y:225, width: 270, height: 130)) //x:400/70y:200/340
        Card3.backgroundColor = UIColor(white: 1, alpha: 0)
        Card4 = CardView(frame: CGRect(x: -280, y: 70, width: 270, height: 130))
        Card4.backgroundColor = UIColor(white: 1, alpha: 0)
        addGestures(Card1: Card1, Card2: Card2)
        self.view.addSubview(Card1)
        self.view.addSubview(Card2)
        self.view.addSubview(Card3)
        self.view.addSubview(Card4)
        Card3.setString(str: string3)
        Card2.setString(str: string2)
        Card1.setString(str: string1)
    }
    func addGestures(Card1: CardView, Card2: CardView) {
        let swipe1 = UISwipeGestureRecognizer(target: self, action: #selector(standInAnimate))
        swipe1.direction = .left
        let swipe2 = UISwipeGestureRecognizer(target: self, action: #selector(standInAnimate))
        swipe2.direction = .up
        let swipe3 = UISwipeGestureRecognizer(target: self, action: #selector(standInAnimateBack))
        swipe3.direction = .down
        let swipe4 = UISwipeGestureRecognizer(target: self, action: #selector(standInAnimateBack))
        swipe4.direction = .right
        Card1.addGestureRecognizer(swipe1)
        Card1.addGestureRecognizer(swipe3)
        Card2.addGestureRecognizer(swipe2)
        Card2.addGestureRecognizer(swipe4)
    }
    //MARK: small start
    @IBAction func start(_ sender: UIButton) {
        //ADD BELOW FOR TESTING
        //match.fakeInit(document: "")
        //ADD ABOVE FOR TESTING
        var string1 = match.sentences[0]
        var string2 = match.sentences[1]
        var string3 = match.sentences[2]
        Card1 = CardView(frame: CGRect(x:65, y:70, width: 270, height: 130)) //x:400/70y:200/340
        Card1.backgroundColor = UIColor(white: 1, alpha: 0)
        Card2 = CardView(frame: CGRect(x:65, y:225, width: 270, height: 130)) //x:400/70y:200/340
        Card2.backgroundColor = UIColor(white: 1, alpha: 0)
        Card3 = CardView(frame: CGRect(x:400, y:225, width: 270, height: 130)) //x:400/70y:200/340
        Card3.backgroundColor = UIColor(white: 1, alpha: 0)
        Card4 = CardView(frame: CGRect(x: -280, y: 70, width: 270, height: 130))
        Card4.backgroundColor = UIColor(white: 1, alpha: 0)
        addGestures(Card1: Card1, Card2: Card2)
        self.view.addSubview(Card1)
        self.view.addSubview(Card2)
        self.view.addSubview(Card3)
        self.view.addSubview(Card4)
        print(string1)
        Card3.setString(str: string3)
        Card2.setString(str: string2)
        Card1.setString(str: string1)
    }
    @IBAction func test1(_ sender: UIButton) {
        index = 0
        animate()
    }
    @IBAction func test2(_ sender: UIButton) {
        index = 1
        animate()
    }
}
