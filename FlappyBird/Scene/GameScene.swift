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

    /// スクロールする親母体node
    var scrollNode: SKNode!
    
    /// 壁の親母体
    var wallNode: SKNode!
    
    /// 鳥のスプライト
    var bird: SKSpriteNode!
    
    /// 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    
    /// スコア
    var score = 0
    /// スコアラベル
    var scoreLabelNode:SKLabelNode!
    /// ベストスコアラベル
    var bestScoreLabelNode:SKLabelNode!
    
    /// UserDefaults
    let userDefaults: UserDefaults = UserDefaults.standard
    
    /// SKView上にシーンが表示された際に呼ばれるメソッド
    ///
    /// - Parameter view: SKView
    override func didMove(to view: SKView) {
        
        // 重力を設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        self.physicsWorld.contactDelegate = self
        
        // 背景色を設定
        self.backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロール母体の設定
        self.scrollNode = SKNode()
        self.addChild(self.scrollNode)
        
        // 壁母体の設定
        self.wallNode = SKNode()
        self.addChild(self.wallNode)
        
        // それぞれのスプライト設定
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
    }
    
    /// リスタート
    private func restart() {
        self.score = 0
        self.scoreLabelNode.text = String("Score:\(self.score)")
        
        self.bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        self.bird.physicsBody?.velocity = CGVector.zero
        self.bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        self.bird.zRotation = 0.0
        
        self.wallNode.removeAllChildren()
        
        self.bird.speed = 1
        self.scrollNode.speed = 1
    }
    
    /// スコアの設定
    private func setupScoreLabel() {
        self.score = 0
        self.scoreLabelNode = SKLabelNode()
        self.scoreLabelNode.fontColor = UIColor.black
        self.scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        self.scoreLabelNode.zPosition = 100 // 一番手前に表示する
        self.scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.scoreLabelNode.text = "Score:\(self.score)"
        self.addChild(self.scoreLabelNode)
        
        self.bestScoreLabelNode = SKLabelNode()
        self.bestScoreLabelNode.fontColor = UIColor.black
        self.bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        self.bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        self.bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = self.userDefaults.integer(forKey: "BEST")
        self.bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(self.bestScoreLabelNode)
    }
    
    /// 地面スプライトの生成
    private func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = self.groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            // スプライトを追加する
            self.scrollNode.addChild(sprite)
        }
    }
    
    /// 雲スプライトの生成
    private func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            self.scrollNode.addChild(sprite)
        }
    }
    
    /// 壁スプライトの設定
    private func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            // 物理演算を設定
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.isDynamic = false
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 物理演算を設定
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.isDynamic = false
            upper.physicsBody?.categoryBitMask = self.wallCategory
            wall.addChild(upper)
            
            // スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        self.wallNode.run(repeatForeverAnimation)
    }
    
    /// 鳥スプライト設定
    private func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライトを作成
        self.bird = SKSpriteNode(texture: birdTextureA)
        self.bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        self.bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        // 衝突時に回転させない
        self.bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        self.bird.physicsBody?.categoryBitMask = self.birdCategory
        self.bird.physicsBody?.collisionBitMask = self.groundCategory | self.wallCategory
        self.bird.physicsBody?.contactTestBitMask = self.groundCategory | self.wallCategory
        
        // アニメーションを設定
        self.bird.run(flap)
        
        // スプライトを追加する
        self.addChild(self.bird)
    }
    
    /// シーンタップ時に呼ばれる
    ///
    /// - Parameters:
    ///   - touches: タッチインスタンス
    ///   - event: イベント
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            self.bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if self.bird.speed == 0 {
            self.restart()
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    /// コンタクトした時に呼ばれる
    ///
    /// - Parameter contact: contactインスタンス
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if self.scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & self.scoreCategory) == self.scoreCategory
            || (contact.bodyB.categoryBitMask & self.scoreCategory) == self.scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            self.score += 1
            self.scoreLabelNode.text = "Score:\(self.score)"
            
            // ベストスコアとの比較
            if self.score > self.userDefaults.integer(forKey: "BEST") {
                self.bestScoreLabelNode.text = "Best Score:\(self.score)"
                self.userDefaults.set(score, forKey: "BEST")
                self.userDefaults.synchronize()
            }
            
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            self.scrollNode.speed = 0
            
            self.bird.physicsBody?.collisionBitMask = self.groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(M_PI) * CGFloat(self.bird.position.y) * 0.01, duration:1)
            self.bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
}
