//
//  DataStandard.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/23.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class DataStandard: NSObject {
    /// 八度
    static let octave: UInt8 = 5
    
    /// 音高
    static let root: UInt8 = octave * 12 + UInt8(VariousOperateFunc.highWhiteNote.rawValue)
    
    /// 一秒多少拍子
    static let oneBeatWithTime: Double = 128 / 3
    
    /// 生成音乐键的规则 前四小节
    static let MusicKeysRulesA: [Int] = [
        0, -2, -3, -5, -7, -9, -10, -12, -14, -15, -17, -19
    ]
    
    /// 生成音乐键的规则 后五小节
    static let MusicKeysRulesB: [Int] = [
        0, -2, -3, -5, -7, -9, -10, -12, -14, -15, -17, -19
    ]
    
    /// 生成音乐键的音阶数组 (规则A)
    static let MusicKeysNoteArrayA: [UInt8] = {
        var tmpArray: [UInt8] = []
        
        for index in 0 ..< 9 {
            let noteA = root - UInt8(-MusicKeysRulesA[index])
            tmpArray.append(noteA)
    
        }
        
        return tmpArray
    }()
    
    /// 生成音乐键的音阶数组 (规则B)
    static let MusicKeysNoteArrayB: [UInt8] = {
        var tmpArray: [UInt8] = []
        
        for index in 0 ..< 9 {
            let noteA = root - UInt8(-MusicKeysRulesB[index])
            tmpArray.append(noteA)
            
        }
        
        return tmpArray
    }()
    
    /// 音乐键标题
    static let MusicKeysTitle: [String] = [
        "2", "1", "7", "6", "5", "4", "3", "2", "1", "7", "6", "5",
    ]
    /// 重要音乐键标题
    static let MusicKeysImportentTitle: [String] = [
        "2", "1", "6", "5", "3"
    ]
    
    /// 稳定音
    static let MusicStabileKeysIndexArray: [ [Int] ] = [
        [],
        [1, 3, 5, 8, 10],
        [0, 2, 4, 7, 9, 11],
        [2, 4, 6, 9, 11],
        [1, 3, 6, 8, 10],
        [0, 3, 5, 7, 10],
        [0, 2, 4, 7, 9, 11],
        [1, 4, 6, 8, 11],
        [0, 2, 4, 7, 9, 11],
    ]
    
    /// 稳定音高
    static let SteadyMidiArray: [[UInt8]] = {
        var totalArray: [UInt8] = []

        for dValue in DataStandard.MusicKeysRulesA {
            totalArray.append(DataStandard.root - UInt8(-dValue))
            
        }
        
        var tmpMidiArray: [[UInt8]] = [
            [],[],[],[],[],[],[],[],[],
        ]
        var index = 0
        
        for keysIndexArray in DataStandard.MusicStabileKeysIndexArray {
            
            for keyIndex in keysIndexArray {
                tmpMidiArray[index].append(totalArray[keyIndex])
                
            }
            
            index += 1
        }
        
        return tmpMidiArray
    }()
    
    /// 音乐文件信息
    static let MusicFileMessage: Dictionary<String, Dictionary<String, Any>> = [
        "Build": [
            "fileName": "输入伴奏.mp3"
        ],
        
        "Edit_Normal": [
            "fileName": "播放伴奏_普通.mp3",
            "delayTime": 0,
        ],
        
        "Edit_Rock": [
            "fileName": "播放伴奏_摇滚.mp3",
            "delayTime": 0,
        ],
    ]
    
    /// 两个八度的误差(需要提高两个八度播放)
    static let NeedHigherPlay = 12 * 2
    
    
    /// 和声节奏层套路数组
    static let RhythmLayerRoutinesArray: [RhythmLayerRoutineModel] = {
        var array: [RhythmLayerRoutineModel] = []
        
        
        for index in 0 ..< 8 {
            let itemModel = RhythmLayerRoutineModel.init()
            
            let specificKindIndex = (index - index % 2) / 2
            var isVariant = false
            if index % 2 != 0 {
                isVariant = true
            }
            
            itemModel.specificKind = BeatConstitutionType.init(rawValue: specificKindIndex)!
            itemModel.isVariant = isVariant
            
            array.append(itemModel)
            
        }
        
        array[0].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 4),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 4, endBeat: 8),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 8, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 12, endBeat: 16),
        ]
        
        array[1].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 4),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 4, endBeat: 8),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 8, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 9, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 12, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 15, endBeat: 16),
        ]
        
        array[2].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 6),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 6, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 6, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 6, endBeat: 12),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 12, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 12, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 12, endBeat: 16),
            
        ]
        
        array[3].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 6),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 6, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 6, endBeat: 12),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 6, endBeat: 12),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 12, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 14, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 14, endBeat: 16),
        ]
        
        array[4].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 6),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 6, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 6, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 6, endBeat: 10),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 10, endBeat: 16),
            
        ]
        
        array[5].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 6),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 6, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 6, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 6, endBeat: 10),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 11, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 12, endBeat: 16),
        ]
        
        array[6].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 4),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 4, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 4, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 4, endBeat: 10),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 10, endBeat: 16),
            
        ]
        
        array[7].noteArray = [
            RhythmLayerSectionNote.init(scaleIndex: 0, startBeat: 0, endBeat: 4),
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 4, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 4, endBeat: 10),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 4, endBeat: 10),
            
            RhythmLayerSectionNote.init(scaleIndex: 1, startBeat: 10, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 3, startBeat: 12, endBeat: 16),
            RhythmLayerSectionNote.init(scaleIndex: 2, startBeat: 14, endBeat: 16),
        ]
        
        
        
        return array
    }()
}

extension DataStandard {
    /// 输入时间(Double)返回拍子数
    static func getBeat(_ time: Double) -> Int {
        
        return lroundf(Float(time * DataStandard.oneBeatWithTime))
        
    }// funcEnd
    
    static func getMeasureSteadyMidi(_ measure: Int) -> [UInt8] {
        
        return SteadyMidiArray[measure]
    }
}
