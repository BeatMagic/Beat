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
    var fmOscillator = AKFMOscillatorBank()
    var melodicSound: AKMIDINode!
    var verb: AKReverb2!
    
    var bassDrum = AKSynthKick()
    var snareDrum = AKSynthSnare()
    var snareGhost = AKSynthSnare(duration: 0.06, resonance: 0.3)
    var snareMixer = AKMixer()
    var snareVerb: AKReverb!
    
    var sequencer = AKSequencer()
    var mixer = AKMixer()
    var pumper: AKCompressor!
    
    var currentTempo = 110.0 {
        didSet {
            sequencer.setTempo(currentTempo)
        }
    }
    
    let scale1: [Int] = [0, 2, 4, 7, 9]
    let scale2: [Int] = [0, 3, 5, 7, 10]
    
    var noteEventSeq : [NoteEvent]!
    let sequenceLength = AKDuration(beats: 4.0)
    
    override init() {
        fmOscillator.modulatingMultiplier = 3
        fmOscillator.modulationIndex = 0.3
        
        melodicSound = AKMIDINode(node: fmOscillator)
        verb = AKReverb2(melodicSound)
        verb.dryWetMix = 0.5
        verb.decayTimeAt0Hz = 7
        verb.decayTimeAtNyquist = 11
        verb.randomizeReflections = 600
        verb.gain = 1
        
        [snareDrum, snareGhost] >>> snareMixer
        
        snareVerb = AKReverb(snareMixer)
        
        pumper = AKCompressor(mixer)
        
        pumper.headRoom = 0.10
        pumper.threshold = -15
        pumper.masterGain = 10
        pumper.attackTime = 0.01
        pumper.releaseTime = 0.3
        
        [verb, bassDrum, snareDrum, snareGhost, snareVerb] >>> mixer
        
        AudioKit.output = pumper
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        super.init()
    }
    
    func SetNoteEventSeq(noteEventSeq:[NoteEvent]){
        self.noteEventSeq = noteEventSeq
        
        generateRecordSeq()
    }
    
    func setupTracks() {
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[Sequence.melody.rawValue].setMIDIOutput(melodicSound.midiIn)
        generateNewMelodicSequence(minor: false)
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.bassDrum.rawValue].setMIDIOutput(bassDrum.midiIn)
        generateBassDrumSequence()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.snareDrum.rawValue].setMIDIOutput(snareDrum.midiIn)
        generateSnareDrumSequence()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.snareGhost.rawValue].setMIDIOutput(snareGhost.midiIn)
        generateSnareDrumGhostSequence()
        
        sequencer.enableLooping()
        sequencer.setTempo(100)
        sequencer.play()
    }
    
    func setupMelodyTrack(){
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[Sequence.melody.rawValue].setMIDIOutput(melodicSound.midiIn)
    }
    
    func playMelody(){
        
        if !sequencer.isPlaying{
            sequencer.rewind()
            sequencer.setTempo(100)
            sequencer.play()
        }else{
            sequencer.stop()
        }
    }
    
    func generateNewMelodicSequence(_ stepSize: Float = 1 / 8, minor: Bool = false, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.melody.rawValue].clear() }
        sequencer.setLength(sequenceLength)
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        //print("steps in sequence: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 12 {
                let step = Double(i) * stepSize
                //print("step is \(step)")
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
                sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(noteToAdd),
                                                               velocity: 100,
                                                               position: AKDuration(beats: step),
                                                               duration: AKDuration(beats: 1))
            }
        }
        sequencer.setLength(sequenceLength)
    }
    
    func generateBassDrumSequence(_ stepSize: Float = 1, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.bassDrum.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        for i in 0 ..< numberOfSteps {
            let step = Double(i) * stepSize
            
            sequencer.tracks[Sequence.bassDrum.rawValue].add(noteNumber: 60,
                                                             velocity: 100,
                                                             position: AKDuration(beats: step),
                                                             duration: AKDuration(beats: 1))
        }
    }
    
    func generateSnareDrumSequence(_ stepSize: Float = 1, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.snareDrum.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        
        for i in stride(from: 1, to: numberOfSteps, by: 2) {
            let step = (Double(i) * stepSize)
            sequencer.tracks[Sequence.snareDrum.rawValue].add(noteNumber: 60,
                                                              velocity: 80,
                                                              position: AKDuration(beats: step),
                                                              duration: AKDuration(beats: 1))
        }
    }
    
    func generateSnareDrumGhostSequence(_ stepSize: Float = 1 / 8, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.snareGhost.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        //print("steps in sequnce: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 14 {
                let step = Double(i) * stepSize
                sequencer.tracks[Sequence.snareGhost.rawValue].add(noteNumber: 60,
                                                                   velocity: MIDIVelocity(arc4random_uniform(65) + 1),
                                                                   position: AKDuration(beats: step),
                                                                   duration: AKDuration(beats: 0.1))
            }
        }
        sequencer.setLength(sequenceLength)
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }
    
    func generateSequence() {
        //        generateNewMelodicSequence(minor: randomBool())
        //        generateBassDrumSequence()
        //        generateSnareDrumSequence()
        //        generateSnareDrumGhostSequence()
        generateRecordSeq()
    }
    
    func clear(_ typeOfSequence: Sequence) {
        sequencer.tracks[typeOfSequence.rawValue].clear()
    }
    
    func generateRecordSeq(clear: Bool = true){
        if clear { sequencer.tracks[Sequence.melody.rawValue].clear() }
        sequencer.setLength(sequenceLength)
        for noteEvent in noteEventSeq{
            let velocity: UInt8 = 95
            let channel:UInt8 = 1
            //速度给的是每小节4拍的速度，我们量化是用16分音符，所以这里要有个转换
            var beats = Double(noteEvent.endbeat - noteEvent.startBeat)/4.0
            let duration = AKDuration(beats: beats)
            beats = Double(noteEvent.startBeat)/4.0
            let position = AKDuration(beats: beats)
            sequencer.tracks[Sequence.melody.rawValue].add(noteNumber:noteEvent.startNoteNumber,velocity:velocity,position:position, duration:duration, channel:channel)
            
        }
        sequencer.setLength(sequenceLength)
    }
    
    
    
    
    
    
    
}
