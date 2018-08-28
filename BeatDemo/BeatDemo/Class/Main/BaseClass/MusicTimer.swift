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
    static let totalTime: Double = 27
    
    /// 目前时间
    private static var presentTime: Double = 0 {
        didSet {
            ProgressButtonManager.presentTime = MusicTimer.presentTime
            print("\(MusicTimer.presentTime)秒")
        }
    }
    
    /// 外部代理
    weak static var delegate: TimerDelegate?
    
    
    /// 初始化
    static func createOneTimer(_ actionClosures: @escaping (() -> Void)) -> Void {
        MusicTimer.actionClosures = actionClosures
        MusicTimer.presentTime = 0
        MusicTimer.timerState = .initState
        
        let timer: DispatchSourceTimer? = DispatchSource.makeTimerSource()
        timer!.schedule(deadline: DispatchTime.now(),
                        repeating: 0.01,
                        leeway: DispatchTimeInterval.seconds(0))
        
        timer!.setEventHandler(handler: {
            if MusicTimer.presentTime >= MusicTimer.totalTime {
                
                let queueGroup = DispatchGroup.init()
                DispatchQueue.main.async(group: queueGroup, execute: {
                    MusicTimer.delegate?.doThingsWhenEnd()
                    
                })
                
                queueGroup.notify(queue: DispatchQueue.main, execute: {
                    MusicTimer.presentTime = 0
                })
                
                
                
            } else {
                DispatchQueue.main.async {
                    MusicTimer.presentTime += 0.01
                    MusicTimer.delegate?.doThingsWhenTiming()
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
            MusicTimer.timerState = .initState
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
        }
        
    }// funcEnd
    
    /// 获取当前时间点
    static func getpresentTime() -> Double {
        return MusicTimer.presentTime
        
    }// funcEnd
    
    /// 设置当前时间点
    static func setPresentTime(_ presentTime: Double) -> Void {
        MusicTimer.presentTime = presentTime
        
    }// funcEnd
}

protocol TimerDelegate: class {
    func doThingsWhenTiming()
    func doThingsWhenEnd()
}
