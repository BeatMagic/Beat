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
    @IBOutlet var keyBoardViewHeight: NSLayoutConstraint!
    
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
        let button = createButton(EnumStandard.ImageName.edit.rawValue, tintColor: UIColor.black, action: #selector(editButtonEvent))
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
    @IBOutlet var editButton: UIButton!
    
    // MARK: - 其他
    /// 循环次数
    var circleNum: Int = 0

    // 选择了哪一小节
    var selectedSection: Int? = nil

    // 上一小节最后一个音结束时间
    var previousSectionLastNoteEndTime: Double = -1
    
    var sampler: AKAppleSampler!
    
    let basicSequencer = BasicSequencer()
    
    let localMusicPlayer: AVAudioPlayer = {
        let messageDict = DataStandard.MusicFileMessage["Build"]
        let pathStr = Bundle.main.path(forResource: messageDict!["fileName"] as? String, ofType: nil)
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
//        operationViewWidth.constant = FrameStandard.universalWidth
//        operationViewHeight.constant = FrameStandard.universalHeight
//        beatViewWidth.constant = FrameStandard.universalWidth
//        beatViewHeight.constant = FrameStandard.beatViewHeight
        
        // 导航栏按钮
        navigationItem.leftBarButtonItem = deleteItem
        navigationItem.rightBarButtonItem = allMusicItem
        
        // 进度条
        ProgressButtonManager.getButtonsArray(clickButtonEvent: #selector(sectionButtonEvent), superView: progressBackgroundView)
        ProgressButtonManager.getImagesArray(superView: progressBackgroundView)
        
        // KeyBoard
//        self.keyBoardView.frame =
        
        let keyBoardHeight: CGFloat = {
            if ToolClass.getIPhoneType() == "iPhone X" {
                return ToolClass.getScreenHeight() - 88 - 100 - 8 - 8 - 60
                
            }else {
                return ToolClass.getScreenHeight() - 64 - 100 - 8 - 8 - 60
                
            }
            
        }()
        
        self.keyBoardViewHeight.constant = keyBoardHeight
        
        self.keyBoardView.musicKeysViewModel = {
            if ToolClass.getIPhoneType() == "iPhone X" {
                return self.keyBoardView.initMusicKeyFrame(ownHeight: keyBoardHeight + 88)
                
            }else {
                return self.keyBoardView.initMusicKeyFrame(ownHeight: keyBoardHeight)
                
            }
            
        }()
        
        // 底部按钮
        resetButton.addTarget(self, action: #selector(resetMusicEvent), for: .touchUpInside)
        resetButton.isHidden = true
        
        playButton.tintColor = UIColor.black
        playButton.addTarget(self, action: #selector(playButtonEvent), for: .touchUpInside)
        
        editButton.addTarget(self, action: #selector(editButtonEvent), for: .touchUpInside)
        editButton.isHidden = true
        
    }// funcEnd
    
    /// 设置Data
    func setData() -> Void {
        keyBoardView.delegate = self
        MusicTimer.delegate = self
        MusicTimer.setPresentSectionIndex(0)
        
        sampler = basicSequencer.GetSampler()
        basicSequencer.setupMelodyTrack()
        
        

    }// funcEnd
    
    /// 删除音乐点击事件
    @objc func deleteMusicEvent() -> Void {
        
        let alertController = SimpleAlertController.getSimpleAlertController(title: "删除所有小节输入的音符?", message: nil) {
            // 暂停播放与录制
            self.musicState = .caused
            
            MusicTimer.recycleAndCreateTimer(0)
            
            ProgressButtonManager.hasNotesArray = [false, false, false, false, false, false, false, false, false, ]
            
            // 重置播放器时间条
            self.localMusicPlayer.currentTime = 0
            
            ProgressButtonManager.resetAllPresentButtonProgress()
            
            self.circleNum = 0
            
            VariousOperateFunc.setMusicKeysEverySection(
                self.keyBoardView.musicKeysArray,
                musicKeyNotes: DataStandard.MusicKeysRulesA,
                stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[0],
                stableKeysNextRulesArray: DataStandard.MusicStabileKeysIndexArray[1]
            )
            
            self.keyBoardView.noteEventModelList = []
            
            self.keyBoardView.sectionArray = []
            for index in 0 ..< 9 {
                let sectionModel = Section.init(startTime: Double(index * 3),
                                                endTime: Double((index + 1) * 3),
                                                passNoteEventArray: nil,
                                                delayTime: nil)
                
                self.keyBoardView.sectionArray.append(sectionModel)
            }
            
            SVProgressHUD.showSuccess(withStatus: "删除成功")
        }
        
        self.present(alertController, animated: true, completion: nil)
        

    }// funcEnd
    
    /// 音乐管理点击事件
    @objc func allMusicEvent() -> Void {
    }// funcEnd

    /// 小节点击事件
    @objc func sectionButtonEvent(_ sender: Any) -> Void {
//        SVProgressHUD.showSuccess(withStatus: "已选择第\((sender as! UIButton).tag)小节")
        
        
        self.selectedSection = (sender as! UIButton).tag
        self.musicState = .caused
        MusicTimer.setPresentSectionIndex(self.selectedSection!)
        self.doInSection()

    }// funcEnd
    
    /// 重置音乐点击事件
    @objc func resetMusicEvent() -> Void {
        
        if let selectedSection = self.selectedSection {
            
            
            let alertController = SimpleAlertController.getSimpleAlertController(title: "重置第\(selectedSection)小节?", message: "第\(selectedSection)小节的音符会被清空") {
                
                MusicTimer.setPresentSectionIndex(selectedSection)
                
                self.keyBoardView.sectionArray[selectedSection].passNoteEventArray = []
                
                SVProgressHUD.showSuccess(withStatus: "重置成功")
            }
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }else {
            let alertController = SimpleAlertController.getSimpleAlertController(title: "重置当前小节?", message: "当前小节的音符会被清空") {
                
                let presentSection = MusicTimer.getPresentSectionIndex()
                MusicTimer.setPresentSectionIndex(presentSection)
                self.keyBoardView.sectionArray[presentSection].passNoteEventArray = []
                
                SVProgressHUD.showSuccess(withStatus: "重置成功")
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
    }// funcEnd
    
    /// 播放按钮点击事件
    @objc func playButtonEvent() -> Void {
        
        
        if musicState == .caused {
            musicState = .played
            
        } else {
            
            MusicTimer.setPresentSectionIndex(MusicTimer.getPresentSectionIndex())
            musicState = .caused
        }
    }// funcEnd
    
    /// 编辑按钮点击事件
    @objc func editButtonEvent() -> Void {
        self.musicState = .caused
        
        let editViewController = UIViewController.initVControllerFromStoryboard("EditViewController") as! EditViewController
        
        let tmpArray = self.keyBoardView.noteEventModelList
        
        editViewController.noteEventArray = tmpArray
        
        let editNaviViewController = UINavigationController.init(rootViewController: editViewController)
        
        editNaviViewController.modalTransitionStyle = .flipHorizontal
        
        self.present(editNaviViewController, animated: true, completion: nil)
        
        
    }
    
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
            
            self.basicSequencer.stopPlayMelody()
            DelayTask.cancelAllWorkItems()
            Section.getSectionModel(noteEventArray: self.keyBoardView.noteEventModelList, tmpSectionModelArray: self.keyBoardView.sectionArray)
            
        }else if state == .played  {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.cause.rawValue), for: .normal)
            
            if MusicTimer.shared == nil {
                MusicTimer.createOneTimer {
                    SVProgressHUD.showSuccess(withStatus: "已经成功录制")
                    self.musicState = .played
                    self.musicState = .caused

                }

                MusicTimer.startTiming()
                
            }else {
                let section = MusicTimer.getPresentSectionIndex()
                MusicTimer.recycleAndCreateTimer(section)
                
            }
            
            if self.selectedSection == nil {
                self.selectedSection  = MusicTimer.getPresentSectionIndex()
                self.playMusic(selectedSection!)
                
                localMusicPlayer.currentTime = TimeInterval.init(selectedSection! * 3)
                localMusicPlayer.play()
                
                MusicTimer.carryOnMoment = Date().timeIntervalSince1970
                MusicTimer.startPlaySectionIndex = selectedSection!
                self.selectedSection = nil
                
            }else {
                localMusicPlayer.currentTime = TimeInterval.init(selectedSection! * 3)
                localMusicPlayer.play()
                self.playMusic(selectedSection!)
                
                
                MusicTimer.carryOnMoment = Date().timeIntervalSince1970
                MusicTimer.startPlaySectionIndex = self.selectedSection!
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
        
        for sectionIndex in fromSectionIndex ..< 9 {
            // 获得播放的小节Model
            let sectionModel = self.keyBoardView.sectionArray[sectionIndex]
            
            var playDelayTime: Double = 0
            
            // 小节Model里有音
            if sectionModel.passNoteEventArray.count != 0 {

                playDelayTime = sectionModel.passNoteEventArray.first!.startBeat / DataStandard.oneBeatWithTime
                
                DelayTask.createTaskWith(workItem: {
                    
                    self.basicSequencer.SetNoteEventSeq(noteEventSeq: sectionModel.passNoteEventArray)
                    self.basicSequencer.playMelody()
                    
                }, delayTime: playDelayTime - fromSectionIndex * 3)
                
            }
            
        }
    
    }// funcEnd
    
    /// 更新进度UI
    func updateProgessUI() -> Void {
        
        let presentSectionIndex = MusicTimer.getPresentSectionIndex()
        
        for index in 0 ... presentSectionIndex  {
            
            let sectionModel = self.keyBoardView.sectionArray[index]
            if ProgressButtonManager.hasNotesArray[index] == false {
                
                for note in self.keyBoardView.noteEventModelList {
                    
                    if note.startBeat >= sectionModel.startBeat && note.startBeat < sectionModel.endbeat {
                        ProgressButtonManager.hasNotesArray[index] = true
                        break
                        
                    }else if note.endbeat >= sectionModel.startBeat && note.endbeat < sectionModel.endbeat {
                        ProgressButtonManager.hasNotesArray[index] = true
                        break
                        
                    }else if note.startBeat <= sectionModel.startBeat && note.endbeat >= sectionModel.endbeat {
                        ProgressButtonManager.hasNotesArray[index] = true
                        break
                        
                    }
                }
            }
        }
    }// funcEnd
    
    /// 在小节处
    func doInSection() -> Void {
        let presentSectionIndex = MusicTimer.getPresentSectionIndex()
        
        // 变调
        if presentSectionIndex >= 4 {
            if presentSectionIndex == 8 {
                VariousOperateFunc.setMusicKeysEverySection(
                    self.keyBoardView.musicKeysArray,
                    musicKeyNotes: DataStandard.MusicKeysRulesB,
                    stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex],
                    stableKeysNextRulesArray: nil
                )
                
            }else {
                VariousOperateFunc.setMusicKeysEverySection(
                    self.keyBoardView.musicKeysArray,
                    musicKeyNotes: DataStandard.MusicKeysRulesB,
                    stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex],
                    stableKeysNextRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex + 1]
                )
                
            }
            
        }else {
            VariousOperateFunc.setMusicKeysEverySection(
                self.keyBoardView.musicKeysArray,
                musicKeyNotes: DataStandard.MusicKeysRulesA,
                stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex],
                stableKeysNextRulesArray: DataStandard.MusicStabileKeysIndexArray[presentSectionIndex + 1]
            )
            
        }
        
        
        // 更新是否有音的UI
        self.updateProgessUI()
    }
    
    /// 在结尾处
    func doInEnd() -> Void {
        self.keyBoardView.pressRemovedLastNote()
        self.selectedSection = 0
        self.musicState = .caused
        self.musicState = .played
        VariousOperateFunc.setMusicKeysEverySection(
            self.keyBoardView.musicKeysArray,
            musicKeyNotes: DataStandard.MusicKeysRulesB,
            stableKeysRulesArray: DataStandard.MusicStabileKeysIndexArray[8],
            stableKeysNextRulesArray: nil
        )
        self.updateProgessUI()
        
    }// funcEnd
}

extension ViewController: MusicKeyDelegate {
    func judgeShouldRecord() -> Bool {
        if self.musicState == .caused {
            return false
            
        }else {
            return true
            
        }
    }
    
    
    
    func startTranscribe() {
        self.circleNum = 0
    }
    
    func noteOn(note: UInt8) {
        self.basicSequencer.SetPlayVolume(volume: 0)
        try! self.sampler.play(noteNumber: note, velocity: 95, channel: 1)
    }
    
    func noteOff(note: UInt8) {
        try! self.sampler.stop(noteNumber: note, channel: 1)
        self.basicSequencer.SetPlayVolume(volume: 1)
    }
    
}

extension ViewController: TimerDelegate {
    func doThingsWhenTiming() {
        
        self.doInSection()
        
    }
    
    func doThingsWhenEnd() {
        
        self.doInEnd()
        ProgressButtonManager.resetAllPresentButtonProgress()
        
    }
    
}


