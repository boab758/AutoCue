//
//  CueCardViewController.swift
//  Speech
//
//  Created by Samuel on 25/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit

class CueCardViewController: UIViewController {
    
    var firstString = ""
    var secondString = ""
    var thirdString = ""
    var fourthString = ""
    var Card1 = CardView()
    var Card2 = CardView()
    var Card3 = CardView()
    var Card4 = CardView()
    var index = 0
    var pathVar = ""
    var disappearing: Bool = true //CHANGE IF CARDS ARE DISAPPEARING THEN APPEARING
    static var numOfDownloads = 0
    var errorOccured = false
    var hasLogin = false
    
    var modelController = ModelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardInit()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cardInit() {
        //ADD BELOW FOR TESTING
        //match.fakeInit(document: "")
        //ADD ABOVE FOR TESTING
        var match = self.modelController.match
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
        var match = self.modelController.match
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
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK")
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD1 IS BACK")
                                    self.Card4.setString(str: match.sentences[self.index-1])
                                    self.Card4.transform = CGAffineTransform.identity
                                    print("CARD4 IS BACK")
                                } else {
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK")
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD4 IS BACK")
                                    self.Card4.setString(str: match.sentences[self.index])
                                    self.Card4.transform = CGAffineTransform.identity
                                }
                        })
                })
        })
    }
    
    func animate() {
        var match = self.modelController.match
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
                                    self.Card3.setString(str: match.sentences[self.index+2])
                                    self.Card3.transform = CGAffineTransform.identity
                                    print("CARD3 IS BACK and: \(match.sentences[self.index+2])")
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    print("CARD2 IS BACK and: \(match.sentences[self.index+1])")
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    print("CARD1 IS BACK and: \(match.sentences[self.index])")
                                } else if !(self.disappearing) {
                                    self.Card4.setString(str: self.Card1.getString())
                                    self.Card1.setString(str: match.sentences[self.index])
                                    self.Card1.transform = CGAffineTransform.identity
                                    self.Card2.setString(str: match.sentences[self.index+1])
                                    self.Card2.transform = CGAffineTransform.identity
                                    self.Card3.setString(str: match.sentences[self.index+2])
                                    self.Card3.transform = CGAffineTransform.identity
                                }
                        })
                })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
