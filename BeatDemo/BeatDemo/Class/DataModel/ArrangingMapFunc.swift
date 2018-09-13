//
//  ArrangingMapFunc.swift
//  BeatDemo
//
//  Created by X Young. on 2018/9/6.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class ArrangingMapFunc: NSObject {
    /// 生成一个编曲图谱Model
    static func initOneReferenceTrack() -> ReferenceTrackMessage {
        let model = ReferenceTrackMessage.init()
        model.sectionNumInParagraph = [1, 9, 17, 18]
        model.secondsInOneSection = 3.0
        model.totalSectionsNum = 18
        
        // MARK: - 测试数据
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
    

    
    /// 生成复杂节奏层
    static func generateComplexRhythmLevel(_ model: ReferenceTrackMessage, instrumentRange: InstrumentRange) -> [NoteEvent] {
        
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
                let isHaveNote = ToolClass.randomInRange(range: 1 ... 3)
                if isHaveNote == 2 {
                    /// 当前音符长度
                    let noteLength = ToolClass.randomInRange(range: 1 ... beat)
                    /// 当前拍
                    let totalBeatIndex = Int.init(sectionIndex) * 16 + lastBeatIndex
                    /// 当前和声音符
                    if let midiNote = self.getMidiNoteFrom(totalBeatIndex, harmonyMessageArray: model.harmonyMessageArray) {
                        
                        // 返回选定的乐器
                        let instrumentHighNote = instrumentRange.highestMidiNum
                        let instrumentLowNote = instrumentRange.lowestMidiNum
                        

                        let tmpMideNote = UInt8(self.getMidiNoteFrom(midiNote, highestMidiNum: instrumentHighNote, lowestMidiNum: instrumentLowNote))
                        
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
    
    
    
    /// 从XML文件中提取和声信息数组
    static func getHarmonyMessageArray(_ fileName: String) -> [HarmonyMessage] {
        let filePath = Bundle.main.path(forResource: fileName, ofType: nil)
        if filePath == nil {
            return []
            
        }
        
        let xml = try! XML.parse(Data.init(contentsOf: URL.init(fileURLWithPath: filePath!)))
        // 获取小节的集合
        let sectionSet = xml.element!.childElements[0].childElements[3].childElements
        
        var array: [HarmonyMessage] = []
        
        for sectionIndex in 0 ..< 18 {
            let item = HarmonyMessage.init()
            item.startBeat = sectionIndex * 16
            item.endBeat = item.startBeat + 16
            
            let sectionXml = sectionSet[sectionIndex].childElements
            
            for note in sectionXml {
                
                if note.name == "note" {
                    
                    for pitch in note.childElements {
                        
                        if pitch.name == "pitch" {
                            
                            var scaleName = "1"
                            var octaveCount = 0
                            var isRising = false
                            
                            // 为每个信息赋值
                            for pitchChildren in pitch.childElements {
                                switch pitchChildren.name {
                                case "step":
                                    scaleName = pitchChildren.text!
                                    
                                case "octave":
                                    octaveCount = Int(pitchChildren.text!)! - 2
                                    
                                case "alter":
                                    isRising = true
                    
                                default:
                                    print("?")
                                }
                                
                            }
                            
                            // 获得音符
                            let tmpMidiNote = self.getMidiNote(scaleName, octaveCount: octaveCount, isRising: isRising)
                            
                            let midiNote = tmpMidiNote
                            item.scale.append(midiNote)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            array.append(item)
        }
        
        return array
    }// funcEnd
    
    /// 从XMl文件中获取编曲图谱字典
    static func getArrangingMapDictFrom(_ xmlFileName: String) -> [String: [String]] {
        let filePath = Bundle.main.path(forResource: xmlFileName, ofType: nil)
        var resultDict = [String: [String]]()

        if filePath == nil {
            return resultDict
            
        }
        
        let xml = try! XML.parse(Data.init(contentsOf: URL.init(fileURLWithPath: filePath!)))
        var rowsElementArray: [XML.Element] = []
        
        for firstElement in xml.element!.childElements {
            if firstElement.name == "Workbook" {
                
                for secondElement in firstElement.childElements {
                    if secondElement.name == "Worksheet" {
                        
                        for thirdElement in secondElement.childElements {
                            if thirdElement.name == "Table" {
                                rowsElementArray = thirdElement.childElements
                            }
                        }
                        
                    }
                }
                
            }
        }
        
        
        for rowsElement in rowsElementArray {
            let rowTitle = rowsElement.childElements.first!.childElements.first!.text!
            resultDict[rowTitle] = []
            
            // 在一行中的每一个单元格(Cell)
            for cellElement in rowsElement.childElements {
                resultDict[rowTitle]!.append(cellElement.childElements.first!.text!)
                
            }

        }

        // TODO: 初步数组进行二次处理
        
        
        
        return resultDict
    }// funcEnd
    

    
    

    
// MARK: - 工具方法
    /// 给定一个拍点构成类型, 返回一个小节内的拍子构成
    static func getBeatGroup(_ type: BeatConstitutionType) -> [Int] {
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
    
    /// 给定一个音阶与八度信息 返回midi音符数字
    static func getMidiNote(_ scaleName: String, octaveCount: Int, isRising: Bool?) -> Int {
        var tmpScale = 0
        
        switch scaleName {
        case "A":
            tmpScale = 9
            
        case "B":
            tmpScale = 11
            
        case "C":
            tmpScale = 0
            
        case "D":
            tmpScale = 2
            
        case "E":
            tmpScale = 4
            
        case "F":
            tmpScale = 5
            
        case "G":
            tmpScale = 7
            
        default:
            return 0
        }
        
        if isRising != true {
            return tmpScale + octaveCount * 12 + 24
            
        }else {
            return tmpScale + octaveCount * 12 + 1 + 24
            
        }
        
    }// funcEnd
    
    /// 扩展: 通过一个字符串获取midi音符数字
    static func getMidiNoteFromString(_ noteString: String) -> Int {
        let scale = ToolClass.cutStringWithPlaces(
            noteString, startPlace: 0, endPlace: 1
        )
        
        let octaveCountString = ToolClass.cutStringWithPlaces(
            noteString, startPlace: noteString.count - 1, endPlace: noteString.count
        )
        
        let isRising: Bool = {
            if noteString.range(of: "#") == nil {
                return false
                
            }
            
            return true
            
        }()
        
        return self.getMidiNote(scale, octaveCount: Int(octaveCountString)!, isRising: isRising)
        
    }
    
    /// 给定一个音域与一个确定的音高, 返回在该音域内的一个音符 [乐器]
    static func getMidiNoteFrom(_ scale: Int, highestMidiNum: Int, lowestMidiNum: Int) -> Int {
        
        var tmpScale = scale
        
        if tmpScale > highestMidiNum {
            while tmpScale > highestMidiNum {
                tmpScale -= 12
            }
            
        }else if tmpScale < lowestMidiNum {
            while tmpScale < lowestMidiNum {
                tmpScale += 12
            }
            
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
    
    

    
    
}
