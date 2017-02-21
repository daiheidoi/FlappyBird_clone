//
//  GameScene.swift
//  FlappyBird
//
//  Created by 土井大平 on 2017/02/21.
//  Copyright © 2017年 土井大平. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {

    /// SKView上にシーンが表示された際に呼ばれるメソッド
    ///
    /// - Parameter view: SKView
    override func didMove(to view: SKView) {
        
        // 背景色を設定
        self.backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    }
}
