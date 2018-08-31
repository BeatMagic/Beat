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
    
    //MARK:- 重要数据
    /// 上一个按下的音
    var lastPressedTmpNote: TmpNote? = nil
    /// 音阶数组
    var noteEventModelList: [NoteEvent] = []
    /// 小节模型
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
            self.musicKeysArray.append(musicKey)
            
            index += 1
        }
        
        VariousOperateFunc.setMusicKeysEverySection(
            self.musicKeysArray,
            stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
            musicKeyNotes: DataStandard.MusicKeysRulesA )
        
    }// funcEnd
    
    /// 添加键 -> Void
    private func addMusicKey() -> Void {
        for key in musicKeysArray {
            //            key.removeFromSuperview()
            addSubview(key)
        }
        
    }// funcEnd
    
}

// MARK: - Judge MusicKey && Press/PressRemoved && Data
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
    
    /// 按下一个键
    private func pressAdded(newKey: BaseMusicKey) {
        self.pressRemovedLastNote()
        
        self.lastPressedTmpNote = TmpNote.init(newKey.midiNoteNumber, pressedTime: MusicTimer.getpresentTime())
        
        // 开始播放
        self.delegate?.noteOn(note: newKey.midiNoteNumber)
    }
    
    /// 抬起上一个键的封装
    private func pressRemovedLastNote() -> Void {

        
        // 临时音为空直接返回
        if self.lastPressedTmpNote == nil {
            return
            
        }
        
        if self.lastPressedTmpNote!.unPressedTime != 0 { // 最后一个音有抬起时间点直接返回
            return
            
        }else { // 最后一个音没有抬起时间点
            self.lastPressedTmpNote!.unPressedTime = MusicTimer.getpresentTime()
            
            // 临时音转换为音阶并储存到音阶数组
            let note = NoteEvent.init(startNoteNumber: self.lastPressedTmpNote!.midiNoteNumber, startTime: self.lastPressedTmpNote!.pressedTime, endTime: self.lastPressedTmpNote!.unPressedTime, passedNotes: nil)
            printWithMessage("音阶\(note.startNoteNumber!)开始时间\(note.startTime!)结束时间\(note.endTime!)")
            self.addNoteEvent(noteEvent: note)
            
            // 停止播放
            self.delegate?.noteOff(note:  self.lastPressedTmpNote!.midiNoteNumber)
            // 重置最后一个音为空
            self.lastPressedTmpNote = nil
            
        }
        
    }
    
    /// 添加音
    private func addNoteEvent(noteEvent:NoteEvent) {
        
        var newNoteEventList : [NoteEvent] = []
        
        for note in noteEventModelList{
            
            if noteEvent.startBeat==note.startBeat||(noteEvent.endbeat>note.startBeat&&noteEvent.endbeat<=note.endbeat){
                continue
            }else if noteEvent.startBeat>note.startBeat && noteEvent.startBeat<note.endbeat{
                note.endbeat = noteEvent.startBeat
            }
            newNoteEventList.append(note)
        }
        newNoteEventList.append(noteEvent)
        
        noteEventModelList = newNoteEventList
        noteEventModelList.sort { (a, b) -> Bool in
            return a.startBeat<b.startBeat
        }
        
    }
    
    
}

// MARK: - Override Touch Methods
extension MusicKeyBoard {

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 { // 只按了一处
            let touch = touches.first
            if let key = self.getKeyFromLocation(loc: touch!.location(in: self)) {
                self.pressAdded(newKey: key)
                
            }
            
        }else if touches.count > 1 { // 多点触控
            
            for touch in touches {
                if let key = self.getKeyFromLocation(loc: touch.location(in: self)) {
                    self.pressAdded(newKey: key)
                    
                }else {
                    self.pressRemovedLastNote()
                    
                }
                
            }
            
            
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            if let key = self.getKeyFromLocation(loc: touch.location(in: self)) {

                // 如果是第一次点击
                if self.lastPressedTmpNote == nil {
                    self.pressAdded(newKey: key)
                    
                // 如果不是第一次点击
                }else {
                    // 点击其他按钮的情况
                    if key.midiNoteNumber != self.lastPressedTmpNote!.midiNoteNumber {
                        self.pressAdded(newKey: key)
                        
                    }
                    
                }

            }else {
                self.pressRemovedLastNote()
                
            }
            
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.pressRemovedLastNote()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.pressRemovedLastNote()

    }
    
}


protocol MusicKeyDelegate: class {
    func noteOn(note: UInt8)
    func noteOff(note: UInt8)
    func startTranscribe()
}
