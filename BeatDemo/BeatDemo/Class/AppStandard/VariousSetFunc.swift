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
                                         musicKeyNotes: [Int],
                                         stableKeysRulesArray: [Int],
                                         stableKeysNextRulesArray: [Int]?) -> Void {
        
        let absoluteNum = highWhiteNote.rawValue
        var index = 0
        
        for musicKey in musicKeysArray {
            
            musicKey.midiNoteNumber = DataStandard.root - UInt8(-musicKeyNotes[index] + absoluteNum)
            
            
            if stableKeysRulesArray.contains(index) {
                
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.flatGreen
                }
                
                if musicKey.isMainKey == true {
                    
                    DispatchQueue.main.async {
                        musicKey.dogImageView!.tintColor = UIColor.white
                    }
                    
                }

            }else {
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.white
                }
                
                if musicKey.isMainKey == true {
                    
                    DispatchQueue.main.async {
                        musicKey.dogImageView!.tintColor = UIColor.flatGreen
                    }
                    
                }
            }
            

            
            
            index += 1
        }
        
        

    }
    
    
    static func playMIDI(totalDelayTime: Double,
                         basicSequencer: BasicSequencer) -> Void {
        
        DelayTask.cancelAllWorkItems()
        DelayTask.createTaskWith(workItem: {
            basicSequencer.playMelody()
        }, delayTime: totalDelayTime)
    }
}
