//
//  TmpNote.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class TmpNote: NSObject {
    /// 按下时间
    let pressedTime: Double!
    
    /// 抬起时间
    var unPressedTime: Double! = 0
    
    /// 音调(主键)
    var midiNoteNumber: UInt8!
    
    init(_ midiNoteNumber: UInt8, pressedTime: Double) {
        self.midiNoteNumber = midiNoteNumber
        self.pressedTime = pressedTime
        
        super.init()
    }
}
