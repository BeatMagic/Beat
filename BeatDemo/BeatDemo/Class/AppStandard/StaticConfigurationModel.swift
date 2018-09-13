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
    
    /// Bass的乐器信息
    static let bassInstrumentRange: InstrumentRange = {
        let tmpModel = InstrumentRange.init()
        tmpModel.highestMidiNum = 39
        tmpModel.lowestMidiNum = 51
        tmpModel.name = "bass"
        
        return tmpModel
    }()
    
// MARK: - 根基
    /// 根据乐器生成和声节奏层音符数组
    static func getRhythmLayerNoteArray(_ harmonyMessageArray: [HarmonyMessage], instrumentRangeModel: InstrumentRange) -> [NoteEvent] {
        
        // 生成的四部和声音符数组
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
    
// MARK: - 根基的二次加工
    /// 生成pad复杂节奏层音符数组 []
    static func getPadNoteArray(_ padFirstNoteArray: [NoteEvent], padSectionStructureArray: [String], model: ReferenceTrackMessage, instrumentRangeModel: InstrumentRange) -> [NoteEvent] {
        var array: [NoteEvent] = []
        
        var sectionIndex = 0
        
        let complexRhythmNoteArray = ArrangingMapFunc.generateComplexRhythmLevel(model, instrumentRange: instrumentRangeModel)
        
        for padSectionStructure in padSectionStructureArray {
            
            let padNoteIndex = 4 * sectionIndex
            
            switch padSectionStructure {
            case "pad":
                array.append(padFirstNoteArray[padNoteIndex])
                array.append(padFirstNoteArray[padNoteIndex + 1])
                array.append(padFirstNoteArray[padNoteIndex + 2])
                array.append(padFirstNoteArray[padNoteIndex + 3])
                
            case "f":
                
                for note in complexRhythmNoteArray {
                    if note.startTime >= Double.init(sectionIndex * 3)
                        &&
                        note.endTime <= Double.init(sectionIndex * 3 + 3) {
                        array.append(note)
                        
                    }else if note.endTime > Double.init(sectionIndex * 3 + 3) {
                        break
                        
                    }
                    
                }
                
                
            default:
                print("无音符在此小节")
            }
            
            sectionIndex += 1
            
        }
        
        return array
        
    }
    

    /// 生成钢琴复杂节奏层音符数组 [钢琴和声节奏层音符数组]
    static func getPainoNoteArray(_ pianoFirstNoteArray: [NoteEvent], model: ReferenceTrackMessage, painoSectionStructureArray: [String]) -> [NoteEvent] {
        
        // 普通节奏层钢琴数组
        var pianoSecondNoteArray: [[NoteEvent]] = []
        // 最终的数组
        var pianoThirdNoteArray: [NoteEvent] = []
        
        for index in 0 ..< 18 {
            pianoSecondNoteArray.append([])
            
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
                
                pianoSecondNoteArray[index].append(finalNote)
                
            }
            
        }
        
        // 复杂节奏层钢琴数组全部
        let complexRhythmNoteArray = ArrangingMapFunc.generateComplexRhythmLevel(model, instrumentRange: StaticConfigurationModel.pianoInstrumentRange)
        

        var sectionIndex = 0
        for painoSectionStructure in painoSectionStructureArray {
            
            switch painoSectionStructure {
            case "fjz":
                pianoThirdNoteArray += pianoSecondNoteArray[sectionIndex]
                
                for note in complexRhythmNoteArray {
                    if note.startTime >= Double.init(sectionIndex * 3)
                        &&
                        note.endTime <= Double.init(sectionIndex * 3 + 3) {
                        pianoThirdNoteArray.append(note)
                        
                    }else if note.endTime > Double.init(sectionIndex * 3 + 3) {
                        break
                        
                    }
                    
                }
                
            case "f":
                for note in complexRhythmNoteArray {
                    if note.startTime >= Double.init(sectionIndex * 3)
                        &&
                        note.endTime <= Double.init(sectionIndex * 3 + 3) {
                        pianoThirdNoteArray.append(note)
                        
                    }else if note.endTime > Double.init(sectionIndex * 3 + 3) {
                        break
                        
                    }
                    
                }

            case "jz":
                pianoThirdNoteArray += pianoSecondNoteArray[sectionIndex]
                
            case "pad":
                pianoThirdNoteArray.append(pianoFirstNoteArray[sectionIndex * 4])
                pianoThirdNoteArray.append(pianoFirstNoteArray[sectionIndex * 4 + 1])
                pianoThirdNoteArray.append(pianoFirstNoteArray[sectionIndex * 4 + 2])
                pianoThirdNoteArray.append(pianoFirstNoteArray[sectionIndex * 4 + 3])
                
            default:
                print("无音符在此小节")
            }
            
            
            
            sectionIndex += 1
        }
        
        
        return pianoThirdNoteArray
        
    }// funcEnd
    
    
    /// 生成bass副旋律音符数组
    static func getBassNoteArray(_ bassFirstNoteArray: [NoteEvent], model: ReferenceTrackMessage, bassSectionStructureArray: [String]) -> [NoteEvent] {
        
        var bassSecondNoteArray: [NoteEvent] = []
        
        
        for index in 0 ..< 18 {
            let bassSectionStructure = bassSectionStructureArray[index]
            
            switch bassSectionStructure {
            case "f":
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
                // 测试
//                for tmpSimpleNote in rhythmLayerRoutineModel.noteArray {
//                    let note = NoteEvent.init(
//                        startNoteNumber: bassFirstNoteArray[index * 4 + tmpSimpleNote.scaleIndex].startNoteNumber,
//                        startTime: Double.init(tmpSimpleNote.startBeat) / 16 * 3 + Double.init(index * 3),
//                        endTime: Double.init(tmpSimpleNote.endBeat) / 16 * 3 + Double.init(index * 3),
//                        passedNotes: nil)
//
//                    bassSecondNoteArray.append(note)
//                }
                
                
                
                
                
                
            case "pad":
                bassSecondNoteArray.append(bassFirstNoteArray[index * 4])
                bassSecondNoteArray.append(bassFirstNoteArray[index * 4 + 1])
                bassSecondNoteArray.append(bassFirstNoteArray[index * 4 + 2])
                bassSecondNoteArray.append(bassFirstNoteArray[index * 4 + 3])

            default:
                print("无音符在此小节")
            }


            
        }
        
        
        
        return bassSecondNoteArray
        
    }// funcEnd
    
    /// 获取噪声层的数组
    static func getNoiseDrummNoteArray(tmpModelArray: [String]) -> [NoteEvent] {
        
        var dramNoteTotalArray: [[NoteEvent]] = []
        
        
        // 添加若干个空数组添加各个音色的音符
        for _ in DataStandard.noiseBeatRoutine.keys {
            dramNoteTotalArray.append([])
            
        }
        
        var sectionIndex = 0
        for tmpModel in tmpModelArray {
            
            let probablyCount = ToolClass.randomInRange(range: 1 ... 3)
            var dramModelDict: [String: [Int]]? = nil
            
            switch tmpModel {
                
            case "zy":
                if probablyCount == 2 {
                    dramModelDict = DataStandard.noiseBeatVariationRoutine
                    
                }else {
                    dramModelDict = DataStandard.noiseBeatRoutine
                    
                }

            case "zyf":
                dramModelDict = DataStandard.noiseBeatVariationRoutine

            default:
                dramModelDict = nil
            }
            
            if dramModelDict != nil {
                
                var dramToneKeyIndex = 0
                
                for dramToneKey in dramModelDict!.keys {
                    
                    for beatIndex in dramModelDict![dramToneKey]! {
                        
                        let note = NoteEvent.init(
                            startNoteNumber: UInt8(Int(dramToneKey)!),
                            startTime: Double.init(sectionIndex * 3) + Double.init(beatIndex - 1) * 3 / 16,
                            endTime:  Double.init(sectionIndex * 3) + Double.init(beatIndex) * 3 / 16,
                            passedNotes: nil)
                        
                        dramNoteTotalArray[dramToneKeyIndex].append(note)
                        
                    }
                    
                    dramToneKeyIndex += 1
                }
                
            }
            
            sectionIndex += 1
        }
        
        
        
        var dragNoteArray: [NoteEvent] = []
        
        for array in dramNoteTotalArray {
            for note in array {
                
                let noteEvent = NoteEvent.init(
                    startNoteNumber: note.startNoteNumber - 12,
                    startTime: note.startTime,
                    endTime: note.endTime,
                    passedNotes: nil)
                
//                let noteEvent = NoteEvent.init(
//                    startNoteNumber: note.startNoteNumber - 12,
//                    startTime: note.startTime - 27,
//                    endTime: note.endTime - 27,
//                    passedNotes: nil)
                
                dragNoteArray.append(noteEvent)

            }
            
        }
        
        return dragNoteArray
        
    }// funcEnd
    
    
    
}
