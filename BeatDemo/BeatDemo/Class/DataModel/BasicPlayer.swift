//
//  BasicPlayer.swift
//  BeatDemo
//
//  Created by apple on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

class BasicPlayer: NSObject {
    let chordFile = try! AKAudioFile(readFileName: "chord.mp3")
    
    
    func Play(currentTime:Double){
        let chordPlayer = AKPlayer(audioFile: chordFile)
        AudioKit.output = chordPlayer
        try! AudioKit.start()
        
        chordPlayer.isLooping = true
        chordPlayer.play(from: currentTime)
        
    }
}
