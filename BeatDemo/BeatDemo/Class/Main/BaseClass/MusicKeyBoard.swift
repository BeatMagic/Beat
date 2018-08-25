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
    /// 最低音阶
    var lowestWhiteNote: EnumStandard.ScaleNotes = EnumStandard.ScaleNotes.G {
        didSet {
            setUp()
        }
    }
    
    /// 最高音阶
    var highWhiteNote: EnumStandard.ScaleNotes = EnumStandard.ScaleNotes.D {
        didSet {
            setUp()
        }
    }
    
    /// 主音位置
    var mainMusicKeyIndex = 8{
        didSet {
            setUp()
        }
    }
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
        
        let queueGroup = DispatchGroup.init()
        DispatchQueue.main.async(group: queueGroup, execute: {
            self.musicKeysViewModel = self.initMusicKeyFrame(ownHeight: frame.height)
        })
        
        queueGroup.notify(queue: DispatchQueue.main) {
            self.setUp()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let queueGroup = DispatchGroup.init()
        DispatchQueue.main.async(group: queueGroup, execute: {
            self.musicKeysViewModel = self.initMusicKeyFrame(ownHeight: self.getHeight())
        })
        
        queueGroup.notify(queue: DispatchQueue.main) {
            self.setUp()
        }
    }
    
}

// MARK: - SetUp
extension MusicKeyBoard {
    
    /// 封装所有键盘设定
    func setUp() -> Void {
        isMultipleTouchEnabled = true
        addMusicKeysWithViewModel(musicKeysViewModel)
        addMusicKey()
    }
    
    override func layoutSubviews() {
        addMusicKeysWithViewModel(musicKeysViewModel)
        addMusicKey()
    }
    
    override func draw(_ rect: CGRect) {
        addMusicKeysWithViewModel(musicKeysViewModel)
        addMusicKey()
    }
    
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
    private func addMusicKeysWithViewModel(_ viewModel: [CGRect]) -> Void {
        // 先清空
        for key in musicKeysArray {
            key.removeFromSuperview()
        }
        musicKeysArray = [BaseMusicKey]()

        var index = 0
        var absoluteNum = highWhiteNote.rawValue
        for item in viewModel {
            var midiNote: UInt8
            
            if absoluteNum < 0 {
                midiNote = DataStandard.root - UInt8(-absoluteNum)
                
            }else {
                midiNote = DataStandard.root + UInt8(absoluteNum)
            }
            
            let musicKey: BaseMusicKey = {
                if index == mainMusicKeyIndex {
                    return BaseMusicKey.init(frame: item, midiNoteNumber: midiNote, isMainKey: true)
                }else {
                    return BaseMusicKey.init(frame: item, midiNoteNumber: midiNote, isMainKey: false)
                }
            }()
            
            musicKeysArray.append(musicKey)
            pitchToKeyDict[midiNote] = musicKey
            absoluteNum -= 1
            index += 1
        }
        
    }// funcEnd
    
    /// 添加键 -> Void
    private func addMusicKey() -> Void {
        for key in musicKeysArray {
            key.removeFromSuperview()
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
        return pitchToKeyDict[midiNoteNumber]
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
                self.noteEventModelList.append(noteEvent)
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
            printWithMessage("按下\(newKey.midiNoteNumber!)")
            
            
            
            printWithMessage("处理后\(newKey.midiNoteNumber!)\(newKey.keyState)")
        }
    }
    
    private func pressRemoved(key: BaseMusicKey) {
        if key.released() {
            /// 根据音音阶为Key 遍历查找并设定抬起时间
            for tmpNote in self.pressedTmpNote {
                if tmpNote.midiNoteNumber == key.midiNoteNumber {
                    tmpNote.unPressedTime = MusicTimer.getpresentTime()
                }
            }
            
            delegate?.noteOff(note: key.midiNoteNumber)
            pressedMusicKeys.remove(key.midiNoteNumber)
            printWithMessage("松开\(key.midiNoteNumber!)")
            
            printWithMessage("处理后\(key.midiNoteNumber!)\(key.keyState)")
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
