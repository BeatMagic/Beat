//
//  NoteEvent.swift
//  BeatDemo
//
//  Created by apple on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class NoteEvent: NSObject {
    /// 开始音阶
    let startNoteNumber: UInt8!
    /// 开始时间
    let startTime: Double!
    /// 结束时间
    let endTime: Double!
    /// 经过音阶
    let passedNotes: [PassNote]?
    
    /// 开始拍子
    let startBeat: UInt8!
    /// 结束拍子
    let endbeat: UInt8!
    
    init(startNoteNumber: UInt8,
         startTime: Double,
         endTime: Double,
         passedNotes: [PassNote]?) {
        self.startNoteNumber = startNoteNumber
        self.startTime = startTime
        self.endTime = endTime
        self.passedNotes = passedNotes
        
        self.startBeat = DataStandard.getBeat(startTime)
        self.endbeat = DataStandard.getBeat(endTime)
        
        super.init()
        
    }

}
