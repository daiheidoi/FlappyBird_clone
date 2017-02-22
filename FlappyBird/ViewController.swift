//
//  ViewController.swift
//  FlappyBird
//
//  Created by 土井大平 on 2017/02/21.
//  Copyright © 2017年 土井大平. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewをSKViewとして取得
        let skView = self.view as! SKView
        
        // FPS表示　ノード数表示
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // ビューと同じサイズのSKScene生成
        let scene = GameScene(size: skView.frame.size)
        
        // 遷移
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// ステータスバー隠す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}

