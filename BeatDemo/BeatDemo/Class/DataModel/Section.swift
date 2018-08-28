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
    var passNoteEventArray: [NoteEvent]! = [] {
        didSet {
            if passNoteEventArray.count > 0 {
                isHaveNoteEvent = true
                
            }
        }
    }
    
    /// 是否有音阶
    var isHaveNoteEvent: Bool = false
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
            if noteEvent.startTime != noteEvent.endTime {
                let tmpSection = tmpSectionModelArray[noteEvent.belongToSection]
                
                tmpSection.passNoteEventArray.append(noteEvent)
                /// 如果最后一个音的EndTime不在该小节内
                if tmpSection.endTime < noteEvent.endTime {
                    // 需要延后的时间
                    let needDelayTime = noteEvent.endTime - tmpSection.endTime
                    // 需要延后的小节数
                    let needDelaySection = Int.init(needDelayTime / 3)
                    
                    
                    tmpSectionModelArray[noteEvent.belongToSection + 1 + needDelaySection].delayTime = needDelayTime - Double.init(needDelaySection * 3)
                    for index in 0 ..< needDelaySection {
                        tmpSectionModelArray[noteEvent.belongToSection + index].delayTime = 3
                    }
                }
                
                /// 排序
                tmpSection.passNoteEventArray = tmpSection.passNoteEventArray.sorted(by: { (note1, note2) -> Bool in
                    return note1.startTime < note2.startTime
                })
            }
            
        
        }
    }// funcEnd
    
    /// 返回一个结果数组
    static func getSectionIsFinishedArray(sectionModelArray: [Section]) -> Void {
        
        
        
        
    }// funcEnd
    
    
}
