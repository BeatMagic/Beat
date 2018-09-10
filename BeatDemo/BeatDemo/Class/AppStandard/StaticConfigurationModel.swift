//
//  StaticConfigurationModel.swift
//  BeatDemo
//
//  Created by X Young. on 2018/9/7.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class StaticConfigurationModel: NSObject {
    
    
    /// pad的乐器信息
    static let padInstrumentRange: InstrumentRange = {
        let tmpModel = InstrumentRange.init()
        tmpModel.highestMidiNum = 74
        tmpModel.lowestMidiNum = 40
        tmpModel.name = "pad"
        
        return tmpModel
    }()
    
    /// 钢琴的乐器信息
    static let pianoInstrumentRange: InstrumentRange = {
        let tmpModel = InstrumentRange.init()
        tmpModel.highestMidiNum = 84
        tmpModel.lowestMidiNum = 40
        tmpModel.name = "piano"
        
        return tmpModel
    }()
    
    /// 钢琴的乐器信息
    static let bassInstrumentRange: InstrumentRange = {
        let tmpModel = InstrumentRange.init()
        tmpModel.highestMidiNum = 39
        tmpModel.lowestMidiNum = 51
        tmpModel.name = "bass"
        
        return tmpModel
    }()
    
    
    /// 根据乐器生成和声节奏层音符数组
    static func getRhythmLayerNoteArray(_ harmonyMessageArray: [HarmonyMessage], instrumentRangeModel: InstrumentRange) -> [NoteEvent] {
        
        // 生成pad的四部和声音符数组
        var padNoteEventArray: [NoteEvent] = []
        
        for beatIndex in 0 ..< 18 {
            
            let harmonyMessage = harmonyMessageArray[beatIndex]
            
            for scale in harmonyMessage.scale {
                
                // 生成pad的音
                let padNoteNumber = ArrangingMapFunc.getMidiNoteFrom(scale, highestMidiNum: instrumentRangeModel.highestMidiNum, lowestMidiNum: instrumentRangeModel.lowestMidiNum)
                
                let padNote = NoteEvent.init(startNoteNumber: UInt8(padNoteNumber),
                                             startTime: Double(harmonyMessage.startBeat / 16 * 3),
                                             endTime: Double(harmonyMessage.endBeat / 16 * 3),
                                             passedNotes: nil)
                
                
                padNoteEventArray.append(padNote)
                
                
            }
            
        }
        
        return padNoteEventArray
        
    }// funcEnd
    
    
    /// 生成钢琴复杂节奏层音符数组 [钢琴和声节奏层音符数组]
    static func getPainoNoteArray(_ pianoFirstNoteArray: [NoteEvent],model: ReferenceTrackMessage) -> [NoteEvent] {
        
        /*
         // 生成四部和声midi
         let harmonyMessageArray = ArrangingMapFunc.getHarmonyMessageArray("四部和声midi.xml")
         
         let model = ReferenceTrackMessage.init()
         model.harmonyMessageArray = harmonyMessageArray
         
         var pianoFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(
         harmonyMessageArray,
         instrumentRangeModel: StaticConfigurationModel.pianoInstrumentRange
         )
         
         var pianoSecondNoteArray: [NoteEvent] = []
         */
        
        
        var pianoSecondNoteArray: [NoteEvent] = []
        
        for index in 0 ..< 18 {
            if index == 17 {
                break
            }
            
            // 当前小组Beat分布
            let sectionBeatConstitutionType = model.beatConstitutionTypeArray[index]
            
            // 概率
            let probability = ToolClass.randomInRange(range: 1 ... 11)
            // 和声节奏层套路模型
            var rhythmLayerRoutineModel: RhythmLayerRoutineModel
            
            if probability <= 7 { // 70%是正常
                rhythmLayerRoutineModel = DataStandard.RhythmLayerRoutinesArray[sectionBeatConstitutionType.rawValue * 2]
                
            }else { // 30%特殊
                rhythmLayerRoutineModel = DataStandard.RhythmLayerRoutinesArray[sectionBeatConstitutionType.rawValue * 2 + 1]
                
            }
            
            for tmpSimpleNote in rhythmLayerRoutineModel.noteArray {
                
                let finalNote = NoteEvent.init(
                    startNoteNumber: pianoFirstNoteArray[index * 4 + tmpSimpleNote.scaleIndex].startNoteNumber,
                    startTime: Double.init(tmpSimpleNote.startBeat) / 16 * 3 + Double.init(index * 3),
                    endTime: Double.init(tmpSimpleNote.endBeat) / 16 * 3 + Double.init(index * 3),
                    passedNotes: nil)
                
                pianoSecondNoteArray.append(finalNote)
                
            }
            
        }
        
        
        for index in (pianoFirstNoteArray.count - 4) ..< pianoFirstNoteArray.count  {
            pianoSecondNoteArray.append(pianoFirstNoteArray[index])
        }
        
        
        
        let complexRhythmNoteArray = ArrangingMapFunc.generateComplexRhythmLevel(model, instrumentRange: StaticConfigurationModel.pianoInstrumentRange)
        var tmpComplexRhythmNoteArray: [NoteEvent] = []
        
        
        for note in complexRhythmNoteArray {
            if note.endTime <= 3 {
                tmpComplexRhythmNoteArray.append(note)
                
            }else {
                break
                
            }
        }
        
        
        return tmpComplexRhythmNoteArray + pianoSecondNoteArray
        
    }// funcEnd
    
    
    /// 生成bass副旋律音符数组
    static func getBassNoteArray(_ bassFirstNoteArray: [NoteEvent], model: ReferenceTrackMessage) -> [NoteEvent] {
        
        var bassSecondNoteArray: [NoteEvent] = []
        
        for index in 0 ..< 18 {
            if index > 0 && index < 17 {
                // 当前小组Beat分布
                let sectionBeatConstitutionType = model.beatConstitutionTypeArray[index]
                // 概率
                let probability = ToolClass.randomInRange(range: 1 ... 4)
                // 和声节奏层套路模型
                let rhythmLayerRoutineModel = DataStandard.RhythmLayerRoutinesArray[sectionBeatConstitutionType.rawValue * 2]
                
                let tmpSimpleNote = rhythmLayerRoutineModel.noteArray[probability]
                
                let note = NoteEvent.init(
                    startNoteNumber: bassFirstNoteArray[index * 4 + tmpSimpleNote.scaleIndex].startNoteNumber ,
                    startTime: Double.init(tmpSimpleNote.startBeat) / 16 * 3 + Double.init(index * 3),
                    endTime: Double.init(tmpSimpleNote.endBeat) / 16 * 3 + Double.init(index * 3),
                    passedNotes: nil)
                
                
                
                bassSecondNoteArray.append(note)
                
                
            }
            
            
        }
        
        
        
        
        return bassSecondNoteArray
        
    }// funcEnd
    
    
    
}
