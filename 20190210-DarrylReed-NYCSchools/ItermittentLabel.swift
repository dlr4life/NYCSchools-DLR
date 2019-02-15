//
//  ItermittentLabel.swift
//  20190210-DarrylReed-NYCSchools
//
//  Created by DLR on 2/9/19.
//  Copyright © 2019 DLR. All rights reserved.
//

import UIKit

class ItermittentLabel: UILabel {
    
    fileprivate var titleForLabel1: String!
    fileprivate var titleForLabel2: String!
    fileprivate var titleForLabel3: String!
    fileprivate var titleForLabel4: String!
    fileprivate var duration: TimeInterval!
    fileprivate var currentLabel = 0
    fileprivate var timer: Timer!
    fileprivate var attributedTextFlag = false
    
    func startFlippingLabels(_ label1Text:String,label2Text:String,label3Text:String,label4Text:String,duration:TimeInterval){
        
        self.titleForLabel1 = label1Text
        self.titleForLabel2 = label2Text
        self.titleForLabel3 = label3Text
        self.titleForLabel4 = label4Text
        self.duration = duration
        
        setLabel1Text()
        attributedTextFlag = false
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.setTextForLabel(_:)), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func startFlippingLabels(_ label1AttributedText:NSMutableAttributedString,label2AttributedText:NSMutableAttributedString,label3AttributedText:NSMutableAttributedString,label4AttributedText:NSMutableAttributedString,duration:TimeInterval){
        self.duration = duration
        
        setLabel1Text()
        attributedTextFlag = true
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.setTextForLabel(_:)), userInfo: nil, repeats: true)
        timer.fire()
        
    }
    
    func stopFlippingLabels() {
        guard timer == nil else {
            timer.invalidate()
            timer = nil
            return
        }
    }
    
    @objc fileprivate func setTextForLabel(_ timer:Timer) {
        if currentLabel == 0 {
            // show label 1 text
            setLabel1Text()
            currentLabel += 1
        } else if currentLabel == 1 {
            // show label 2 text
            setLabel2Text()
            currentLabel += 1
        } else if currentLabel == 2 {
            // show label 3 text
            setLabel3Text()
            currentLabel += 1
        } else if currentLabel == 3 {
            // show label 4 text
            setLabel4Text()
            currentLabel += 1
        } else {
            // show label 1 text
            setLabel1Text()
            currentLabel -= 3
        }
    }
    
    fileprivate func setLabel4Text() {
        self.alpha = 0
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.alpha = 1
            if self.attributedTextFlag == false {
                self.text = self.titleForLabel4
            }
        }, completion: nil)
    }
    
    fileprivate func setLabel3Text() {
        self.alpha = 0
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.alpha = 1
            if self.attributedTextFlag == false {
                self.text = self.titleForLabel3
            }
        }, completion: nil)
    }
    
    fileprivate func setLabel2Text() {
        self.alpha = 0
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.alpha = 1
            if self.attributedTextFlag == false {
                self.text = self.titleForLabel2
            }
        }, completion: nil)
    }
    
    fileprivate func setLabel1Text() {
        self.alpha = 0
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.alpha = 1
            if self.attributedTextFlag == false {
                self.text = self.titleForLabel1
            }
        }, completion: nil)
    }
}
