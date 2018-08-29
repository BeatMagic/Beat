//
//  VariousSetFunc.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/29.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class VariousSetFunc: NSObject {
    static func setMusicStabileKeysUI(musicKeysArray: [BaseMusicKey], rulesArray: [Int]) -> Void {
        
        var index = 0
        for musicKey in musicKeysArray {
            if rulesArray.contains(index) {
                
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.flatGreen
                }
                
                
            }else {
                DispatchQueue.main.async {
                    musicKey.backgroundColor = UIColor.white
                }
            }
            
            index += 1
        }
        
    }
}
