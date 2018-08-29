//
//  MusicKeyBoard.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//


import UIKit

// MARK: - Init
class MusicKeyBoard: UIView {
    
    /// 最高音阶
//    var highWhiteNote: EnumStandard.ScaleNotes = EnumStandard.ScaleNotes.B {
//        didSet {
//            setUp()
//        }
//    }
    
    /// 主音位置
    var mainMusicKeyIndex = 8
    
    /// 生成规则
//    var keyRules = DataStandard.MusicKeysRulesA {
//        didSet {
//            setUp()
//        }
//    }
    
//    var musicStabileKeysIndexArray: [Int] = []
    
    /// 音乐键数组
    var musicKeysArray = [BaseMusicKey]()
    /// 音高对应字典
    var pitchToKeyDict = [UInt8: BaseMusicKey]()
    /// 按下的键Set
    var pressedMusicKeys = Set<UInt8>()
    
    //MARK:- 重要数据
    var pressedTmpNote: [TmpNote] = []
    var noteEventModelList: [NoteEvent] = []
    var sectionArray: [Section] = {
        var tmpSectionArray: [Section] = []
        for index in 0 ..< 9 {
            let sectionModel = Section.init(startTime: Double(index * 3),
                                            endTime: Double((index + 1) * 3),
                                            passNoteEventArray: nil,
                                            delayTime: nil)
            
            tmpSectionArray.append(sectionModel)
        }
        
        return tmpSectionArray
    }()
    
    //MARK:-
    
    /// 所有键ViewModel
    var musicKeysViewModel: [CGRect] = [CGRect]()
    /// 外部代理
    weak var delegate: MusicKeyDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.musicKeysViewModel = {
            if ToolClass.getIPhoneType() == "iPhone X" {
                return self.initMusicKeyFrame(ownHeight: frame.height + 88)
                
            }else {
                return self.initMusicKeyFrame(ownHeight: frame.height)
                
            }
            
        }()
        
        
        DispatchQueue.main.async {
            self.initKeyBoard()
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.musicKeysViewModel = {
            if ToolClass.getIPhoneType() == "iPhone X" {
                return self.initMusicKeyFrame(ownHeight: self.getHeight() + 88)
                
            }else {
                return self.initMusicKeyFrame(ownHeight: self.getHeight())
                
            }
        }()
        
        DispatchQueue.main.async {
            self.initKeyBoard()
        }
    }
    
}

// MARK: - SetUp
extension MusicKeyBoard {
    
    ///  初始化一个键盘
    func initKeyBoard() -> Void {
        self.addMusicKeysWithViewModel(self.musicKeysViewModel)
        self.addMusicKey()
        
    }
    
//    override func layoutSubviews() {
//            self.addMusicKeysWithViewModel(self.musicKeysViewModel)
//            self.addMusicKey()
//    }
//
//    override func draw(_ rect: CGRect) {
//            self.addMusicKeysWithViewModel(self.musicKeysViewModel)
//            self.addMusicKey()
//    }
    
    /// 生成所有键的ViewModel -> [ CGRect ]
    private func initMusicKeyFrame(ownHeight: CGFloat) -> [CGRect] {
        let normalWidth = ToolClass.getScreenWidth() - FrameStandard.universalWidth
        let firstAreaKeyHeight = FrameStandard.universalHeight / 4
        let secondAreaKeyHeight = ownHeight - FrameStandard.universalHeight - FrameStandard.beatViewHeight
        let thirdAreaKeyHeight = FrameStandard.beatViewHeight / 3
        
        var keysViewModel = [CGRect]()
        for index in 0 ..< 4 {
            let firstAreaKeyCGRect = CGRect.init(x: 0, y: CGFloat(index) * firstAreaKeyHeight, width: normalWidth, height: firstAreaKeyHeight)
            keysViewModel.append(firstAreaKeyCGRect)
        }
        
        for index in 0 ..< 5 {
            let secondAreaCGRect = CGRect.init(x: CGFloat(index) * normalWidth, y: FrameStandard.universalHeight, width: normalWidth, height: secondAreaKeyHeight)
            keysViewModel.append(secondAreaCGRect)
        }
        
        for index in 0 ..< 3 {
            let firstAreaKeyCGRect = CGRect.init(x: FrameStandard.universalWidth, y: FrameStandard.universalHeight + secondAreaKeyHeight + CGFloat(index) * thirdAreaKeyHeight, width: normalWidth, height: thirdAreaKeyHeight)
            keysViewModel.append(firstAreaKeyCGRect)
        }
        
        return keysViewModel
    }// funcEnd

    /// 根据所有键的ViewModel生成键 [[CGRect]] -> Void
    private func addMusicKeysWithViewModel(_ viewModel: [CGRect] ) -> Void {
        // 先清空
        for key in self.musicKeysArray {
            key.removeFromSuperview()
        }
        
        musicKeysArray = [BaseMusicKey]()

        var index = 0
        
        for item in viewModel {
            
            let musicKey: BaseMusicKey = {
                
                if index == self.mainMusicKeyIndex {
                    return BaseMusicKey.init(frame: item, midiNoteNumber: 1, isMainKey: true)
                    
                }else {
                    return BaseMusicKey.init(frame: item, midiNoteNumber: 1, isMainKey: false)
                    
                }
                
            }()
            

            
            musicKey.title = DataStandard.MusicKeysTitle[index]
            self.pitchToKeyDict[DataStandard.root - UInt8(-DataStandard.MusicKeysRulesA[index] + VariousSetFunc.highWhiteNote.rawValue)] = musicKey
            self.musicKeysArray.append(musicKey)
            
            index += 1
        }
        
        VariousSetFunc.setMusicKeysEverySection(self.musicKeysArray,
                                                stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
                                                musicKeyNotes: DataStandard.MusicKeysRulesA)
        
    }// funcEnd
    
    /// 添加键 -> Void
    private func addMusicKey() -> Void {
        for key in musicKeysArray {
//            key.removeFromSuperview()
            addSubview(key)
        }
        

        
    }// funcEnd
    
}

// MARK: - MusicKey SetUp
extension MusicKeyBoard {
    func turnKeyOn(midiNoteNumber: UInt8) {
        let musicKey = getKeyFromMidiNote(midiNoteNumber: midiNoteNumber)
        _ = musicKey?.pressed()
    }
    
    func turnKeyOff(midiNoteNumber: UInt8) {
        let musicKey = getKeyFromMidiNote(midiNoteNumber: midiNoteNumber)
        _ = musicKey?.released()
    }
    
    func turnAllKeysOff() {
        musicKeysArray.forEach { _ = $0.released() }
    }
    
    private func getKeyFromMidiNote(midiNoteNumber: UInt8) -> BaseMusicKey? {
        if pitchToKeyDict.keys.contains(midiNoteNumber) {
            return pitchToKeyDict[midiNoteNumber]
            
        }else {
            let key: UInt8  = Array(pitchToKeyDict.keys).last!
            return pitchToKeyDict[key]
            
        }

    }
    
    
    
}

// MARK: - Judge MusicKey && Override Touch Methods
extension MusicKeyBoard {
    /// 判断哪个键被点击 (返回可能为空)
    private func getKeyFromLocation(loc: CGPoint) -> BaseMusicKey? {
        var selection: BaseMusicKey?
        for key in musicKeysArray {
            if key.frame.contains(loc) {
                selection = key
            }
        }
        
        return selection
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let key = getKeyFromLocation(loc: touch.location(in: self)) {
                delegate?.startTranscribe()
                
                pressAdded(newKey: key)
                verifyTouches(touches: event?.allTouches ?? Set<UITouch>())
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
//            if !self.frame.contains(touch.location(in: self)) {
//                verifyTouches(touches: event?.allTouches ?? Set<UITouch>())
//            } else {
//
//
//            }
            if let key = getKeyFromLocation(loc: touch.location(in: self)),
                key != getKeyFromLocation(loc: touch.previousLocation(in: self)) {
                pressAdded(newKey: key)
                verifyTouches(touches: event?.allTouches ?? Set<UITouch>())
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let key = getKeyFromLocation(loc: touch.location(in: self)) {
                
                // verify that there isn't another finger pressed to same key
                if var allTouches = event?.allTouches {
                    allTouches.remove(touch)
                    let noteSet = getNoteSetFromTouches(touches: allTouches)
                    if !noteSet.contains(key.midiNoteNumber) {
                        pressRemoved(key: key)
                    }
                }
            }
        }
        
        let allTouches = event?.allTouches ?? Set<UITouch>()
        verifyTouches(touches: allTouches)
        
//        if let noteEvent = NoteEvent.getNoteEventFromTmpNoteArray(self.pressedTmpNote) {
//            self.noteEventModelList.append(noteEvent)
//        }
        if self.pressedTmpNote.count != 0 {
            for tmpNote in self.pressedTmpNote {
                let noteEvent = NoteEvent.getNoteEventFromTmpNote(tmpNote)
                if noteEvent.startTime != noteEvent.endTime {
                    self.noteEventModelList.append(noteEvent)
                }
            }
        }
        
        self.pressedTmpNote = []
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        let allTouches = event?.allTouches ?? Set<UITouch>()
        verifyTouches(touches: allTouches)
        
    }
    
    private func pressAdded(newKey: BaseMusicKey) {
        if newKey.pressed() {
            
            /// 开始记录单个音
            self.pressedTmpNote.append(TmpNote.init(newKey.midiNoteNumber, pressedTime: MusicTimer.getpresentTime()))
            
            delegate?.noteOn(note: newKey.midiNoteNumber)
            pressedMusicKeys.insert(newKey.midiNoteNumber)
        }
    }
    
    private func pressRemoved(key: BaseMusicKey) {
        if key.released() {
            // 根据音音阶为Key 遍历查找最后一个并设定抬起时间
            var index = 0
            var indexRecord = 0
            
            for tmpNote in self.pressedTmpNote {
                if tmpNote.midiNoteNumber == key.midiNoteNumber {
                    indexRecord = index
                }
                
                index += 1
            }
            
            
            let tmpNote: TmpNote = {
                if indexRecord != 0 {
                    return self.pressedTmpNote[indexRecord]
                    
                }else {
                    return self.pressedTmpNote[index - 1]
                    
                }
            }()
            
            
            
            tmpNote.unPressedTime = MusicTimer.getpresentTime()
            printWithMessage("音阶\(tmpNote.midiNoteNumber!)按下时间\(tmpNote.pressedTime!)抬起时间\(tmpNote.unPressedTime!)")
            delegate?.noteOff(note: key.midiNoteNumber)
            pressedMusicKeys.remove(key.midiNoteNumber)
        }
    }
    
    private func getNoteSetFromTouches(touches: Set<UITouch>) -> Set<UInt8> {
        var touchedKeys = Set<UInt8>()
        for touch in touches {
            if let key = getKeyFromLocation(loc: touch.location(in: self)) {
                touchedKeys.insert(key.midiNoteNumber)
            }
        }
        return touchedKeys
    }
    
    private func verifyTouches(touches: Set<UITouch>) {
        let notesFromTouches = getNoteSetFromTouches(touches: touches)
        let disjunct = pressedMusicKeys.subtracting(notesFromTouches)
        if !disjunct.isEmpty {
            print("stuck notes: \(disjunct) touches at\(notesFromTouches)")
            for note in disjunct {
                pressRemoved(key: getKeyFromMidiNote(midiNoteNumber: note)!)
            }
        }
    }

}


protocol MusicKeyDelegate: class {
    func noteOn(note: UInt8)
    func noteOff(note: UInt8)
    func startTranscribe()
}
