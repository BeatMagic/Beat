//
//  SimpleAlertController.swift
//  BeatDemo
//
//  Created by X Young. on 2018/8/27.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class SimpleAlertController: NSObject {
    static var shared: UIAlertController = UIAlertController.init()
    
    /// 返回AlertController
    static func getSimpleAlertController(title: String, message: String?, actionClosures: @escaping (() -> Void)) -> UIAlertController {

        SimpleAlertController.shared = UIAlertController.init()
        SimpleAlertController.shared.title = title
        SimpleAlertController.shared.message = message
        
        let sureAction = UIAlertAction.init(title: "确定", style: .destructive) { (UIAlertAction) in
            actionClosures()
        }
        
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        SimpleAlertController.shared.addAction(sureAction)
        SimpleAlertController.shared.addAction(cancelAction)
        
        return SimpleAlertController.shared
    }// funcEnd
}
