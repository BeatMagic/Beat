//
//  ViewController.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import ChameleonFramework
import AudioKitUI
import SVProgressHUD
import AVFoundation

class ViewController: UIViewController {
    // MARK: - 布局
    @IBOutlet var operationViewWidth: NSLayoutConstraint!
    @IBOutlet var operationViewHeight: NSLayoutConstraint!
    @IBOutlet var beatViewWidth: NSLayoutConstraint!
    @IBOutlet var beatViewHeight: NSLayoutConstraint!
    
    // MARK: - 导航栏按钮
    /// 删除ButtonItem
    lazy private var deleteItem: UIBarButtonItem = {
        let button = createButton(EnumStandard.ImageName.delete.rawValue, tintColor: UIColor.flatRed, action: #selector(deleteMusicEvent))
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return UIBarButtonItem.init(customView: button)
    }()
    
    /// 全部音乐ButtonItem
    lazy private var allMusicItem: UIBarButtonItem = {
        let button = createButton(EnumStandard.ImageName.allMusic.rawValue, tintColor: UIColor.black, action: #selector(allMusicEvent))
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return UIBarButtonItem.init(customView: button)
    }()
    
    // MARK: - 进度条相关
    @IBOutlet var progressBackgroundView: UIView!
    
    // MARK: - 键盘View
    @IBOutlet var keyBoardView: MusicKeyBoard!
    
    // MARK: - 底部按钮
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    // MARK: - 其他
    /// 循环次数
    var circleNum: Int = 0

    
    /// 下一个需要记录的时间节点
    var nextNeedRecordTime: Double = 3

    // 选择了哪一小节
    var selectedSection: Int? = nil

    // 上一小节最后一个音结束时间
    var previousSectionLastNoteEndTime: Double = -1
    
    var sampler: AKAppleSampler!
    
    let basicSequencer = BasicSequencer()
    
    let localMusicPlayer: AVAudioPlayer = {
        let pathStr = Bundle.main.path(forResource: "9小节输入伴奏.wav", ofType: nil)
        let player = try! AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: pathStr!))
        player.prepareToPlay()
        player.numberOfLoops = -1

        return player
    }()
    
    
    /// 音乐播放状态
    var musicState: EnumStandard.MusicPlayStates = .caused {
        didSet {
            setUpButtonMessageWithState(musicState)
        }
    }
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        musicState = .caused
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController {
    
    /// 设置UI && 绑定点击事件
    func setUI() -> Void {
        // 布局
        operationViewWidth.constant = FrameStandard.universalWidth
        operationViewHeight.constant = FrameStandard.universalHeight
        beatViewWidth.constant = FrameStandard.universalWidth
        beatViewHeight.constant = FrameStandard.beatViewHeight
        
        // 导航栏按钮
        navigationItem.leftBarButtonItem = deleteItem
        navigationItem.rightBarButtonItem = allMusicItem
        
        // 进度条
        ProgressButtonManager.getButtonsArray(clickButtonEvent: #selector(sectionButtonEvent), superView: progressBackgroundView)
        ProgressButtonManager.getImagesArray(superView: progressBackgroundView)
        
        // 底部按钮
        resetButton.addTarget(self, action: #selector(resetMusicEvent), for: .touchUpInside)
        playButton.tintColor = UIColor.black
        playButton.addTarget(self, action: #selector(playButtonEvent), for: .touchUpInside)
        
        
        
        
    }// funcEnd
    
    /// 设置Data
    func setData() -> Void {
        keyBoardView.delegate = self
        MusicTimer.delegate = self
        
        sampler = basicSequencer.GetSampler()
        basicSequencer.setupMelodyTrack()

    }// funcEnd
    
    /// 删除音乐点击事件
    @objc func deleteMusicEvent() -> Void {
        let alertController = SimpleAlertController.getSimpleAlertController(title: "删除所有小节输入的音符?", message: nil) {
            
            // 取消播放
            DelayTask.cancelAllWorkItems()
            
            // 暂停播放与录制
//            self.setUpButtonMessageWithState(.caused)
            
            // 重置进度条
            MusicTimer.setPresentTime(0)
            ProgressButtonManager.presentTime = 0
            
            // 重置播放器时间条
            self.localMusicPlayer.currentTime = 0
            
            self.nextNeedRecordTime = 3
            
            ProgressButtonManager.resetAllPresentButtonProgress()
            
            self.circleNum = 0
            VariousSetFunc.setMusicKeysEverySection(
                self.keyBoardView.musicKeysArray,
                stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
                musicKeyNotes: DataStandard.MusicKeysRulesA)
            
            self.keyBoardView.noteEventModelList = []
            
            for sectionModel in self.keyBoardView.sectionArray {
                sectionModel.passNoteEventArray = []
            }
            
            
            SVProgressHUD.showSuccess(withStatus: "删除成功")
        }
        
        self.present(alertController, animated: true, completion: nil)
        

    }// funcEnd
    
    /// 音乐管理点击事件
    @objc func allMusicEvent() -> Void {
        printWithMessage("音乐管理")
    }// funcEnd

    /// 小节点击事件
    @objc func sectionButtonEvent(_ sender: Any) -> Void {
        SVProgressHUD.showSuccess(withStatus: "已选择第\((sender as! UIButton).tag)小节")
        self.selectedSection = (sender as! UIButton).tag
        self.musicState = .caused

    }// funcEnd
    
    /// 重置音乐点击事件
    @objc func resetMusicEvent() -> Void {
        
        if let selectedSection = self.selectedSection {
            
            
            let alertController = SimpleAlertController.getSimpleAlertController(title: "重置第\(selectedSection)小节?", message: "第\(selectedSection)小节的音符会被清空") {
                
                MusicTimer.setPresentTime(selectedSection * 3)
                ProgressButtonManager.presentTime = selectedSection * 3
                
                self.keyBoardView.sectionArray[selectedSection].passNoteEventArray = []
                
                SVProgressHUD.showSuccess(withStatus: "重置成功")
            }
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }else {
            let alertController = SimpleAlertController.getSimpleAlertController(title: "重置当前小节?", message: "当前小节的音符会被清空") {
                
                MusicTimer.setPresentTime(ProgressButtonManager.getPresentButtonIndex() * 3)
                ProgressButtonManager.presentTime = ProgressButtonManager.getPresentButtonIndex() * 3
                self.keyBoardView.sectionArray[ProgressButtonManager.getPresentButtonIndex()].passNoteEventArray = []
                
                SVProgressHUD.showSuccess(withStatus: "重置成功")
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
    }// funcEnd
    
    /// 播放按钮点击事件
    @objc func playButtonEvent() -> Void {
        if musicState == .caused {
            musicState = .played
            printWithMessage("开始播放")
            
        } else {
            musicState = .caused
            printWithMessage("播放暂停")
            
        }
    }// funcEnd
    
    /// 设置当前按钮信息 ( 音乐当前状态 )
    func setUpButtonMessageWithState(_ state: EnumStandard.MusicPlayStates) -> Void {

        if state == .caused {
            
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.play.rawValue), for: .normal)
            localMusicPlayer.pause()
            
            switch MusicTimer.timerState {
            case .initState:
                return
                
            case .timing:
                MusicTimer.causeTimer()
                
            case .caused:
                break;
            }
            
            
            let queueGroup = DispatchGroup.init()
            let basicQueue = DispatchQueue(label: "getSectionModel")
            basicQueue.async(group: queueGroup, execute: {
                // 在子线程转换
                Section.getSectionModel(noteEventArray: self.keyBoardView.noteEventModelList, tmpSectionModelArray: self.keyBoardView.sectionArray)
                
            })
            
            queueGroup.notify(queue: basicQueue) {
                self.keyBoardView.noteEventModelList = []
            }
            
            self.basicSequencer.stopPlayMelody()
            DelayTask.cancelAllWorkItems()
            
        }else if state == .played  {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.cause.rawValue), for: .normal)
            
            
            if MusicTimer.shared == nil {
                MusicTimer.createOneTimer {
                    SVProgressHUD.showSuccess(withStatus: "已经成功录制")
                    self.musicState = .played
                    self.musicState = .caused

                }

                MusicTimer.startTiming()
            }
            
            if self.selectedSection == nil {
                localMusicPlayer.play()
                
            }else {
                localMusicPlayer.currentTime = TimeInterval.init(selectedSection! * 3)
                localMusicPlayer.play()
                
                MusicTimer.setPresentTime(selectedSection! * 3)
                self.playMusic(selectedSection!)
                
                self.selectedSection = nil
            }
            
            switch MusicTimer.timerState {
            case .initState:
                return
                
            case .timing:
                return
                
            case .caused:
                MusicTimer.startTiming()
            }
            

            
        }
        
    }// funcEnd
    
    /// 从某小节处开始播放
    func playMusic(_ fromSectionIndex: Int) -> Void {
//        let nextSectionIndex = ProgressButtonManager.getPresentButtonIndex() + 1
        
        for sectionIndex in fromSectionIndex ..< 9 {
            // 获得播放的小节Model
            let sectionModel = self.keyBoardView.sectionArray[sectionIndex]
            
            var playDelayTime: Double = 0
            
            // 小节Model里有音
            if sectionModel.passNoteEventArray.count != 0 {
                
                playDelayTime = sectionModel.passNoteEventArray.first!.startTime - sectionModel.startTime - sectionModel.delayTime
                
            // 没有音
            }else {
                playDelayTime = 3 - sectionModel.delayTime
                
            }
            
            DelayTask.createTaskWith(name: "第\(sectionIndex)小节", workItem: {
                self.basicSequencer.SetNoteEventSeq(noteEventSeq: sectionModel.passNoteEventArray)
                self.basicSequencer.playMelody()
                
            }, delayTime: (sectionIndex - fromSectionIndex) * 3 + playDelayTime)
            
        }
    
    }// funcEnd
}

extension ViewController: MusicKeyDelegate {
    
    func startTranscribe() {
        self.circleNum = 0
    }
    
    func noteOn(note: UInt8) {
        self.basicSequencer.stopPlayMelody()
        try! self.sampler.play(noteNumber: note, velocity: 95, channel: 1)
    }
    
    func noteOff(note: UInt8) {
        try! self.sampler.stop(noteNumber: note, channel: 1)
    }
    
}

extension ViewController: TimerDelegate {
    func doThingsWhenTiming() {
        // 下一小节需要记录的时间节点
        if MusicTimer.getpresentTime() >= nextNeedRecordTime {
            if self.circleNum == 0 {
                let presentSectionIndex = ProgressButtonManager.getPresentButtonIndex()
                
                nextNeedRecordTime += 3
                
                if self.nextNeedRecordTime >= 18 {
                    VariousSetFunc.setMusicKeysEverySection(
                        self.keyBoardView.musicKeysArray,
                        stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex],
                        musicKeyNotes: DataStandard.MusicKeysRulesA)
                    
                }else {
                    VariousSetFunc.setMusicKeysEverySection(
                        self.keyBoardView.musicKeysArray,
                        stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex],
                        musicKeyNotes: DataStandard.MusicKeysRulesB)
                    
                }
                
                self.keyBoardView.sectionArray[presentSectionIndex - 1].passNoteEventArray = []
                
                let queueGroup = DispatchGroup.init()
                let basicQueue = DispatchQueue(label: "getSectionModel")
                basicQueue.async(group: queueGroup, execute: {
                    // 在子线程转换
                    Section.getSectionModel(noteEventArray: self.keyBoardView.noteEventModelList, tmpSectionModelArray: self.keyBoardView.sectionArray)
                    
                })
                
                queueGroup.notify(queue: basicQueue) {
                    if self.keyBoardView.sectionArray[presentSectionIndex - 1].passNoteEventArray.count != 0 {
                        ProgressButtonManager.hasNotesArray[presentSectionIndex - 1] = true
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    func doThingsWhenEnd() {
        circleNum += 1
        VariousSetFunc.setMusicKeysEverySection(
            self.keyBoardView.musicKeysArray,
            stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
            musicKeyNotes: DataStandard.MusicKeysRulesA)
        
        nextNeedRecordTime = 3
        keyBoardView.noteEventModelList = []
        ProgressButtonManager.deleteAllPresentButtonProgress()

        
        DelayTask.cancelAllWorkItems()
        
        self.selectedSection = 0
        localMusicPlayer.currentTime = 0
        
        if self.musicState == .played {
            self.playMusic(0)
        }
        
    }
    
}


