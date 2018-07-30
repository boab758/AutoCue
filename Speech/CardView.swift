//
//  CardView.swift
//  Speech
//
//  Created by Samuel on 7/7/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit

class CardView: UIView {

    private(set) var speechText: String = "" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private lazy var speechLabel = self.createLabel()
    private var isErrorCard = false
    
    func setString (str: String) {
        speechText = str
    }
    func getString() -> String{
        return speechText
    }
    
    private func createLabel() -> UILabel{
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureSpeechLabel(_ label: UILabel) {
        label.text = speechText
        if isErrorCard {
            label.textColor = UIColor.white
            label.textAlignment = .center
        }
        label.frame.size = bounds.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSpeechLabel(speechLabel)
        let boundsOriginPoint = bounds.origin
        speechLabel.frame.origin = CGPoint(x: boundsOriginPoint.x+2, y: boundsOriginPoint.y+1)
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath.init(roundedRect: bounds, cornerRadius: 16.0)
        if isErrorCard {
            UIColor.red.setFill()
        } else {
            UIColor.white.withAlphaComponent(0.65).setFill()
        }
//        self.backgroundColor = UIColor.black.withAlphaComponent(0)
//        self.isOpaque = false
        roundedRect.fill()
    }
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    convenience init (isError: Bool, frame: CGRect) {
        self.init(frame: frame)
        self.isErrorCard = isError
        setupView()
    }
    private func setupView() {
        setNeedsLayout()
    }
    
}
