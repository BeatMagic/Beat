//
//  ReferenceTrackMessage.swift
//  BeatDemo
//
//  Created by X Young. on 2018/9/6.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import HandyJSON

class ReferenceTrackMessage: HandyJSON {

    /// 曲式 每个段落之间的分割线
    var sectionNumInParagraph: [Int] = []
    
    /// 每小节最大Beat数
    var beatsNumInSection: Int = 16

    /// 每小节多少秒
    var secondsInOneSection: Double = 0

    /// 小节总数
    var totalSectionsNum: Int = 0

    /// 拍点构成
    var beatConstitutionTypeArray: [BeatConstitutionType] = []

    /// 每个小节内16个Beat的强弱信息 ()
    var strongLevelInformationInSection: [StrongLevelInformation] = [.Weak]
    
    /// 各种乐器的音域
    var variousInstrumentArray: [InstrumentRange] = []

    /// 和声信息数组
    var harmonyMessageArray: [HarmonyMessage] = []

    /// 主题句信息
    var topicSentenceArray: [TopicSentence] = []

    /// 和弦信息数组
    var chordMessageArray: [ChordMessage] = []
    
    required init() {}
}

/// 拍点构成
enum BeatConstitutionType: Int, HandyJSONEnum {
    case Type2222 = 0
    case Type332 = 1
    case Type323 = 2
    case Type233 = 3
}

/// 每个Beat的强弱信息
enum StrongLevelInformation: Int, HandyJSONEnum {
    case Strongest = 3
    case Strong = 2
    case Weak = 1
    case Weakest = 0
}

/// 乐器的音域
class InstrumentRange: HandyJSON {
    /// 乐器名称
    var name: String = ""
    /// 下限音高
    var lowestMidiNum: Int = 0
    /// 上限音高
    var highestMidiNum: Int = 0
    
    required init() {}
}

/// 和声信息
class HarmonyMessage: HandyJSON {
    /// 音高 [1st根音, 2st第二, ...]
    var scale: [Int] = []
    /// 起始拍
    var startBeat: Int = 0
    /// 终结拍
    var endBeat: Int = 0

    required init() {}
}

/// 主题句信息
class TopicSentence: HandyJSON {
    /// 主调
    var mainTone: Int = 0
    
    /// 主调五声音名
    var mainToneChineseScale: [String] = [""]

    /// 在参考轨的位置
    var location: [Int] = []

    required init() {}
}

class ChordMessage: HandyJSON {
    /// 位置 (Beat)
    var location: [Int] = []
    
    /// 调性
    var tonality: String = ""
    
    /// 稳定音
    var stableNote: [Int] = []

    required init() {}
}
