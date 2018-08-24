//
//  BasicSequencer.swift
//  BeatDemo
//
//  Created by apple on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

class BasicSequencer: NSObject {
    let oscBank = AKOscillatorBank()
    let sequencer = AKSequencer()
    let midi = AKMIDI()
    let sequenceLength = AKDuration(beats: 20)
    
    var noteEventSeq : [NoteEvent]!
    
    func SetNoteEventSeq(noteEventSeq:[NoteEvent]){
        self.noteEventSeq = noteEventSeq
    }
    
    func setupSynth() {
        oscBank.attackDuration=0.1
        oscBank.decayDuration=0.1
        oscBank.sustainLevel=0.1
        oscBank.releaseDuration=0.3
    }
    
    
    
    func generateSequence(){
        
        for noteEvent in noteEventSeq{
            let velocity: UInt8 = 95
            let channel:UInt8 = 1
            //速度给的是每小节4拍的速度，我们量化是用16分音符，所以这里要有个转换
            var beats = Double(noteEvent.endbeat - noteEvent.startBeat)/4.0
            let duration = AKDuration(beats: beats)
            beats = Double(noteEvent.startBeat)/4.0
            let position = AKDuration(beats: beats)
            sequencer.tracks[0].add(noteNumber:noteEvent.startNoteNumber,velocity:velocity,position:position, duration:duration, channel:channel)
            
        }
        
    }
    
    func playMidi(from:UInt8){
        let midiNode = AKMIDINode(node: oscBank)
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        
        generateSequence()
        
        AudioKit.output = midiNode
        try! AudioKit.start()
        midiNode.enableMIDI(midi.client, name: "midiNode midi in")
        sequencer.setTempo(80.0)
        
        var beats = Double(from)/4
        //sequencer.currentPosition = AKDuration(beats: beats)
        sequencer.play()
    }
    
}
