//
//  BaseMusicKey.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import Hue

class BaseMusicKey: UIButton {
    /// 按钮Index
    let keyIndex: Int
    /// 音阶
    var midiNoteNumber: UInt8!
    /// 是否为主音键
    let isMainKey: Bool!
    /// 音乐键状态(是否被按下)
    var keyState: EnumStandard.KeyStates = .notPressed
    
    /// 标题Label
    var title: String = "" {
        didSet {
            if isMainKey != true {
                let titleLabel = UILabel.init(frame: CGRect.init(
                    x: 0,
                    y: 0,
                    width: self.getWidth(),
                    height: self.getHeight())
                 )
                titleLabel.text = title
                titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                titleLabel.textAlignment = .center
                titleLabel.backgroundColor = UIColor.clear
                
                self.addSubview(titleLabel)
            }
        }
    }
    
//    var gradientTimeInterval: CFTimeInterval = CFTimeInterval.init(0) {
//        didSet {
//            self.gradient.timeOffset = gradientTimeInterval
//        }
//    }

    
//    /// 渐变色处理
//    private lazy var gradient: CAGradientLayer = [
//        UIColor.white,
//        ].gradient { gradient in
//            gradient.speed = 0
//            gradient.timeOffset = 0
//
//            return gradient
//    }
//    /// 渐变色动画
//    private lazy var animation: CABasicAnimation = { [unowned self] in
//        let animation = CABasicAnimation(keyPath: "colors")
//        animation.duration = 1.0
//        animation.isRemovedOnCompletion = false
//
//        return animation
//    }()
    
    /// 初始化
    init(frame: CGRect, midiNoteNumber: UInt8, keyIndex: Int, isMainKey: Bool) {
        self.midiNoteNumber = midiNoteNumber
        self.isMainKey = isMainKey
        self.keyIndex = keyIndex
        
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.isMainKey = false
        self.midiNoteNumber = 60
        self.keyIndex = -1
        
        super.init(coder: aDecoder)
    }
}

// MARK: - Respond to key presses
extension BaseMusicKey {
    /// 设定键样式
    func setUp() -> Void {
        isUserInteractionEnabled = false
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.flatGreen.cgColor
        
        self.backgroundColor = .clear
        
//        self.animation.fromValue = gradient.colors
//        self.animation.toValue = UIColor.flatGreen.cgColor
//        self.gradient.add(self.animation, forKey: "changeColors")
//        self.layer.insertSublayer(self.gradient, at: 0)
        
        if self.isMainKey == true {
            let dogFrame = CGRect.init(x: 0, y: (self.getHeight() - self.getWidth()) / 2, width: self.getWidth(), height: self.getWidth())
            let dogImageView = UIImageView.init(frame: dogFrame)
            dogImageView.image = UIImage.init(named: EnumStandard.ImageName.mainMusicKey.rawValue)
            
            self.addSubview(dogImageView)
            
        }else {
            
        }
    }
    
    func pressed() -> Bool {
        if keyState != .pressed {
            keyState = .pressed
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
    
    func released() -> Bool {
        if keyState != .notPressed {
            keyState = .notPressed
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
    
}
