//
//  VariousSetFunc.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/29.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class VariousOperateFunc: NSObject {
    
    static let highWhiteNote: EnumStandard.ScaleNotes = EnumStandard.ScaleNotes.B
    
    static func setMusicKeysEverySection(_ musicKeysArray: [BaseMusicKey],
                                         stableKeysRulesArray: [Int],
                                         musicKeyNotes: [Int]) -> Void {
        
        let absoluteNum = highWhiteNote.rawValue
        var index = 0
        
        for musicKey in musicKeysArray {
            
            musicKey.midiNoteNumber = DataStandard.root - UInt8(-musicKeyNotes[index] + absoluteNum)
            
            if stableKeysRulesArray.contains(index) {
                
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.flatGreen
                }
                
                
            }else {
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.white
                }
            }
            
            
            index += 1
        }
        
    }
    
    
    static func playMIDI(sectionArray: [Section],
                         totalDelayTime: Double,
                         basicSequencer: BasicSequencer) -> Void {
        
        DelayTask.cancelAllWorkItems()
        
        for sectionModel in sectionArray {
            // 小节Model里有音
            if sectionModel.passNoteEventArray.count != 0 {
                var playDelayTime: Double = 0
                
                playDelayTime = Double.init(sectionModel.passNoteEventArray.first!.startBeat) / DataStandard.oneBeatWithTime
                
                DelayTask.createTaskWith(name: "", workItem: {
                    basicSequencer.SetNoteEventSeq(noteEventSeq: sectionModel.passNoteEventArray)
                    basicSequencer.playMelody()
                    
                }, delayTime: playDelayTime + totalDelayTime)
                
            }
        }
    }
}
