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
    static let octave: UInt8 = 6
    
    /// 音高
    static let root: UInt8 = octave * 12 + UInt8(VariousOperateFunc.highWhiteNote.rawValue) - 1
    
    /// 一秒多少拍子
    static let oneBeatWithTime: Double = 16 / 3
    
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
    
    /// 稳定音
    static let MusicStabileKeysIndexArray: [ [Int] ] = [
        [],
        [1, 3, 5, 8, 10],
        [0, 2, 7, 9],
        [2, 4, 6, 9, 11],
        [1, 3, 6, 8, 10],
        [0, 3, 5, 7, 10],
        [0, 2, 4, 7, 9, 11],
        [1, 4, 6, 8, 11],
        [0, 2, 4, 7, 9, 11],
    ]
    
    /// 音乐文件信息
    static let MusicFileMessage: Dictionary<String, Dictionary<String, Any>> = [
        "Build": [
            "fileName": "输入伴奏.mp3"
        ],
        
        "Edit": [
            "fileName": "播放伴奏.mp3",
            "delayTime": 0, 
        ],
    ]
}

extension DataStandard {
    /// 输入时间(Double)返回拍子数
    static func getBeat(_ time: Double) -> Int {
        
        return lroundf(Float(time * DataStandard.oneBeatWithTime))
        
    }// funcEnd
}
