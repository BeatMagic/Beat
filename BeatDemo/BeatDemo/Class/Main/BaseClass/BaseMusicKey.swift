//
//  BaseMusicKey.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import HGRippleRadarView

class BaseMusicKey: UIButton {
    /// 按钮Index
    let keyIndex: Int
    /// 音阶
    var midiNoteNumber: UInt8!
    /// 是否为主音键
    let isMainKey: Bool!
    /// 记录的Frame
    let recordFrame: CGRect!
    
    /// 抖动开关
    var isNeedShake: Bool = false
    
    /// 音乐键状态(是否被按下)
    var keyState: EnumStandard.KeyStates = .notPressed {
        didSet {
            if keyState == .notPressed {
                self.layer.setAffineTransform(CGAffineTransform.identity)
                
            }else {
                self.shake()
            }
        }
    }
    /// 主音图片
    let dogImageView: UIImageView?
    
    /// 波浪动画View
    let rippleView = RippleView.init(
        frame: CGRect.init(x: 0,
                           y: 0,
                           width: FrameStandard.universalHeight / 4 / 2 * 3,
                           height: FrameStandard.universalHeight / 4 / 2 * 3))
    
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
                
                if DataStandard.MusicKeysImportentTitle.contains(title) == false {
                    titleLabel.textColor = UIColor.flatRed
                }
                
                self.addSubview(titleLabel)
            }
        }
    }
    
    /// 初始化
    init(frame: CGRect, midiNoteNumber: UInt8, keyIndex: Int, isMainKey: Bool) {
        self.midiNoteNumber = midiNoteNumber
        self.isMainKey = isMainKey
        self.keyIndex = keyIndex
        self.recordFrame = frame
        
        if self.isMainKey == true {
            let dogFrame = CGRect.init(x: 0, y: (frame.height - frame.width) / 2, width: frame.width, height: frame.width)
            self.dogImageView = UIImageView.init(frame: dogFrame)
            self.dogImageView!.image = UIImage.init(named: EnumStandard.ImageName.mainMusicKey.rawValue)
            self.dogImageView!.tintColor = UIColor.flatGreen
            
        }else {
            
            self.dogImageView = nil
        }
        
        super.init(frame: frame)
        self.rippleView.center = CGPoint.init(x: frame.width / 2,
                                              y: frame.height / 2)
        self.rippleView.diskRadius = 0.1
        self.rippleView.diskColor = UIColor.flatGreenDark
//            .withAlphaComponent(0.75)
        self.rippleView.numberOfCircles = 0
        self.rippleView.animationDuration = 3 / 8
        
        self.addSubview(self.rippleView)
        
        
        if self.isMainKey == true {
            self.addSubview(self.dogImageView!)
        }
        
//        self.animation = self.shakeOffAnimation()
//        self.layer.add(self.animation, forKey: "animation")
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.isMainKey = false
        self.midiNoteNumber = 60
        self.keyIndex = -1
        self.dogImageView = nil
        self.recordFrame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
        
        super.init(coder: aDecoder)
    }
}

// MARK: - Respond to key presses
extension BaseMusicKey {
    /// 设定键样式
    func setUp() -> Void {
        isUserInteractionEnabled = false
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = UIColor.flatGreen.cgColor
        
        self.backgroundColor = .clear
        
        
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
