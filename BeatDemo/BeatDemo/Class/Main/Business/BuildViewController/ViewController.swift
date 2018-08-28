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
    /// 下一个需要记录的时间节点
    var nextNeedRecordTime: Double = 3

    // 选择了哪一小节
    var selectedSection: Int? = nil

    // 上一小节最后一个音结束时间
    var previousSectionLastNoteEndTime: Double = -1
    
    var sampler:AVAudioUnitSampler!
    var engine: AVAudioEngine!
    
    var oscillatorBank: AKFMOscillatorBank!

    
    let basicSequencer = BasicSequencer()
    
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
        
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try engine.start()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with:
                AVAudioSessionCategoryOptions.mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("set up failed")
            return
        }
        
        basicSequencer.setupMelodyTrack()
        oscillatorBank = basicSequencer.GetOscillatorBank()

    }// funcEnd
    
    /// 删除音乐点击事件
    @objc func deleteMusicEvent() -> Void {
        printWithMessage("删除当前")
    }// funcEnd
    
    /// 音乐管理点击事件
    @objc func allMusicEvent() -> Void {
        printWithMessage("音乐管理")
    }// funcEnd

    /// 小节点击事件
    @objc func sectionButtonEvent(_ sender: Any) -> Void {
        SVProgressHUD.showSuccess(withStatus: "已选择第\((sender as! UIButton).tag)小节")
        self.selectedSection = (sender as! UIButton).tag
        
//        self.playMusic(self.selectedSection!)

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
            
            
            
            switch MusicTimer.timerState {
            case .initState:
                return
                
            case .timing:
                return
                
            case .caused:
                MusicTimer.startTiming()
            }
            
            if let selectedSection = self.selectedSection {
                
                MusicTimer.setPresentTime(selectedSection * 3)
                self.playMusic(selectedSection)
            }
        }
        
    }// funcEnd
    
    /// 测试播放按钮
    @IBAction func testPlayMusic(_ sender: Any) {
        
        for sectionModelIndex in 0 ..< ProgressButtonManager.getPresentButtonIndex() + 1 {
            let sectionModel = keyBoardView.sectionArray[sectionModelIndex]
            
            DelayTask.createTaskWith(name: "\(sectionModelIndex)", workItem: {
                 printWithMessage("第\(sectionModelIndex)小节开始播放")
                self.basicSequencer.SetNoteEventSeq(noteEventSeq: sectionModel.passNoteEventArray)
                self.basicSequencer.playMelody()
                
            }, delayTime: sectionModelIndex * 3 + sectionModel.delayTime)
        }
    }
    
    /// 从某小节处开始播放
    func playMusic(_ fromSectionIndex: Int) -> Void {
//        let nextSectionIndex = ProgressButtonManager.getPresentButtonIndex() + 1
        
        for sectionIndex in fromSectionIndex ..< 9 {
            // 获得播放的小节Model
            let sectionModel = self.keyBoardView.sectionArray[sectionIndex]
            
            var playDelayTime: Double = 0
            
            // 小节Model里有音
            if sectionModel.isHaveNoteEvent == true {
                
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

    }
    
    func noteOn(note: UInt8) {
        self.basicSequencer.stopPlayMelody()
        oscillatorBank.play(noteNumber: note, velocity: 95)
    }
    
    func noteOff(note: UInt8) {
        oscillatorBank.stop(noteNumber: note)
    }
    
}

extension ViewController: TimerDelegate {
    func doThingsWhenTiming() {
        // 下一小节需要记录的时间节点
        if MusicTimer.getpresentTime() >= nextNeedRecordTime {
            nextNeedRecordTime += 3
            
            let presentSectionIndex = ProgressButtonManager.getPresentButtonIndex()
            let queueGroup = DispatchGroup.init()
            let basicQueue = DispatchQueue(label: "getSectionModel")
            basicQueue.async(group: queueGroup, execute: {
                // 在子线程转换
                Section.getSectionModel(noteEventArray: self.keyBoardView.noteEventModelList, tmpSectionModelArray: self.keyBoardView.sectionArray)
                
            })
            
            queueGroup.notify(queue: basicQueue) {
                self.keyBoardView.noteEventModelList = []
                if self.keyBoardView.sectionArray[presentSectionIndex - 1].isHaveNoteEvent == true {
                    DispatchQueue.main.async {
                        ProgressButtonManager.hasNotesArray[presentSectionIndex - 1] = true
                    }
                }
            }

        }
        
    }
    
    func doThingsWhenEnd() {
        nextNeedRecordTime = 3
        keyBoardView.noteEventModelList = []
        ProgressButtonManager.deleteAllPresentButtonProgress()
    }
    
}

