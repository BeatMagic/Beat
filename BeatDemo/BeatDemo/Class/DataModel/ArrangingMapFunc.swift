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
        let interval = Double.init(endSection - startSection) / Double.init(suitableScaleArray.count)
        
        for suitableScale in suitableScaleArray {
            let noteEvent = NoteEvent.init(startNoteNumber: UInt8(suitableScale),
                                           startTime: Double.init(startSection) * model.secondsInOneSection,
                                           endTime: Double.init(startSection) * model.secondsInOneSection + interval,
                                           passedNotes: nil)
            
            noteEventArray.append(noteEvent)
        }
        
        return noteEventArray
        
    }// funcEnd
    
    
    /// 生成复杂节奏层
    static func generateComplexRhythmLevel(_ model: ReferenceTrackMessage, instrumentName: String) -> [NoteEvent] {
        
        var array: [NoteEvent] = []
        
        // 当前小节
        var sectionIndex: Double = 0
        
        for beatConstitutionType in model.beatConstitutionTypeArray {
            // 获取拍子结构数组
            let beatGroup = self.getBeatGroup(beatConstitutionType)
            
            var lastBeatIndex = 0
            // 遍历拍子结构数组获取每个拍子组是否有音
            for beat in beatGroup {
                lastBeatIndex += beat
                
                /// 当前拍子组结束时间
                let lastTime = sectionIndex * model.secondsInOneSection + Double.init(lastBeatIndex * 3) / 16
                
                // 1没有2有
                let isHaveNote = ToolClass.randomInRange(range: 1 ... 2)
                if isHaveNote == 2 {
                    /// 当前音符长度
                    let noteLength = ToolClass.randomInRange(range: 1 ... beat)
                    /// 当前拍
                    let totalBeatIndex = Int.init(sectionIndex) * 16 + lastBeatIndex
                    /// 当前和声音符
                    if let midiNote = self.getMidiNoteFrom(totalBeatIndex, harmonyMessageArray: model.harmonyMessageArray) {
                        
                        // 返回选定的乐器
                        let instrumenthighNote: Int = {
                            for range in model.variousInstrumentArray {
                                if range.name == instrumentName {
                                    return range.highestMidiNum
                                }
                            }
                            
                            return 0
                        }()

                        let tmpMideNote = UInt8(self.getMidiNoteFrom(midiNote, highestMidiNum: instrumenthighNote))
                        
                        let note = NoteEvent.init(startNoteNumber: tmpMideNote,
                                                  startTime: lastTime - Double.init(noteLength * 3) / 16 ,
                                                  endTime: lastTime,
                                                  passedNotes: nil)
                        array.append(note)
                    }
                    
                }
                
                if lastBeatIndex == 16 {
                    lastBeatIndex = 0
                }
            }
            
            
            sectionIndex += 1
        }

        
        

        return array
        
    }// funcEnd
    
    
// MARK: - 私有方法
    /// 给定一个音域与一个确定的音高, 返回在该音域内的一个音符 [乐器]
    static private func getMidiNoteFrom(_ scale: Int, highestMidiNum: Int) -> Int {
        
        var tmpScale = scale
        while tmpScale > highestMidiNum {
            tmpScale -= 12
            
        }
        
        return tmpScale
    }// funcEnd
    
    /// 给定拍子的序号, 返回一个音符
    static private func getMidiNoteFrom(_ beatIndex: Int, harmonyMessageArray: [HarmonyMessage]) -> Int? {
        for harmonyMessage in harmonyMessageArray {
            if beatIndex >= harmonyMessage.startBeat && beatIndex <= harmonyMessage.endBeat {
                return harmonyMessage.scale.first!
                
            }
            
        }
        
        return nil
    }
    
    
    /// 给定一个拍点构成类型, 返回一个小节内的拍子构成
    static private func getBeatGroup(_ type: BeatConstitutionType) -> [Int] {
        switch type {
        case .Type2222:
            return [4, 4, 4, 4]
            
        case .Type233:
            return [4, 6, 6]
            
        case .Type323:
            return [6, 4, 6]
            
        case .Type332:
            return [6, 6, 4]
            
        }
    }// funcEnd
    
    
}
