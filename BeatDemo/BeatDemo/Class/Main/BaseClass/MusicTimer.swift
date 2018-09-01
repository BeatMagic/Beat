//
//  MusicTimer.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/24.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class MusicTimer: NSObject {
    static var shared: DispatchSourceTimer? = nil
    /// 目前状态
    static var timerState: EnumStandard.MusicTimerState = .initState
    
    /// Closures 完成后执行的闭包
    static var actionClosures: (() -> Void)? = nil
    
    /// 总时间
    static let totalTime: Int = 27
    
    /// 目前时间的秒数
    private static var presentTime: Int = 0
//    {
//        didSet {
//            // 在当前的小节赋值
//            self.presentSectionIndex = presentTime / 3
//        }
//    }
    
    /// 外部代理
    weak static var delegate: TimerDelegate?
    
    /// 当前小节
    private static var presentSectionIndex: Int = 0 {
        didSet {
            ProgressButtonManager.resetProgress()
        }
    }
    
    /// 播放开始的小节处
    static var startPlaySectionIndex: Int = 0
    
    /// 开始播放时间点
    static var carryOnMoment: Double = 0
    
    
    /// 获取当前小节index
    static func getPresentSectionIndex() -> Int {
        return MusicTimer.presentSectionIndex
        
    }// funcEnd
    
    /// 设置当前小节
    static func setPresentSectionIndex(_ index: Int) -> Void {
        MusicTimer.presentSectionIndex = index
        MusicTimer.presentTime = index * 3
        
    }// funcEnd
    
    /// 获取BGM开始播放到当前的时间
    static func getTimeFromStartPlayBGM() -> Double {
        return Date().timeIntervalSince1970 - self.carryOnMoment + Double.init(startPlaySectionIndex * 3)
    }
    
    
}

extension MusicTimer {
    /// 初始化
    static func createOneTimer(_ actionClosures: @escaping (() -> Void)) -> Void {
        MusicTimer.actionClosures = actionClosures
        MusicTimer.presentTime = 0
        MusicTimer.timerState = .initState
        
        let timer: DispatchSourceTimer? = DispatchSource.makeTimerSource()
        timer!.schedule(deadline: DispatchTime.now(),
                        repeating: 1,
                        leeway: DispatchTimeInterval.seconds(0))
        
        timer!.setEventHandler(handler: {
            
            if MusicTimer.presentTime >= MusicTimer.totalTime {
                
                let queueGroup = DispatchGroup.init()
                DispatchQueue.main.async(group: queueGroup, execute: {
                    MusicTimer.delegate?.doThingsWhenEnd()
                    MusicTimer.setPresentSectionIndex(0)
                })
                
            }else {
                
                DispatchQueue.main.sync {
                    // 临时
                    if MusicTimer.presentTime % 3 == 0 {
                        if MusicTimer.presentTime != 0 {
                            MusicTimer.presentSectionIndex = MusicTimer.presentTime / 3
                        }
                        MusicTimer.delegate!.doThingsWhenTiming()
                      
                    }
                    MusicTimer.presentTime += 1
                }
                
            }

            
        })
        
        MusicTimer.shared = timer

        
    }// funcEnd
    

    /// 开启计时器
    static func startTiming() -> Void {
        if MusicTimer.shared != nil {
            
            MusicTimer.shared!.resume()
            MusicTimer.timerState = .timing
        }
        
        
    }// funcEnd
    
    /// 暂停计时器
    static func causeTimer() -> Void {
        if let timer = MusicTimer.shared {
            timer.suspend()
            MusicTimer.timerState = .caused
        }
        
    }// funcEnd
    
    /// 关闭计时器
    static func closeTimer() -> Void {
        if let timer = MusicTimer.shared {
            MusicTimer.presentTime = 0
            MusicTimer.actionClosures = nil
            
            switch MusicTimer.timerState {
            case .timing:
                timer.cancel()
                MusicTimer.shared = nil
                
            case .caused:
                timer.resume()
                timer.cancel()
                MusicTimer.shared = nil
                
            default:
                return
            }
            MusicTimer.timerState = .initState
        }
        
    }// funcEnd
    
    
    /// 销毁并重新创建计时器
    static func recycleAndCreateTimer(_ nowIndex: Int) -> Void {
        self.closeTimer()
        MusicTimer.createOneTimer {}
        MusicTimer.setPresentSectionIndex(nowIndex)
        MusicTimer.startTiming()
        MusicTimer.causeTimer()
    }
    
    
}

protocol TimerDelegate: class {
    func doThingsWhenTiming()
    func doThingsWhenEnd()
}
