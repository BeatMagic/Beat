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
    private static var presentTime: Double = 0
    
    
    /// 初始化
    static func createOneTimer(_ actionClosures: @escaping (() -> Void)) -> Void {
        MusicTimer.actionClosures = actionClosures
        MusicTimer.presentTime = 0
        MusicTimer.timerState = .initState
        
        var timer: DispatchSourceTimer? = DispatchSource.makeTimerSource()
        timer!.schedule(deadline: DispatchTime.now(),
                        repeating: 0.01,
                        leeway: DispatchTimeInterval.seconds(0))
        
        timer!.setEventHandler(handler: {
            if MusicTimer.presentTime >= MusicTimer.totalTime {
                timer!.cancel()
                timer = nil
                MusicTimer.shared = nil
                MusicTimer.actionClosures!()
                MusicTimer.actionClosures = nil
                
            } else {
                DispatchQueue.main.async {
                    MusicTimer.presentTime += 0.01
                }
            }
        })
        
        MusicTimer.shared = timer
        
    }// funcEnd
    
    /// 开启计时器
    static func startTiming() -> Void {
        if let timer = MusicTimer.shared {
            timer.resume()
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
}