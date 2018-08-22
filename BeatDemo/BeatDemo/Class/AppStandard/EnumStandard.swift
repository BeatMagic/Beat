//
//  EnumStandard.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class EnumStandard: NSObject {
    
    /// 音乐键盘状态
    enum KeyStates {
        case notPressed, pressed
    }
    
    /// 音阶
    enum ScaleNotes: Int {
        case C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11
    }
}
