//
//  BasicSequencer.swift
//  BeatDemo
//
//  Created by apple on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

class BasicSequencer: NSObject{
    
    var sequencer = AKSequencer()
    
    //用于规则生成存放midi
    var bgmSequencer = AKSequencer()
    
    //bgmSampler
    var paino1Sampler = AKMIDISampler()
    
    var fluteSampler = AKMIDISampler()
    
    var midiSampler = AKMIDISampler()
    var mixer = AKMixer()
    var currentTempo = 110.0 {
        didSet {
            sequencer.setTempo(currentTempo)
        }
    }
    
    var noteEventSeq : [NoteEvent]!
    let sequenceLength = AKDuration(beats: 36.0)
    
    let bgmSeqLength = AKDuration(beats:8.0)
    
    override init() {
        
        
        try! midiSampler.loadMelodicSoundFont("GeneralUser", preset: 5)
        
        //bgm 音色
        try! paino1Sampler.loadMelodicSoundFont("GeneralUser", preset: 3)
        
        try! fluteSampler.loadMelodicSoundFont("GeneralUser", preset: 8)
        
        
        [midiSampler,paino1Sampler,fluteSampler] >>> mixer
        
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        super.init()
    }
    
    
    func GetSampler() -> AKAppleSampler{
        return self.midiSampler
    }
    
    func SetNoteEventSeq(noteEventSeq:[NoteEvent]){
        self.noteEventSeq = noteEventSeq
        
        sequencer.stop()
        generateRecordSeq()
    }
    
    
    func setupMelodyTrack(){
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[0].setMIDIOutput(midiSampler.midiIn)
        sequencer.setTempo(currentTempo)
        
        //test
        //setupBgmTracks()
    }
    
    func setupBgmTracks(){
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.paino1.rawValue].setMIDIOutput(paino1Sampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
        generateNewMelodicSequence()
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.paino2.rawValue].setMIDIOutput(fluteSampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.koto.rawValue].setMIDIOutput(fluteSampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.flute.rawValue].setMIDIOutput(fluteSampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.pad.rawValue].setMIDIOutput(fluteSampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
        
        _ = bgmSequencer.newTrack()
        bgmSequencer.setLength(bgmSeqLength)
        bgmSequencer.tracks[Sequence.bass.rawValue].setMIDIOutput(fluteSampler.midiIn)
        bgmSequencer.setTempo(currentTempo)
    }
    
    func playMelody(){
        
        //print("player"+String(sequencer.isPlaying))
        
        //print(String(sequencer.tracks[Sequence.melody.rawValue].isEmpty))
        
        //if !sequencer.isPlaying{
        sequencer.rewind()
        //sequencer.preroll()
        sequencer.play()
        //}else{
        //sequencer.stop()
        //}
        //test
        //bgmSequencer.enableLooping()
        //bgmSequencer.play()
    }
    
    /// 停止播放
    func stopPlayMelody() -> Void {
        sequencer.stop()
    }// funcEnd
    
    func generateNewMelodicSequence(_ stepSize: Float = 1 / 8, minor: Bool = false, clear: Bool = true) {
        let scale1: [Int] = [0, 2, 4, 7, 9]
        let scale2: [Int] = [0, 3, 5, 7, 10]
        
        if clear { bgmSequencer.tracks[Sequence.paino1.rawValue].clear() }
        bgmSequencer.setLength(bgmSeqLength)
        let numberOfSteps = Int(Float(bgmSeqLength.beats) / stepSize)
        print("steps in sequence: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 12 {
                let step = Double(i) * stepSize
                print("step is \(step)")
                let scale = (minor ? scale2 : scale1)
                let scaleOffset = arc4random_uniform(UInt32(scale.count) - 1)
                var octaveOffset = 0
                for _ in 0 ..< 2 {
                    octaveOffset += Int(12 * (((Float(arc4random_uniform(2))) * 2.0) + (-1.0)))
                    octaveOffset = Int(
                        (Float(arc4random_uniform(2))) *
                            (Float(arc4random_uniform(2))) *
                            Float(octaveOffset)
                    )
                }
                //print("octave offset is \(octaveOffset)")
                let noteToAdd = 60 + scale[Int(scaleOffset)] + octaveOffset
                bgmSequencer.tracks[Sequence.paino1.rawValue].add(noteNumber: MIDINoteNumber(noteToAdd),
                                                                  velocity: 100,
                                                                  position: AKDuration(beats: step),
                                                                  duration: AKDuration(beats: 1))
            }
        }
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }
    
    
    func clear(_ typeOfSequence: Sequence) {
        sequencer.tracks[typeOfSequence.rawValue].clear()
    }
    
    func generateRecordSeq(clear: Bool = true){
        if clear { sequencer.tracks[0].clear() }
        sequencer.setLength(sequenceLength)
        print("generate!!!!")
        var fbPosition = -0.1
        for noteEvent in noteEventSeq{
            //print(String(noteEvent.startBeat)+" set "+String(noteEvent.endbeat))
            let velocity: UInt8 = 95
            let channel:UInt8 = 1
            //速度给的是每小节4拍的速度，我们量化是用16分音符，所以这里要有个转换
            var beats = Double(noteEvent.endbeat - noteEvent.startBeat)/4.0
            //print("realbeate"+String(beats))
            let duration = AKDuration(beats: beats)
            beats = Double(noteEvent.startBeat)/4.0
            if fbPosition<0{
                fbPosition = beats
            }
            beats -= fbPosition
            let position = AKDuration(beats: beats)
            sequencer.tracks[0].add(noteNumber:noteEvent.startNoteNumber,velocity:velocity,position:position, duration:duration, channel:channel)
            
        }
        sequencer.setLength(sequenceLength)
    }
    
    
    
    
    
    
    
}
