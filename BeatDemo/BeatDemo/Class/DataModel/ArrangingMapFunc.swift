//
//  ArrangingMapFunc.swift
//  BeatDemo
//
//  Created by X Young. on 2018/9/6.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class ArrangingMapFunc: NSObject {
    /// 生成一个编曲图谱Model
    static func initOneReferenceTrack() -> ReferenceTrackMessage {
        let model = ReferenceTrackMessage.init()
        model.sectionNumInParagraph = [1, 9, 17, 18]
        model.secondsInOneSection = 3.0
        model.totalSectionsNum = 18
        
        // MARK: - 测试数据
        model.beatConstitutionTypeArray = [.Type2222]
        model.strongLevelInformationInSection = [.Weak]
        
        let instrumentRange = InstrumentRange.init()
        instrumentRange.name = "🎸"
        instrumentRange.lowestMidiNum = 50
        instrumentRange.highestMidiNum = 56
        model.variousInstrumentArray = [ instrumentRange ]
        
        let harmonyMessage = HarmonyMessage.init()
        harmonyMessage.scale = []
        model.harmonyMessageArray = [harmonyMessage]
        
        
        let topicSentence = TopicSentence.init()
        topicSentence.mainTone = 50
        topicSentence.location = [0, 8]
        model.topicSentenceArray = [topicSentence]
        
        let chordMessage = ChordMessage.init()
        chordMessage.location = [0,9]
        chordMessage.tonality = "A"
        model.chordMessageArray = [chordMessage]
        
        
        return model
    }// funcEnd
    
    /// 生成和声节奏层
    static func generateHarmonyLevel(_ model: ReferenceTrackMessage, instrumentName: String, startSection: Int, endSection: Int) -> [NoteEvent] {

        // 找到选定的乐器
        var selectInstrument: InstrumentRange? = nil
        for variousInstrument in model.variousInstrumentArray {
            if variousInstrument.name == instrumentName {
                selectInstrument = variousInstrument
            }
        }
        
        // 没有匹配的乐器直接返回空数组
        if selectInstrument == nil {
            return []
        }
        
        // 匹配对应的和声信息数组
        var selectHarmonyMessage: HarmonyMessage? = nil
        for harmonyMessage in model.harmonyMessageArray {
            if harmonyMessage.startBeat == startSection * model.beatsNumInSection {
                selectHarmonyMessage = harmonyMessage
            }
        }
        
        // 没有匹配的和声信息直接返回空数组
        if selectHarmonyMessage == nil {
            return []
        }
        
        // 找到在选定乐器音域内的音高
        var suitableScaleArray: [Int] = []
        for tmpScale in selectHarmonyMessage!.scale {
            if tmpScale > selectInstrument!.highestMidiNum { // 不合适?
                suitableScaleArray.append(self.getMidiNoteFrom(tmpScale, highestMidiNum: selectInstrument!.highestMidiNum))
                
            }else { // 合适直接安排上了
                suitableScaleArray.append(tmpScale)
                
            }
            
        }
        
        // 在合适的音符里生成数组
        var noteEventArray: [NoteEvent] = []
        let interval = Double.init(endSection - startSection) / 3
        
        for suitableScale in suitableScaleArray {
            let noteEvent = NoteEvent.init(startNoteNumber: UInt8(suitableScale),
                                           startTime: Double.init(startSection) * model.secondsInOneSection,
                                           endTime: Double.init(startSection) * model.secondsInOneSection + interval,
                                           passedNotes: nil)
            
            noteEventArray.append(noteEvent)
        }
        
        return noteEventArray
        
    }// funcEnd
    
    
// MARK: - 私有方法
    /// 给定一个音域与一个确定的音高, 返回在该音域内的一个音符
    static private func getMidiNoteFrom(_ scale: Int, highestMidiNum: Int) -> Int {
        
        var tmpScale = scale
        while tmpScale > highestMidiNum {
            tmpScale -= 12
            
        }
        
        return tmpScale
    }// funcEnd
    
    
    
    
}
