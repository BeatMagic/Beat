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
    
    //用于即时播放用户输入的sampler
    var inputSampler = AKMIDISampler()
    //bgmSampler
    var paino1Sampler = AKMIDISampler()
    
    var fluteSampler = AKMIDISampler()
    
    var midiSampler = AKMIDISampler()
    
    var mixer = AKMixer()
    var midiCompresser : AKCompressor
    var reverb : AKReverb?
    var reverbMixer : AKDryWetMixer?
    var delay : AKDelay?
    var delayMixer : AKDryWetMixer?
    var booster : AKBooster?
    var currentTempo = 80.0
    
    var noteEventSeq : [NoteEvent]!
    let sequenceLength = AKDuration(beats: 76.0)
    
    //4 乘以小节数量
    let bgmSeqLength = AKDuration(beats:8.0)
    
    let standerand = 128
    let measureCount = 9
    
    let diviation: Double!
    
    
    override init() {
        
        diviation = standerand/4.0
        
        try! inputSampler.loadMelodicSoundFont("GeneralUser", preset: 40)
        
        try! midiSampler.loadMelodicSoundFont("GeneralUser", preset: 40)
        midiCompresser = AKCompressor(midiSampler)
        
        
        
        //bgm 音色
        try! paino1Sampler.loadMelodicSoundFont("GeneralUser", preset: 60)
        
        try! fluteSampler.loadMelodicSoundFont("GeneralUser", preset: 8)
        
        
        [inputSampler,midiCompresser,paino1Sampler,fluteSampler] >>> mixer
        
        reverb = AKReverb(mixer)
        reverbMixer = AKDryWetMixer(mixer, reverb)
        
        delay = AKDelay(reverb)
        delay?.time = 0.1
        delayMixer = AKDryWetMixer(reverb,delay)
        
        booster = AKBooster(delayMixer)
        booster?.gain = 3
        
        AudioKit.output = booster
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        super.init()
    }
    
    func SetPlayVolume(volume:Double)
    {
        var vol = volume
        if volume<0{
            vol = 0
        }
        if volume>1.0{
            vol = 1.0
        }
        midiSampler.volume = vol
    }
    
    func GetSampler() -> AKAppleSampler{
        return self.inputSampler
    }
    
    func SetNoteEventSeq(noteEventSeq:[NoteEvent],preroll: Bool = true){
        self.noteEventSeq = noteEventSeq
        
        sequencer.stop()
        generateRecordSeq(preroll: preroll)
    }
    
    func SetNotesAndMakeMelody(noteEventSeq:[NoteEvent])
    {
        if noteEventSeq.count == 0 {
            return
        }
        
        
        //let startDelay = noteEventSeq[0].startBeat
        let addBeat = standerand*(measureCount - 1)
        self.noteEventSeq = noteEventSeq
        
        var indexList:[Int] = []
        for index in 0 ..< noteEventSeq.count
        {
            indexList.append(index)
        }
        indexList = shuffle(toShuffle: indexList)
        //print(indexList)
        
        for index in 0 ..< noteEventSeq.count
        {
            let nt = noteEventSeq[index]
            
            let newNt = NoteEvent.init(startNoteNumber: nt.startNoteNumber, startTime: 0.0, endTime: 0.0, passedNotes: nil)
            newNt.startBeat = nt.startBeat+addBeat
            newNt.endbeat = nt.endbeat+addBeat
            if newNt.endbeat <= 12+addBeat{
                continue
            }
            
            //更改稳定音
            let count = indexList.count/3
            for j in 0 ..< count{
                if index == indexList[j]{
                    let steadymidis = DataStandard.getMeasureSteadyMidi(nt.belongToSection)
                    var diff:Int32 = 128
                    for midi in steadymidis{
                        let newDiff = abs(Int32(newNt.startNoteNumber) - Int32(midi))
                        if newDiff<diff && midi != newNt.startNoteNumber{
                            newNt.startNoteNumber = midi
                            diff = newDiff
                        }
                    }
                }
            }
            
            self.noteEventSeq.append(newNt)
        }
        //加一小节主音 68
        
        //去掉重叠的音
        
        var toRemove:[Int] = []
        
        for index in 0 ..< self.noteEventSeq.count-1 {
            let nt = self.noteEventSeq[index]
            
            let _nt = self.noteEventSeq[index+1]
            if nt.startBeat >= _nt.startBeat
            {
                toRemove.append(index)
            }
            else if nt.endbeat>=_nt.startBeat{
                nt.endbeat = _nt.startBeat
            }
        }
        
        for i in toRemove{
            self.noteEventSeq.remove(at: i)
        }
        
        
        let mainNt =  NoteEvent.init(startNoteNumber: 57, startTime: 0.0, endTime: 0.0, passedNotes: nil)
        mainNt.startBeat = standerand*(measureCount*2-1)
        mainNt.endbeat = mainNt.startBeat+standerand
        self.noteEventSeq.append(mainNt)
        
        sequencer.stop()
        generateRecordSeq(preroll: false)
    }
    
    func setupMelodyTrack(){
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[0].setMIDIOutput(midiSampler.midiIn)
        
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
        print(sequencer.tempo)
        print(sequencer.rate)
        sequencer.play()
        //}else{
        //sequencer.stop()
        //}
        //test
        //        if !bgmSequencer.isPlaying{
        //            bgmSequencer.enableLooping()
        //            bgmSequencer.play()
        //        }
        
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
    
    func generateRecordSeq(preroll: Bool = true, clear: Bool = true){
        if clear { sequencer.tracks[0].clear() }
        sequencer.setLength(sequenceLength)
        print("generate!!!!")
        var fbPosition = -0.1
        for noteEvent in noteEventSeq{
            //print(String(noteEvent.startBeat)+" set "+String(noteEvent.endbeat))
            let velocity: UInt8 = 95
            let channel:UInt8 = 1
            //速度给的是每小节4拍的速度，我们量化是用16分音符，所以这里要有个转换
            var beats = Double(noteEvent.endbeat - noteEvent.startBeat)/diviation
            //print("realbeate"+String(beats))
            let duration = AKDuration(beats: beats)
            beats = Double(noteEvent.startBeat)/diviation
            if fbPosition<0{
                fbPosition = beats
            }
            if preroll{
                beats -= fbPosition
            }
            let position = AKDuration(beats: beats)
            sequencer.tracks[0].add(noteNumber:noteEvent.startNoteNumber,velocity:velocity,position:position, duration:duration, channel:channel)
            
        }
        sequencer.setLength(sequenceLength)
        sequencer.setTempo(80.0)
    }
    
    
    
    
}
