//
//  FrameStandard.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class FrameStandard: NSObject {
    /// 主页面进度条X
    static var progressBarX: CGFloat = 15
    /// 主页面进度条Y
    static var progressBarY: CGFloat = (100 - 15) / 2
    /// 主页面进度条宽
    static var progressBarWidth: CGFloat = ToolClass.getScreenWidth() - 15 * 2
    /// 主页面进度条高
    static var progressBarHeight: CGFloat = 15
    
    
    /// 主页面通用View宽
    static var universalWidth: CGFloat = 300 / 375 * ToolClass.getScreenWidth()
    
    /// 主页面通用View高
    static var universalHeight: CGFloat = 180 / 667 * ToolClass.getScreenHeight()
    
    /// 节拍View高
    static var beatViewHeight: CGFloat = universalHeight / 4 * 3
    
    
    
}
