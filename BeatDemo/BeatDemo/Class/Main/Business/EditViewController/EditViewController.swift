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

    @IBOutlet var keyBoardViewHeight: NSLayoutConstraint!
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
    
    
    /// 测试播放
    @IBAction func testPlay(_ sender: Any) {
        // 生成pad与钢琴的乐器信息
        let padInstrumentRange = InstrumentRange.init()
        padInstrumentRange.highestMidiNum = 50
        padInstrumentRange.lowestMidiNum = 16
        padInstrumentRange.name = "pad"
        
        let pianoInstrumentRange = InstrumentRange.init()
        pianoInstrumentRange.highestMidiNum = 60
        pianoInstrumentRange.lowestMidiNum = 16
        pianoInstrumentRange.name = "piano"
        
//        var instrumentRangeArray = [padInstrumentRange, pianoInstrumentRange]
        
        // 生成四部和声midi
        let harmonyMessageArray = ArrangingMapFunc.getHarmonyMessageArray("四部和声midi.xml")
        
        // 生成pad与钢琴的四部和声音符数组
        var padNoteEventArray: [NoteEvent] = []
        var pianoNoteEventArray: [NoteEvent] = []
        
        let padSequencer = BasicSequencer()
        let pianoSequencer = BasicSequencer()
        
        
        for beatIndex in 0 ..< 18 {
            
            let harmonyMessage = harmonyMessageArray[beatIndex]
            
            for scale in harmonyMessage.scale {
                
                // 生成pad的音
                let padNoteNumber = ArrangingMapFunc.getMidiNoteFrom(scale, highestMidiNum: padInstrumentRange.highestMidiNum, lowestMidiNum: padInstrumentRange.lowestMidiNum)
                let padNote = NoteEvent.init(startNoteNumber: UInt8(padNoteNumber),
                                             startTime: harmonyMessage.startBeat / 16 * 3,
                                             endTime: harmonyMessage.endBeat / 16 * 3,
                                             passedNotes: nil)
                padNoteEventArray.append(padNote)
                
                // 生成钢琴的音
                let pianoNoteNumber = ArrangingMapFunc.getMidiNoteFrom(scale, highestMidiNum: pianoInstrumentRange.highestMidiNum, lowestMidiNum: pianoInstrumentRange.lowestMidiNum)
                let pianoNote = NoteEvent.init(startNoteNumber: UInt8(pianoNoteNumber),
                                             startTime: harmonyMessage.startBeat / 16 * 3,
                                             endTime: harmonyMessage.endBeat / 16 * 3,
                                             passedNotes: nil)
                pianoNoteEventArray.append(pianoNote)
                
                
            }
            
            
        }
        
        
        
        for index in 0 ..< 18 {
            
            let noteEventIndex = index * 4
            
            
            let padPlayArray = [
                    padNoteEventArray[noteEventIndex],
                    padNoteEventArray[noteEventIndex + 1],
                    padNoteEventArray[noteEventIndex + 2],
                    padNoteEventArray[noteEventIndex + 3],
                ]
            
            let pianoPlayArray = [
                    pianoNoteEventArray[noteEventIndex],
                    pianoNoteEventArray[noteEventIndex + 1],
                    pianoNoteEventArray[noteEventIndex + 2],
                    pianoNoteEventArray[noteEventIndex + 3],
                ]
            
            let playDelayTime = padNoteEventArray[noteEventIndex].startBeat / DataStandard.oneBeatWithTime
            
            
            DelayTask.createTaskWith(workItem: {
                
                padSequencer.SetNoteEventSeq(noteEventSeq: padPlayArray)
                padSequencer.SetPlayTimbre(timbre: 89)
                padSequencer.playMelody()
                
                pianoSequencer.SetNoteEventSeq(noteEventSeq: pianoPlayArray)
                pianoSequencer.SetPlayTimbre(timbre: 0)
                pianoSequencer.playMelody()
                
            }, delayTime: playDelayTime)
            
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
        let keyBoardHeight: CGFloat = {
            if ToolClass.getIPhoneType() == "iPhone X" {
                return ToolClass.getScreenHeight() - 88 - 100 - 8 - 8 - 60 - 34
                
            }else {
                return ToolClass.getScreenHeight() - 64 - 100 - 8 - 8 - 60
                
            }
            
        }()
        
        self.keyBoardViewHeight.constant = keyBoardHeight
        
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

