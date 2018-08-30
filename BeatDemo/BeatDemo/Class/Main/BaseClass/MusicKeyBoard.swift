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
    
    
    /// 主音位置
    var mainMusicKeyIndex = 8
    
    
    /// 音乐键数组
    var musicKeysArray = [BaseMusicKey]()
    /// 位置对应按钮字典
    var pitchToKeyDict = [Int: BaseMusicKey]()

    /// 上一次按下键的位置
    var previousPressedMusicKeysArray: [BaseMusicKey] = []
    
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
    
    /// 上次按下时间的记录
    var prevTime: Double = 0
    
    /// 所有键ViewModel
    var musicKeysViewModel: [CGRect] = [CGRect]()
    /// 外部代理
    weak var delegate: MusicKeyDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isMultipleTouchEnabled = true
        
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
        self.isMultipleTouchEnabled = true
        
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
                    return BaseMusicKey.init(frame: item, midiNoteNumber: 1, keyIndex: index, isMainKey: true)
                    
                }else {
                    return BaseMusicKey.init(frame: item, midiNoteNumber: 1, keyIndex: index, isMainKey: false)
                    
                }
                
            }()
            

            
            musicKey.title = DataStandard.MusicKeysTitle[index]
            self.pitchToKeyDict[index] = musicKey
            self.musicKeysArray.append(musicKey)
            
            index += 1
        }
        
        VariousOperateFunc.setMusicKeysEverySection(self.musicKeysArray,
                                                stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
                                                musicKeyNotes: DataStandard.MusicKeysRulesA)
        
    }// funcEnd
    
    /// 添加键 -> Void
    private func addMusicKey() -> Void {
        for key in musicKeysArray {
            addSubview(key)
        }
        

        
    }// funcEnd
    
}

// MARK: - MusicKey SetUp
extension MusicKeyBoard {
    private func getKeyFromKeyIndex(keyIndex: Int) -> BaseMusicKey? {
        return pitchToKeyDict[keyIndex]
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
                
                // 处理之前按下的键
                if self.previousPressedMusicKeysArray.count != 0 {
                    for key in self.previousPressedMusicKeysArray {
                        pressRemoved(key: key)
                    }
                    
                    self.previousPressedMusicKeysArray = []
                }

                pressAdded(newKey: key)
                printWithMessage("按下\(key.midiNoteNumber)")
                self.previousPressedMusicKeysArray.append(key)
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            
            if let key = getKeyFromLocation(loc: touch.location(in: self)),
                key != getKeyFromLocation(loc: touch.previousLocation(in: self)) {
                
                // 处理之前按下的键
                if self.previousPressedMusicKeysArray.count != 0 {
                    for key in self.previousPressedMusicKeysArray {
                        pressRemoved(key: key)
                    }
                    
                    self.previousPressedMusicKeysArray = []
                }
                
                pressAdded(newKey: key)
                self.previousPressedMusicKeysArray.append(key)
                
            }else if getKeyFromLocation(loc: touch.location(in: self)) == nil {
                // 处理之前按下的键
                if self.previousPressedMusicKeysArray.count != 0 {
                    for key in self.previousPressedMusicKeysArray {
                        pressRemoved(key: key)
                    }
                    
                    self.previousPressedMusicKeysArray = []
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 处理之前按下的键
        if self.previousPressedMusicKeysArray.count != 0 {
            for key in self.previousPressedMusicKeysArray {
                pressRemoved(key: key)
            }
            
            self.previousPressedMusicKeysArray = []
        }
        
        for touch in touches {
            if let key = getKeyFromLocation(loc: touch.location(in: self)) {
                
                pressRemoved(key: key)
                
            }
        }
        
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {

        
    }
    
    private func pressAdded(newKey: BaseMusicKey) {
        
        if newKey.pressed() {
            
            /// 开始记录单个音
            self.pressedTmpNote.append(TmpNote.init(newKey.midiNoteNumber, pressedTime: MusicTimer.getpresentTime()))
            
            delegate?.noteOn(note: newKey.midiNoteNumber)
        }
    }
    
    private func pressRemoved(key: BaseMusicKey) {
        if key.released() {
            
            let tmpNote = TmpNote.init(key.midiNoteNumber, pressedTime: self.prevTime)
            
            tmpNote.unPressedTime = MusicTimer.getpresentTime()
            
            
            
            tmpNote.unPressedTime = MusicTimer.getpresentTime()
            self.prevTime = MusicTimer.getpresentTime()
            
            printWithMessage("音阶\(tmpNote.midiNoteNumber!)按下时间\(tmpNote.pressedTime!)抬起时间\(tmpNote.unPressedTime!)")
            
            
            delegate?.noteOff(note: key.midiNoteNumber)
            
            if let noteEvent = NoteEvent.getNoteEventFromTmpNoteArray([tmpNote]) {
                self.noteEventModelList.append(noteEvent)
            }
            
        
        }
    
            
    }
    
    private func getKeyIndexFromTouches(touches: Set<UITouch>) -> [Int] {

        var touchedKeysIndexArray: [Int] = []

        for touch in touches {
            if let key = getKeyFromLocation(loc: touch.location(in: self)) {

                touchedKeysIndexArray.append(key.keyIndex)
            }
        }
        
        return touchedKeysIndexArray
    }
    

}


protocol MusicKeyDelegate: class {
    func noteOn(note: UInt8)
    func noteOff(note: UInt8)
    func startTranscribe()
}
