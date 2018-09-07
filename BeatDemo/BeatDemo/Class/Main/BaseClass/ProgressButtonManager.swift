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
    
    /// 图片数组
    static var imageViewArray: [UIImageView] = []
    
    /// 是否有音符数组
    static var hasNotesArray: [Bool] = [
            false, false, false, false, false, false, false, false, false, 
        ] {
        didSet {
            resetFinishedImageViewArray()
        }
    }
    

}
// MARK: - 公共方法
extension ProgressButtonManager {
    /// 返回设置的按钮数组
    static func getButtonsArray(clickButtonEvent: Selector, superView: UIView) -> Void {
        let viewModelArray = ProgressButtonManager.createButtonsViewModelArray(
            buttonWidth: 40 / 375 * ToolClass.getScreenWidth(),
            buttonHeight: 50 / 667 * ToolClass.getScreenHeight()
        )
        
        ProgressButtonManager.buttonArray = ProgressButtonManager.createButtonsArray(viewModelArray: viewModelArray, clickButtonEvent: clickButtonEvent, superView: superView)
        
    }// funcEnd
    
    /// 返回设置的完成指示器
    static func getImagesArray(superView: UIView) -> Void {
        let baseImageWH: CGFloat  = 15
        let baseImageMarginToLeft: CGFloat = (40 - baseImageWH) / 2
        let baseImageMarginToTop: CGFloat  = ((100 - 50) / 3 * 2 - baseImageWH) / 2
        
        
        for index in 0 ..< 9 {
            let bottomButton = ProgressButtonManager.buttonArray[index]
            let imageCGRect = CGRect.init(x: bottomButton.getX() + baseImageMarginToLeft, y: baseImageMarginToTop, width: baseImageWH, height: baseImageWH)
            
            let imageView = UIImageView.init(frame: imageCGRect)
            imageView.image = UIImage.init(named: EnumStandard.ImageName.unfinished.rawValue)
            imageView.tintColor = UIColor.flatGreen
            
            imageViewArray.append(imageView)
            superView.addSubview(imageView)
        }
        
        
        
    }// funcEnd
    
    /// 删除所有图片
    static func deleteAllPresentButtonProgress() -> Void {

        
        for imageView in ProgressButtonManager.imageViewArray {
            imageView.image = UIImage.init(named: EnumStandard.ImageName.unfinished.rawValue)
            imageView.tintColor = UIColor.flatGreen
        }
        
    }// funcEnd
    
    /// 重置所有按钮状态
    static func resetAllPresentButtonProgress() -> Void {
        for button in ProgressButtonManager.buttonArray {
            button.resetProgress()
        }
        
    }// funcEnd
}

// MARK: - 私有方法
extension ProgressButtonManager {
    
    /// 根据当前时间重新绘制进度按钮
    static func resetProgress() -> Void {
        
        for index in 0 ..< 9 {
            if index <= MusicTimer.getPresentSectionIndex() {
                ProgressButtonManager.buttonArray[index].setProgress(progress: 1, true)
                
            }else {
                ProgressButtonManager.buttonArray[index].setProgress(progress: 0, true)
            }
        }
        
    }// funcEnd
    
    ///  根据是否有音符数组重新展示
    private static func resetFinishedImageViewArray() -> Void {
        for index in 0 ..< 9 {
            let finishedImageView = ProgressButtonManager.imageViewArray[index]
            let isFinished = ProgressButtonManager.hasNotesArray[index]
            
            if isFinished == true {
                DispatchQueue.main.async {
                    finishedImageView.image = UIImage.init(named: EnumStandard.ImageName.finished.rawValue)
                }
                
            }else {
                DispatchQueue.main.async {
                    finishedImageView.image = UIImage.init(named: EnumStandard.ImageName.unfinished.rawValue)
                }
                
            }
            
            
        }
        
    }// funcEnd
    
    /// 获取当前按钮
    private static func getPresentButtonIndex(_ presentTime: Double) -> Int {
        let presentTimeInt = Int.init(presentTime)
        let tmpTimeInt = (presentTimeInt - presentTimeInt % 3) / 3
        
        if tmpTimeInt <= 8 {
            return tmpTimeInt
            
        }else {
            return 8
        }
    }
    
    /// 生成9个Button的ViewModelArray
    private static func createButtonsViewModelArray(buttonWidth: CGFloat,
                                     buttonHeight: CGFloat) -> [CGRect] {
        var viewModelArray: [CGRect] = []
        
        let baseButtonPadding: CGFloat = 3
        let baseButtonX = (ToolClass.getScreenWidth() - buttonWidth * 9 - baseButtonPadding * 8) / 2
        let baseButtonY = (100 - buttonHeight) / 3 * 2
        
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
            buttonProgressBar.isUserInteractionEnabled = true
            buttonProgressBar.tag = index
            buttonProgressBar.addTarget(nil, action: clickButtonEvent, for: .touchUpInside)
            superView.addSubview(buttonProgressBar)
            
            buttonsArray.append(buttonProgressBar)
            index += 1
        }
        
        return buttonsArray
    }// funcEnd
    
}
