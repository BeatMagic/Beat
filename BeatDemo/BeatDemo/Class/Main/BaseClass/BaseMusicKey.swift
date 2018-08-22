//
//  BaseMusicKey.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class BaseMusicKey: UIButton {
    /// 音阶
    let midiNoteNumber: UInt8!
    /// 是否为主音键
    let isMainKey: Bool!
    /// 音乐键状态(是否被按下)
    var keyState: EnumStandard.KeyStates = .notPressed
    
    /// 初始化
    init(frame: CGRect, midiNoteNumber: UInt8, isMainKey: Bool) {
        self.midiNoteNumber = midiNoteNumber
        self.isMainKey = isMainKey
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.isMainKey = false
        self.midiNoteNumber = 60
        super.init(coder: aDecoder)
    }
}

// MARK: - Respond to key presses
extension BaseMusicKey {
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
