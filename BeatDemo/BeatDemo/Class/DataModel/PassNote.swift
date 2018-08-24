//
//  PassNote.swift
//  BeatDemo
//
//  Created by apple on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

/// 一个note事件里面滑动经过的音
class PassNote: NSObject {
    /// 音阶
    let midiNoteNumber : UInt8!
    /// 进入时间
    let enterTime: Double!
    /// 退出时间
    let exitTime: Double!
    
    /// 进入拍子
    let enterBeat: UInt8!
    /// 退出拍子
    let exitBeat: UInt8!
    
    init(midiNoteNumber: UInt8,
         enterTime: double_t,
         exitTime: double_t) {
        self.midiNoteNumber = midiNoteNumber
        self.enterTime = enterTime
        self.exitTime = exitTime
        
        self.enterBeat = DataStandard.getBeat(enterTime)
        self.exitBeat = DataStandard.getBeat(exitTime)
        
        super.init()
    }
}
