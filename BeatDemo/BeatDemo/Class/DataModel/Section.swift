//
//  Section.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/25.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class Section: NSObject {
    /// 开始录制时间
    var startTime: Double!
    /// 结束录制时间
    var endTime: Double!
    /// 延迟时间
    var delayTime: Double! = 0
    /// 经过的音阶
    var passNoteEventArray: [NoteEvent]! = []
    
    /// 开始拍子
    var startBeat: Int!
    /// 结束拍子
    var endbeat: Int!

    init(startTime: Double,
         endTime: Double,
         passNoteEventArray: [NoteEvent]?,
         delayTime: Double?) {
        
        self.startTime = startTime
        self.endTime = endTime
    
        if let tmpDelayTime = delayTime {
            self.delayTime = tmpDelayTime
        }
        
        if let array = passNoteEventArray {
            self.passNoteEventArray = array
        }
        self.startTime = startTime
        
        self.startBeat = DataStandard.getBeat(startTime)
        self.endbeat = DataStandard.getBeat(endTime)
        
    }

}

extension Section {
    /// 处理noteEvent数组并存储到小节模型
    static func getSectionModel(noteEventArray: [NoteEvent], tmpSectionModelArray: [Section]) -> Void {
        
        // 将所有音存入所属小节
        for noteEvent in noteEventArray {
            tmpSectionModelArray[noteEvent.belongToSection].passNoteEventArray.append(noteEvent)
        }
        
        
        for index in 0 ..< 9 {
            
            let sectionModel = tmpSectionModelArray[index]
            
            // 经过两个及以上音符的时候
            if sectionModel.passNoteEventArray.count != 0 {
                
                // 检查最末一个音是否超车
                if sectionModel.passNoteEventArray.last?.isTooLong == true {
                    
                    // 超车时间大于3秒
                    let tooLongTime = sectionModel.passNoteEventArray.last?.tooLongTime
                    let needDelaySection = Int.init(tooLongTime! / 3)
                    
                    for needDelaySectionIndex in 0 ..< needDelaySection {
                        tmpSectionModelArray[index + needDelaySectionIndex + 1].delayTime = 3
                    }
                    
                    tmpSectionModelArray[index + needDelaySection + 1].delayTime = tooLongTime! - Double.init(exactly: needDelaySection * 3)!
                    
                }
                
            }
        }
    
    }// funcEnd
}
