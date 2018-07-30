//
//  CueCardViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis
import SwiftyDropbox
import Foundation

let SAMPLE_RATE = 16000

class CueCardViewController: UIViewController, AudioControllerDelegate {
    
    var firstString = ""
    var secondString = ""
    var thirdString = ""
    var fourthString = ""
    var Card1 = CardView()
    var Card2 = CardView()
    var Card3 = CardView()
    var Card4 = CardView()
    var index = 0 {
        didSet {
            if !((modelController.match.sentences.count - 1) == self.index) { 
            modelController.match.min = self.index
//            animate()
            }
        }
    }
    var pathVar = ""
    var disappearing: Bool = true //CHANGE IF CARDS ARE DISAPPEARING THEN APPEARING
    static var numOfDownloads = 0
    var errorOccured = false
    var hasLogin = false
    
    var modelController = ModelController()
    var initialLoad = true
    var audioData: NSMutableData!
    var running = false
    
    var time: Timer?
    
    @IBOutlet var buttons: [UIButton]! {
        didSet {
        buttons.forEach({
            $0.layer.cornerRadius = 16.0
            
        })
        }
    }
    
    
    //MARK: record
    @IBAction func Stop(_ sender: UIButton) {
        if running {
            stopStream()
        }
    }
    private func stopStream(){
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        time?.invalidate()
    }
    @IBAction func restart(_ sender: UIButton) {
        index = 0
        animateBack()
        if running {
            stopStream()
        }
    }
    @IBAction func Start(_ sender: UIButton) {
        startStream()
        running = true
        time = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(timeController), userInfo: nil, repeats: true)
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
    @objc func timeController() {
        print("called timecontroller")
        stopStream()
        startStream()
    }
    
    func processSampleData(_ data: Data) {
        let matchVC = modelController.match
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.001 /* seconds/chunk */
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
                                if result.stability > 0.5 { // provided returned string is stable
//                                    print(result)
                                        if let result = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                            let presentedTextIndex = matchVC.compareStringWithSentences(googleString: result.transcript!)
    //                                        print ("DD")
                                        
                                            if self?.index != presentedTextIndex {
                                                self?.index = presentedTextIndex
                                                self?.animate()
                                            }
    //                                        self?.animate()
    //                                        print("FF")
                                        }
                                }
                            }
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
        cardInit()
        if modelController.color == "blue" {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "blue")!)
        } else if modelController.color == "orange" {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "orange")!)
        } else {
            view.backgroundColor = .white
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: cardInit
    func cardInit() {
        //ADD BELOW FOR TESTING
        //match.fakeInit(document: "")
        //ADD ABOVE FOR TESTING
        var match = self.modelController.match
        var string1 = match.sentences[0]
        var string2 = match.sentences[1]
        var string3 = match.sentences[2]
        Card1 = CardView(frame: CGRect(x:65, y:70, width: 290, height: 200)) //x:225/400/70y:200/340width:270height:130
        Card1.backgroundColor = UIColor(white: 1, alpha: 0)
        //Card1.backgroundColor = UIColor.white
        Card2 = CardView(frame: CGRect(x:65, y:295, width: 290, height: 200)) //x:225/400/70y:200/340
        Card2.backgroundColor = UIColor(white: 1, alpha: 0)
        Card3 = CardView(frame: CGRect(x:400, y:295, width: 290, height: 200)) //x:400/70y:200/340
        Card3.backgroundColor = UIColor(white: 1, alpha: 0)
        Card4 = CardView(frame: CGRect(x: -280, y: 70, width: 290, height: 200))
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
    
    //MARK: animation condition
    @objc func standInAnimate() { //normal + end      0 to +2
        if index+2 >= modelController.match.sentences.count {
            return
        } else {
            index += 1
//            print("forward: index is \(index)")
            animate()
        }
    }
    @objc func standInAnimateBack() { //start + normal + end     -1 to +1
        if index == 0 {
            return
        } else if index+1 == modelController.match.sentences.count {
            return
        } else {
            index -= 1
//            print("backward: index is \(index)")
            animateBack()
        }
        
        
        
//        if index-1 <= -1 {
//            index = 0
//            if isAni {
//                animateBack()
//            }
//        } else {
//            index -= 1
//            if index == 0 {
//                isAni = false
//            }
//            animateBack()
//        }
    }
    //MARK: animate backward
    func animateBack() {
        var match = self.modelController.match
        let frame = Card1.frame
        //if string1 == Card1.getString() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {self.Card2.transform = CGAffineTransform.identity.translatedBy(x: 330, y: 0)},
            //animations: {self.Card1.frame = CGRect(x:-self.Card1.frame.origin.x, y:0, width:self.Card1.frame.size.width, height:self.Card1.frame.size.height)},
            completion: {finished in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.4,
                    delay: 0,
                    options: UIViewAnimationOptions.curveEaseIn,
                    animations: {self.Card1.transform = CGAffineTransform.identity.translatedBy(x: 0, y: frame.size.height+25)},//+20
                    completion: {finished in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.5,
                            delay: 0,
                            options: UIViewAnimationOptions.curveEaseIn,
                            animations: {self.Card4.transform = CGAffineTransform.identity.translatedBy(x: frame.size.width+75, y: 0)},//+60
                            completion: {finished in
                                if self.index > 0 && self.index+2 < match.sentences.count{ //in between
                                    self.Card3.setString(str: match.sentences[self.index+2])
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    self.Card4.setString(str: match.sentences[self.index-1])
                                    self.Card4.transform = CGAffineTransform.identity
//                                    print ("Card4: \(match.sentences[self.index-1])")
//                                    print ("Card3: \(match.sentences[self.index+2])")
//                                    print ("Card2: \(match.sentences[self.index+1])")
//                                    print ("Card1: \(match.sentences[self.index])")
                                } else if self.index == 0 { //start
                                    self.Card3.setString(str: match.sentences[self.index+2])
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    self.Card4.setString(str: match.sentences[self.index])
                                    self.Card4.transform = CGAffineTransform.identity
//                                    print ("Card4: \(match.sentences[self.index])")
//                                    print ("Card3: \(match.sentences[self.index+2])")
//                                    print ("Card2: \(match.sentences[self.index+1])")
//                                    print ("Card1: \(match.sentences[self.index])")
                                } else {
                                    self.Card3.setString(str: match.sentences[self.index+1])
                                    self.Card2.setString(str: match.sentences[self.index])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    self.Card4.setString(str: match.sentences[self.index-1])
                                    self.Card4.transform = CGAffineTransform.identity
//                                    print ("Card4: \(match.sentences[self.index-1])")
//                                    print ("Card2: \(match.sentences[self.index])")
//                                    print ("Card1: \(match.sentences[self.index])")
                                }
                        })
                })
        })
    }
    //MARK: animate forward
    func animate() {
        var match = self.modelController.match
        let frame = Card1.frame
        //self.index+=1
        //ABOVE
        //if string1 == Card1.getString() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {self.Card1.transform = CGAffineTransform.identity.translatedBy(x: -frame.size.width-70, y: 0)},
            //animations: {self.Card1.frame = CGRect(x:-self.Card1.frame.origin.x, y:0, width:self.Card1.frame.size.width, height:self.Card1.frame.size.height)},
            completion: {finished in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.4,
                    delay: 0,
                    options: UIViewAnimationOptions.curveEaseIn,
                    animations: {self.Card2.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -frame.size.height-25)},
                    completion: {finished in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.5,
                            delay: 0,
                            options: UIViewAnimationOptions.curveEaseIn,
                            animations: {self.Card3.transform = CGAffineTransform.identity.translatedBy(x: -frame.size.width-45, y: 0)},//-75 -65 -85
                            completion: {finished in
                                if self.index+2 < match.sentences.count { //start and in between
                                    self.Card4.setString(str: self.Card1.getString())
                                    self.Card3.setString(str: match.sentences[self.index+2])
                                    self.Card3.transform = CGAffineTransform.identity
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
//                                    print ("Card3: \(match.sentences[self.index+2])")
//                                    print ("Card2: \(match.sentences[self.index+1])")
//                                    print ("Card1: \(match.sentences[self.index])")
                                } else { //end //MARK:condition
                                    self.Card4.setString(str: self.Card1.getString())
                                    self.Card3.setString(str: match.sentences[self.index+1])
                                    self.Card3.transform = CGAffineTransform.identity
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
//                                    print ("Card3: \(match.sentences[self.index+1])")
//                                    print ("Card2: \(match.sentences[self.index+1])")
//                                    print ("Card1: \(match.sentences[self.index])")
                                }
                        })
                })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
