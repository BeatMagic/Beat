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
    
    //// 音乐计时器状态
    enum MusicTimerState {
        case initState, timing, caused
    }
    
    /// 音乐播放状态
    enum MusicPlayStates {
        case played, caused
    }
    
    /// 图片名枚举
    enum ImageName: String {
        /// 重置
        case reset = "reset"
        /// 暂停
        case cause = "cause"
        /// 播放
        case play = "play"
        /// 删除
        case delete = "delete"
        /// 编辑
        case edit = "edit"
        /// 所有音乐
        case allMusic = "all_music"
        /// 返回
        case back = "back"
        /// 关闭
        case close = "close"
    }
    
}
