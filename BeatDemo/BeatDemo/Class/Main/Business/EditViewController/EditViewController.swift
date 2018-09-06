//
//  EditViewController.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import ChameleonFramework
import AudioKitUI
import SVProgressHUD

class EditViewController: UIViewController {
    
    @IBOutlet var operationViewWidth: NSLayoutConstraint!
    @IBOutlet var operationViewHeight: NSLayoutConstraint!
    @IBOutlet var beatViewWidth: NSLayoutConstraint!
    @IBOutlet var beatViewHeight: NSLayoutConstraint!

    /// 关闭ButtonItem
    lazy private var closeItem: UIBarButtonItem = {
        let button = createButton(EnumStandard.ImageName.close.rawValue, tintColor: UIColor.black, action: #selector(closeEvent))
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true

        return UIBarButtonItem.init(customView: button)
    }()
    
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var keyBoardView: MusicKeyBoard!
    @IBOutlet var playButton: UIButton!
    
    // MARK: - 数据
    var noteEventArray : [NoteEvent] = []


    
    // MARK: - 其他
    /// 循环次数
    var circleNum: Int = 0
    
    
    /// 下一个需要记录的时间节点
    var nextNeedRecordTime: Double = 3
    var sampler: AKAppleSampler!
    let basicSequencer = BasicSequencer()
    

    
    var localMusicPlayer: AVAudioPlayer? {
        didSet {
            if let player = localMusicPlayer {
                player.prepareToPlay()
                player.numberOfLoops = -1
            }
        }
    }

    /// 暂停按钮点击次数
    var clickPauseTime: Int = 0

    
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

extension EditViewController {
    
    /// 设置UI && 绑定点击事件
    func setUI() -> Void {
        operationViewWidth.constant = FrameStandard.universalWidth
        operationViewHeight.constant = FrameStandard.universalHeight
        beatViewWidth.constant = FrameStandard.universalWidth
        beatViewHeight.constant = FrameStandard.beatViewHeight
        
        navigationItem.leftBarButtonItem = closeItem
        
        prevButton.isHidden = true
        prevButton.addTarget(self, action: #selector(prevEvent), for: .touchUpInside)
        playButton.tintColor = UIColor.black
        playButton.addTarget(self, action: #selector(playButtonEvent), for: .touchUpInside)
    }// funcEnd
    
    /// 设置Data
    func setData() -> Void {
        keyBoardView.delegate = self
        
        sampler = basicSequencer.GetSampler()
        basicSequencer.setupMelodyTrack()
        self.basicSequencer.SetNotesAndMakeMelody(noteEventSeq: self.noteEventArray)
        
        var messageDict: Dictionary<String, Any> = Dictionary<String, Any>()
        
        switch self.clickPauseTime % 2 {
            
        case 1:
            messageDict = DataStandard.MusicFileMessage["Edit_Normal"]!
            
        case 0:
            messageDict = DataStandard.MusicFileMessage["Edit_Rock"]!
            
        default:
            print("???")
        }
        
        self.localMusicPlayer = VariousOperateFunc.initOnePlayer(messageDict["fileName"] as! String)
        
        VariousOperateFunc.playMIDI(
            totalDelayTime: Double.init(messageDict["delayTime"] as! Int),
            basicSequencer: self.basicSequencer)
        
    }// funcEnd
    
    /// 关闭按钮点击事件
    @objc func closeEvent() -> Void {
        navigationController?.dismiss(animated: true, completion: nil)
        
    }// funcEnd
    
    /// 上一曲点击事件
    @objc func prevEvent() -> Void {
        
        
    }// funcEnd
    
    
    /// 播放按钮点击事件
    @objc func playButtonEvent() -> Void {
        if musicState == .caused {
            musicState = .played
            
        } else {
            musicState = .caused
            
        }
        

    }// funcEnd
    
    
    /// 设置当前按钮信息 ( 音乐当前状态 )
    func setUpButtonMessageWithState(_ state: EnumStandard.MusicPlayStates) -> Void {
        if state == .caused {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.play.rawValue), for: .normal)
            
            localMusicPlayer!.pause()
            localMusicPlayer!.currentTime = 0
            
            self.basicSequencer.stopPlayMelody()
            DelayTask.cancelAllWorkItems()
            
        }else {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.prevSong.rawValue), for: .normal)
            
            self.clickPauseTime += 1
            
            var messageDict: Dictionary<String, Any> = Dictionary<String, Any>()
            
            switch self.clickPauseTime % 2 {
                
            case 1:
                messageDict = DataStandard.MusicFileMessage["Edit_Normal"]!
                
            case 0:
                messageDict = DataStandard.MusicFileMessage["Edit_Rock"]!
                
            default:
                print("???")
            }
            
            self.localMusicPlayer = VariousOperateFunc.initOnePlayer(messageDict["fileName"] as! String)
            
            localMusicPlayer!.play()
            
            VariousOperateFunc.playMIDI(
                totalDelayTime: Double.init(messageDict["delayTime"] as! Int),
                basicSequencer: self.basicSequencer)
            
            
        }
    }// funcEnd
    
    /// 返回音乐点击事件
    @objc func backEvent() -> Void {
        navigationController?.popViewController(animated: true)
    }// funcEnd
    
}

extension EditViewController: MusicKeyDelegate {
    func judgeShouldRecord() -> Bool {
        return false
    }
    
    
    func startTranscribe() {
        
    }
    
    func noteOn(note: UInt8) {
        try! self.sampler.play(noteNumber: note, velocity: 95, channel: 1)
    }
    
    func noteOff(note: UInt8) {
        try! self.sampler.stop(noteNumber: note, channel: 1)
    }
    
}

