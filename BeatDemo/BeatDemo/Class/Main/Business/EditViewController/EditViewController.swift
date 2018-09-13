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
import SwiftyXMLParser

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
//        编曲图谱修改版0.2.xml
        
//        let string = "编曲图谱修改版"
//        let stringHead = ToolClass.cutStringWithPlaces(string, startPlace: string.count - 1, endPlace: string.count)
        
        self.playBGMFromArrangingMapFrom("编曲图谱修改版0.2.xml")
        
        
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
            self.basicSequencer.bgmSequencer.stop()
            DelayTask.cancelAllWorkItems()
            
        }else {
            playButton.setBackgroundImage(UIImage.init(named: EnumStandard.ImageName.prevSong.rawValue), for: .normal)
            
            self.clickPauseTime += 1
            
            var messageDict: Dictionary<String, Any> = Dictionary<String, Any>()
            var delayTime: Double = 0
            
            switch self.clickPauseTime % 4 {
                
            case 4:
                self.playBGMFromArrangingMapFrom("编曲图谱修改版0.2.xml")
                delayTime = 0
                
            case 3:
                self.playMidiAccompaniment()
                delayTime = 0

                
            case 2:
                messageDict = DataStandard.MusicFileMessage["Edit_Rock"]!
                self.playLocalAccompaniment(messageDict)
                delayTime = Double.init(messageDict["delayTime"] as! Int)
                
            case 1:
                messageDict = DataStandard.MusicFileMessage["Edit_Normal"]!
                self.playLocalAccompaniment(messageDict)
                delayTime = Double.init(messageDict["delayTime"] as! Int)
                
                
            default:
                print("???")
            }
            
            
            VariousOperateFunc.playMIDI(
                totalDelayTime: delayTime,
                basicSequencer: self.basicSequencer)
            
        }
    }// funcEnd
    
    /// 返回音乐点击事件
    @objc func backEvent() -> Void {
        navigationController?.popViewController(animated: true)
    }// funcEnd
    
}


extension EditViewController {
    /// 根据文件信息数组播放本地伴奏文件
    func playLocalAccompaniment(_ messageDict: Dictionary<String, Any>) -> Void {
        
        self.localMusicPlayer = VariousOperateFunc.initOnePlayer(messageDict["fileName"] as! String)
        self.localMusicPlayer!.play()
        
    }// funcEnd
    
    
    /// 播放Midi伴奏文件
    func playMidiAccompaniment() -> Void {
        // 生成四部和声midi
        let harmonyMessageArray = ArrangingMapFunc.getHarmonyMessageArray("四部和声midi.xml")
        
        let model = ReferenceTrackMessage.init()
        model.harmonyMessageArray = harmonyMessageArray
        
        // 没什么变化的pad
        let padFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(harmonyMessageArray, instrumentRangeModel: StaticConfigurationModel.padInstrumentRange)

        // 钢琴
        let pianoFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(harmonyMessageArray, instrumentRangeModel: StaticConfigurationModel.pianoInstrumentRange)
        
        let tmpPianoArray = [
            "fjz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "jz",
            "pad",
            ]
        
        let pianoSecondNoteArray = StaticConfigurationModel.getPainoNoteArray(pianoFirstNoteArray, model: model, painoSectionStructureArray: tmpPianoArray)
        
        // 贝斯
        let bassFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(
            harmonyMessageArray,
            instrumentRangeModel: StaticConfigurationModel.bassInstrumentRange
        )
        
        let tmpBassArray = [
            "",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            "f",
            " ",
            ]
        
        
        
        let bassSecondNoteArray: [NoteEvent] = StaticConfigurationModel.getBassNoteArray(bassFirstNoteArray, model: model, bassSectionStructureArray: tmpBassArray)
        
        
        
        let tmpDragArray = [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "zy",
            "zy",
            "zy",
            "zyf",
            "zy",
            "zy",
            "zyf",
            "zyf",
            "zyf",
            ]
        
        let dragNoteArray = StaticConfigurationModel.getNoiseDrummNoteArray(tmpModelArray: tmpDragArray)
        
        self.basicSequencer.setupBgmTracks()
        
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.pad.rawValue, noteEventSeq: padFirstNoteArray)
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.paino1.rawValue, noteEventSeq: pianoSecondNoteArray)
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.bass.rawValue, noteEventSeq: bassSecondNoteArray)
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.drum.rawValue, noteEventSeq: dragNoteArray)
        
        self.basicSequencer.playBGM()
    }// funcEnd
    

    /// 根据任意XML编曲图谱文件的文件名字生成BGM
    func playBGMFromArrangingMapFrom(_ fileName: String) -> Void {
        var arrangingMapDict = ArrangingMapFunc.getArrangingMapDictFrom(fileName)
        // 音域字典
        var instrumentRangeDict: [String: InstrumentRange] = [String: InstrumentRange]()
        // 音符数组字典
        var instrumentNoteEventDict: [String: [NoteEvent]] =  [String: [NoteEvent]]()
        
        for key in arrangingMapDict.keys {
            let array = arrangingMapDict[key]
            
            switch key {
                
            // 算出具有音域的乐器音域
            case EnumStandard.XMLFileKey.Pad.rawValue,
                 EnumStandard.XMLFileKey.Piano.rawValue,
                 EnumStandard.XMLFileKey.Bass.rawValue:
                
                let lowestNoteString = array![1]
                let highestNoteString = array![2]
                
                let instrumentRange = InstrumentRange.init()
                instrumentRange.name = key
                instrumentRange.lowestMidiNum = ArrangingMapFunc.getMidiNoteFromString(lowestNoteString)
                instrumentRange.highestMidiNum = ArrangingMapFunc.getMidiNoteFromString(highestNoteString)
                    
                instrumentRangeDict[key] = instrumentRange

                
            default:
                print("暂时用不到")
            }
            
            // 去除不必要的信息(前三列)
            arrangingMapDict[key]!.removeSubrange(0 ..< 3)
            
        }
        
        // 基础四部和声midi
        let harmonyMessageArray = ArrangingMapFunc.getHarmonyMessageArray("四部和声midi.xml")
        
        let model = ReferenceTrackMessage.init()
        model.harmonyMessageArray = harmonyMessageArray
        
        
        
        
        for key in arrangingMapDict.keys {
            switch key {
                
            case EnumStandard.XMLFileKey.Pad.rawValue:
                let padFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(harmonyMessageArray, instrumentRangeModel: instrumentRangeDict[key]!)
                
                let padSecondNoteArray = StaticConfigurationModel.getPadNoteArray(
                    padFirstNoteArray,
                    padSectionStructureArray: arrangingMapDict[key]!,
                    model: model,
                    instrumentRangeModel: instrumentRangeDict[key]!)
                
                instrumentNoteEventDict[key] = padSecondNoteArray
                
            case EnumStandard.XMLFileKey.Piano.rawValue:
                // 钢琴和声数组
                let pianoHarmonyNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(
                    harmonyMessageArray, instrumentRangeModel: instrumentRangeDict[key]!
                )
                
                // 钢琴复杂节奏层数组
                let pianoComplexNoteArray = StaticConfigurationModel.getPainoNoteArray(
                    pianoHarmonyNoteArray,
                    model: model,
                    painoSectionStructureArray: arrangingMapDict[key]!
                )
                
                instrumentNoteEventDict[key] = pianoComplexNoteArray
                
                
            case EnumStandard.XMLFileKey.Drum.rawValue:
                let drumHarmonyNoteArray = StaticConfigurationModel.getNoiseDrummNoteArray(tmpModelArray: arrangingMapDict[key]!)
                
                instrumentNoteEventDict[key] = drumHarmonyNoteArray
                
            case EnumStandard.XMLFileKey.Bass.rawValue:
                let bassFirstNoteArray = StaticConfigurationModel.getRhythmLayerNoteArray(harmonyMessageArray, instrumentRangeModel: instrumentRangeDict[key]!)
                
                
                let bassSecondNoteArray = StaticConfigurationModel.getBassNoteArray(bassFirstNoteArray, model: model, bassSectionStructureArray: arrangingMapDict[key]!)
                
                instrumentNoteEventDict[key] = bassSecondNoteArray
                
                
            default:
                print("什么都不做")

                
            }
        }
        

        self.basicSequencer.setupBgmTracks()
        
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.pad.rawValue, noteEventSeq: instrumentNoteEventDict[EnumStandard.XMLFileKey.Pad.rawValue]!)
        
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.paino1.rawValue, noteEventSeq: instrumentNoteEventDict[EnumStandard.XMLFileKey.Piano.rawValue]!)
//
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.bass.rawValue, noteEventSeq: instrumentNoteEventDict[EnumStandard.XMLFileKey.Bass.rawValue]!)
//
        self.basicSequencer.SetBgmNoteEventSeq(index: Sequence.drum.rawValue, noteEventSeq: instrumentNoteEventDict[EnumStandard.XMLFileKey.Drum.rawValue]!)
        
        self.basicSequencer.playBGM()
        
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

