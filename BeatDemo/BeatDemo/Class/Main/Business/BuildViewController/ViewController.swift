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
    @IBOutlet var operationViewWidth: NSLayoutConstraint!
    @IBOutlet var operationViewHeight: NSLayoutConstraint!
    @IBOutlet var beatViewWidth: NSLayoutConstraint!
    @IBOutlet var beatViewHeight: NSLayoutConstraint!
    
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
    
    @IBOutlet var keyBoardView: MusicKeyBoard!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var playButtonTitleLabel: UILabel!
    
    var sampler:AVAudioUnitSampler!
    var engine: AVAudioEngine!
    
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
        operationViewWidth.constant = FrameStandard.universalWidth
        operationViewHeight.constant = FrameStandard.universalHeight
        beatViewWidth.constant = FrameStandard.universalWidth
        beatViewHeight.constant = FrameStandard.beatViewHeight
        
        navigationItem.leftBarButtonItem = deleteItem
        navigationItem.rightBarButtonItem = allMusicItem
        
        playButton.tintColor = UIColor.black
        playButton.addTarget(self, action: #selector(playButtonEvent), for: .touchUpInside)
    }// funcEnd
    
    /// 设置Data
    func setData() -> Void {
        keyBoardView.delegate = self
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

    }// funcEnd
    
    /// 删除音乐点击事件
    @objc func deleteMusicEvent() -> Void {
        printWithMessage("删除当前")
    }// funcEnd
    
    /// 音乐管理点击事件
    @objc func allMusicEvent() -> Void {
        printWithMessage("音乐管理")
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
            playButtonTitleLabel.text = "播放"
            
            switch MusicTimer.timerState {
            case .initState:
                return
                
            case .timing:
                MusicTimer.causeTimer()
                
            case .caused:
                return
            }
            
        }else {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.cause.rawValue), for: .normal)
            playButtonTitleLabel.text = "暂停"
            
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
    
    
    @IBAction func testPlayMusic(_ sender: Any) {
        let basicSequencer = BasicSequencer.init()
        basicSequencer.SetNoteEventSeq(noteEventSeq: self.keyBoardView.noteEventModelList)
        basicSequencer.playMidi(from: 8)
        
    }
}

extension ViewController: MusicKeyDelegate {
    func startTranscribe() {
        if self.musicState == .played {
            if MusicTimer.shared == nil {
                MusicTimer.createOneTimer {
                    SVProgressHUD.showSuccess(withStatus: "已经成功录制")
                    self.musicState = .played
                }
                
                MusicTimer.startTiming()
            }
        }
    }
    
    func noteOn(note: UInt8) {
        sampler.startNote(note, withVelocity: 120, onChannel: 0)
    }
    
    func noteOff(note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
    
}

