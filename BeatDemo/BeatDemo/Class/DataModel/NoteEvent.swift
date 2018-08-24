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
    var startNoteNumber: UInt8!
    /// 开始时间
    var startTime: Double!
    /// 结束时间
    var endTime: Double!
    /// 经过音阶
    var passedNotes: [PassNote]?
    
    /// 开始拍子
    var startBeat: UInt8!
    /// 结束拍子
    var endbeat: UInt8!
    
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

extension NoteEvent {
    
    /// 从TmpNoteArray转换为NoteEvent
    static func getNoteEventFromTmpNoteArray(_ tmpNoteArray: [TmpNote]) -> NoteEvent? {
        switch tmpNoteArray.count {
        case 0:
            return nil
            
        case 1:
            let tmpNote = tmpNoteArray[0]
            return NoteEvent.init(startNoteNumber: tmpNote.midiNoteNumber, startTime: tmpNote.pressedTime, endTime: tmpNote.unPressedTime, passedNotes: nil)
            
        default:
            let firstTmpNote = tmpNoteArray[0]
            let lastTmpNote = tmpNoteArray[tmpNoteArray.count - 1]
            
            var passNoteArray: [PassNote] = []
            
            for index in 1 ..< tmpNoteArray.count  {
                let tmpNote = tmpNoteArray[index]
                passNoteArray.append(PassNote.init(midiNoteNumber: tmpNote.midiNoteNumber, enterTime: tmpNote.pressedTime, exitTime: tmpNote.unPressedTime))
            }
            
            return NoteEvent.init(startNoteNumber: firstTmpNote.midiNoteNumber, startTime: firstTmpNote.pressedTime, endTime: lastTmpNote.unPressedTime, passedNotes: passNoteArray)
            
        }
                
    }// funcEnd
}
