//
//  MusicKeyBoard.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/22.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

// MARK: - Init and SetUp
class MusicKeyBoard: UIView {
    
    /// 音乐键数组
    var musicKeysArray = [BaseMusicKey]()
    /// 按下的键Set
    var pressedMusicKeys = Set<UInt8>()
    /// 外部代理
    weak var delegate: MusicKeyDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MusicKeyBoard {
    
    /// 生成所有键的ViewModel -> [ CGRect ]
    func initMusicKeyFrame(ownHeight: CGFloat) -> [CGRect] {
        let normalWidth = ToolClass.getScreenWidth() - FrameStandard.universalWidth
        let firstAreaKeyHeight = FrameStandard.universalHeight / 4
        let secondAreaKeyHeight = ownHeight - FrameStandard.universalHeight - FrameStandard.beatViewHeight
        let thirdAreaKeyHeight = FrameStandard.beatViewHeight / 3
        
        var keysViewModel = [CGRect]()
        for index in 0...5 {
            let firstAreaKeyCGRect = CGRect.init(x: 0, y: CGFloat(index) * firstAreaKeyHeight, width: normalWidth, height: firstAreaKeyHeight)
            keysViewModel.append(firstAreaKeyCGRect)
        }
        
        for index in 0...6 {
            let secondAreaCGRect = CGRect.init(x: CGFloat(index) * normalWidth, y: FrameStandard.universalHeight, width: normalWidth, height: secondAreaKeyHeight)
            keysViewModel.append(secondAreaCGRect)
        }
        
        for index in 0...4 {
            let firstAreaKeyCGRect = CGRect.init(x: FrameStandard.universalWidth, y: FrameStandard.universalHeight + secondAreaKeyHeight + CGFloat(index) * thirdAreaKeyHeight, width: normalWidth, height: thirdAreaKeyHeight)
            keysViewModel.append(firstAreaKeyCGRect)
        }
        
        return keysViewModel
    }// funcEnd

    /// 根据所有键的ViewModel生成键 [[CGRect]] -> Void
    func addMusicKeysWithViewModel(_ viewModel: [CGRect]) -> Void {
// TODO: 8/23 继续
    }// funcEnd
    
}



protocol MusicKeyDelegate: class {
    func noteOn(note: UInt8)
    func noteOff(note: UInt8)
}
