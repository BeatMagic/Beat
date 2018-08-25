//
//  ProgressButtonManager.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/25.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import ButtonProgressBar_iOS

class ProgressButtonManager: NSObject {
    
    /// 按钮数组
    static var buttonArray: [ButtonProgressBar] = []
    
    /// 当前时间
    static var presentTime = MusicTimer.getpresentTime() {
        didSet {
            /// 更新按钮index
            ProgressButtonManager.presentButtonIndex = ProgressButtonManager.getPresentButtonIndex(presentTime)
            
            /// 刷新按钮状态
            ProgressButtonManager.resetProgress()
        }
    }
    
    /// 当前按钮index
    private static var presentButtonIndex: Int = 0
    

}
// MARK: - 公共方法
extension ProgressButtonManager {
    /// 返回设置的按钮数组
    static func getButtonsArray(clickButtonEvent: Selector, superView: UIView) -> Void {
        let viewModelArray = ProgressButtonManager.createButtonsViewModelArray(
            buttonWidth: 40,
            buttonHeight: 50
        )
        
        ProgressButtonManager.buttonArray = ProgressButtonManager.createButtonsArray(viewModelArray: viewModelArray, clickButtonEvent: clickButtonEvent, superView: superView)
        
    }// funcEnd
    
    /// 返回当前按钮index
    static func getPresentButtonIndex() -> Int {
        return presentButtonIndex
        
    }// funcEnd
}

// MARK: - 私有方法
extension ProgressButtonManager {
    
    /// 根据当前时间重新绘制
    private static func resetProgress() -> Void {
        
        for index in 0 ..< ProgressButtonManager.presentButtonIndex {
            buttonArray[index].setProgress(progress: 1, false)
            buttonArray[index].isUserInteractionEnabled  = true
            
        }
        
        if ProgressButtonManager.presentButtonIndex < 9 {
            let progress = (ProgressButtonManager.presentTime - Double.init(ProgressButtonManager.presentButtonIndex * 3))  / 3
            
            buttonArray[ProgressButtonManager.presentButtonIndex].isUserInteractionEnabled  = true
            buttonArray[ProgressButtonManager.presentButtonIndex].setProgress(progress: CGFloat(progress), false)
        }
        
    }// funcEnd
    
    /// 获取当前按钮
    private static func getPresentButtonIndex(_ presentTime: Double) -> Int {
        let presentTimeInt = Int.init(presentTime)
        
        return (presentTimeInt - presentTimeInt % 3) / 3
    }
    
    /// 生成9个Button的ViewModelArray
    private static func createButtonsViewModelArray(buttonWidth: CGFloat,
                                     buttonHeight: CGFloat) -> [CGRect] {
        var viewModelArray: [CGRect] = []
        
        let baseButtonPadding: CGFloat = 3
        let baseButtonX = (ToolClass.getScreenWidth() - buttonWidth * 9 - baseButtonPadding * 8) / 2
        let baseButtonY = (100 - buttonHeight) / 2
        
        for index in 0 ..< 9 {
            let buttonCGRect = CGRect.init(
                x: baseButtonX + CGFloat.init(index) * (buttonWidth + baseButtonPadding),
                y: baseButtonY,
                width: buttonWidth,
                height: buttonHeight
            )
            
            viewModelArray.append(buttonCGRect)
        }
        
        return viewModelArray
    }// funcEnd
    
    /// 根据ViewModelArray生成ButtonsArray
    private static func createButtonsArray(viewModelArray: [CGRect], clickButtonEvent: Selector, superView: UIView) -> [ButtonProgressBar] {
        var buttonsArray: [ButtonProgressBar] = []
        
        var index = 0
        for viewModel in viewModelArray {
            let buttonProgressBar = ButtonProgressBar.init(frame: viewModel)
            buttonProgressBar.setTitle("\(index)", for: .normal)
            buttonProgressBar.setBackgroundColor(color: UIColor.flatGreen.withAlphaComponent(0.25))
            buttonProgressBar.setProgressColor(color: UIColor.flatGreen)
            buttonProgressBar.isUserInteractionEnabled = false
            buttonProgressBar.tag = index
            buttonProgressBar.addTarget(nil, action: clickButtonEvent, for: .touchUpInside)
            superView.addSubview(buttonProgressBar)
            
            buttonsArray.append(buttonProgressBar)
            index += 1
        }
        
        return buttonsArray
    }// funcEnd
    
}
