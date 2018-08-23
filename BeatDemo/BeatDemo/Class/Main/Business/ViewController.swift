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
    
    @IBOutlet var keyBoardView: MusicKeyBoard!
    
    var sampler:AVAudioUnitSampler!
    var engine: AVAudioEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController {
    
    /// 设置UI
    func setUI() -> Void {
        operationViewWidth.constant = FrameStandard.universalWidth
        operationViewHeight.constant = FrameStandard.universalHeight
        beatViewWidth.constant = FrameStandard.universalWidth
        beatViewHeight.constant = FrameStandard.beatViewHeight
        
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
}

extension ViewController: MusicKeyDelegate {
    func noteOn(note: UInt8) {
        sampler.startNote(note, withVelocity: 120, onChannel: 0)
    }
    
    func noteOff(note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
    
}

