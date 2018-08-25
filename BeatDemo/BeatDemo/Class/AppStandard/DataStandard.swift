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
    static let octave: UInt8 = 7
    
    /// 音高
    static let root: UInt8 = octave * 12
    
    /// 一秒多少拍子
    static let oneBeatWithTime: Double = 16 / 3
    
    /// 
}

extension DataStandard {
    /// 输入时间(Double)返回拍子数
    static func getBeat(_ time: Double) -> Int {
        
        return lroundf(Float(time * DataStandard.oneBeatWithTime))
        
    }// funcEnd
}
