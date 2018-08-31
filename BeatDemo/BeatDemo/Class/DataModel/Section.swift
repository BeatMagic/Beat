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

        for tmpSectionModel in tmpSectionModelArray {
            tmpSectionModel.passNoteEventArray = []
        }
        
        
        
        // 将所有音存入所属小节
        for noteEvent in noteEventArray {
            if noteEvent.startBeat != noteEvent.endbeat {
                let tmpSection = tmpSectionModelArray[noteEvent.belongToSection]
              
                tmpSection.passNoteEventArray.append(noteEvent)
                
            }
            
        
        }
    }// funcEnd
    
    /// 返回一个结果数组
    static func getSectionIsFinishedArray(sectionModelArray: [Section]) -> Void {
        
        
        
        
    }// funcEnd
    
    
}
