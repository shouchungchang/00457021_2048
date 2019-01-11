//
//  NumberTileGame.swift
//  00457021_2048
//
//  Created by User16 on 2019/1/11.
//  Copyright © 2019 00457021_2048. All rights reserved.
//

import UIKit

//代表swift-2048遊戲的視圖控制器。 它主要用於綁定GameModel和GameboardView
// 數據流如下工作：用戶輸入到達視圖控制器並被轉發到model
//由模型計算的移動返回到視圖控制器並轉發到遊戲板視圖，該視圖執行任何動畫來更新其狀態

protocol FetchScoreDelegate {
    func fetchScore(_ score: Int)
}

class NumberTileGameViewController : UIViewController, GameModelProtocol {
    
    
    
    // 2048遊戲中每行每列含有多少個塊
    var dimension: Int
    // 分數最高那一塊的值
    var threshold: Int
    var flag: Int = 0
    
    
    var board: GameboardView?
    var model: GameModel?
    var scoreView: ScoreViewProtocol?
    var player: Player?
    
    var delegate: FetchScoreDelegate?
    var rankVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"Rank")as!RankTableViewController
    
    //創建一个custom類型的按鈕
    let button:UIButton = UIButton(type:.custom)
    let buttonBefore:UIButton = UIButton(type:.custom)
    let buttonBack = UIButton(type: .custom)
    
    
    // 遊戲版版的寬度
    let boardWidth: CGFloat = 230.0
    // 小塊小塊的間距
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    
    // 在不同的組件視圖（遊戲板，分數版等）之間放置的空間量
    let viewPadding: CGFloat = 10.0
    
    // 如果它們居中，那麼組件視圖的垂直對齊應該不同
    let verticalViewOffset: CGFloat = 0.0
    
    //設置了最小2個塊塊和最低分數8分
    init(dimension d: Int, threshold t: Int) {
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        super.init(nibName: nil, bundle: nil)
        model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named:"Image")!)
        setupSwipeControls()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.upCommand(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizer.Direction.up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.downCommand(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.leftCommand(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.rightCommand(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(rightSwipe)
    }
    
    
    // View Controller
    override func viewDidLoad()  {
        super.viewDidLoad()
        setupGame()
        
        
        
    }
    
    func segueToSecondViewController() {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "Rank") as! RankTableViewController
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func reset() {
        assert(board != nil && model != nil)
        let b = board!
        let m = model!
        b.reset()
        m.reset()
        m.insertTileAtRandomLocation(withValue: 2)
        m.insertTileAtRandomLocation(withValue: 2)
    }
    
    @objc func buttonClicked(sender:UIButton)
    {
        self.reset()
    }
    
    @objc func buttonBackClicked(sender:UIButton)
    {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "start") as! ViewController
        self.dismiss(animated: true, completion: nil)  //回前頁並顯示tab bar
    }
    
    
    @objc func buttonBeforeClicked(sender:UIButton)
    {
        let scoreView = self.scoreView
        let alertView = UIAlertView()
        alertView.title = "挑戰成功"
        alertView.message = "記下你的大名吧："
        alertView.addButton(withTitle: "OK")
        alertView.show()
        scoreView?.scoreChanged(to: 2048)
        
        self.present(rankVC, animated: true, completion: nil)
        self.delegate = rankVC as? FetchScoreDelegate
        self.delegate?.fetchScore(getScore())
        
        self.segueToSecondViewController()
        
    }
    
    
    func setupGame() {
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
        // 提供x位置的function
        func xPositionToCenterView(_ v: UIView) -> CGFloat {
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vcWidth - viewWidth)
            return tentativeX >= 0 ? tentativeX : 0
        }
        // 提供y位置的function
        func yPositionForViewAtPosition(_ order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            //      let viewHeight = views[order].bounds.size.height
            let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
            let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0
            
            // Not sure how to slice an array yet
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        // 創造 the score view
        let scoreView = ScoreView(backgroundColor: UIColor(red: 249/255, green: 109/255, blue: 156/255, alpha: 1.0),
                                  textColor: UIColor.white,
                                  font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0),
                                  radius: 6)
        scoreView.score = 0
        
        //create a button
        //設置按鈕位置和大小
        button.frame = CGRect(x:136, y:240, width:140, height:30)
        //設置按鈕文字
        button.setTitle("↻ 重新開始 ↻", for:.normal)
        button.backgroundColor = UIColor(red: 249/255, green: 109/255, blue: 156/255, alpha: 1.0)
        button.setTitleColor(UIColor.white,for: .normal)
        button.layer.cornerRadius = 15
        
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 12, height: 12)
        button.layer.shadowOpacity = 0.7
        
        
        self.view.addSubview(button)
        
        // 按鈕按下後的動作
        button.tag = 5
        button.addTarget(self,action:#selector(buttonClicked),
                         for:.touchUpInside)
        
        //create a buttonbefore
        //設置按鈕位置和大小
        buttonBefore.frame = CGRect(x:160, y:700, width:220, height:40)
        //設置按鈕文字
        buttonBefore.setTitle("點我一鍵加速┌( ಠ‿ಠ)┘", for:.normal)
        buttonBefore.backgroundColor = UIColor(red: 249/255, green: 109/255, blue: 156/255, alpha: 1.0)
        buttonBefore.setTitleColor(UIColor.white,for: .normal)
        buttonBefore.layer.cornerRadius = 15
        self.view.addSubview(buttonBefore)
        
        // 按鈕按下後的動作
        buttonBefore.addTarget(self,action:#selector(buttonBeforeClicked),for:.touchUpInside)
        
        buttonBack.frame = CGRect(x:20, y:100, width:120, height:30)
        buttonBack.setTitle("⇦ 回到首頁", for: .normal)
        buttonBack.backgroundColor = UIColor(red: 249/255, green: 109/255, blue: 156/255, alpha: 1.0)
        buttonBack.setTitleColor(UIColor.white,for: .normal)
        buttonBack.layer.cornerRadius = 15
        self.view.addSubview(buttonBack)
        
        buttonBack.addTarget(self,action:#selector(buttonBackClicked),for:.touchUpInside)
        
        
        
        
        
        
        // 創造遊戲版版
        let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameboardView(dimension: dimension,
                                      tileWidth: width,
                                      tilePadding: padding,
                                      cornerRadius: 6,
                                      backgroundColor: UIColor(red: 249/255, green: 109/255, blue: 156/255, alpha: 1.0),
                                      foregroundColor: UIColor(red: 255/255, green: 160/255, blue: 204/255, alpha: 1.0))
        
        // 將遊戲中的遊戲介面和分數介面➕到frame中
        let views = [scoreView, gameboard]
        
        var f = scoreView.frame
        f.origin.x = xPositionToCenterView(scoreView)
        f.origin.y = yPositionForViewAtPosition(0, views: views)
        scoreView.frame = f
        
        f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionForViewAtPosition(1, views: views)
        gameboard.frame = f
        
        
        // Add to game state
        view.addSubview(gameboard)
        board = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
        
        assert(model != nil)
        let m = model!
        m.insertTileAtRandomLocation(withValue: 2)
        m.insertTileAtRandomLocation(withValue: 2)
    }
    
    // Misc
    func followUp() {
        assert(model != nil)
        let m = model!
        let (userWon, _) = m.userHasWon()
        if userWon {
            // TODO: alert delegate we won
            
            let alertView = UIAlertView()
            alertView.title = "挑戰成功"
            alertView.message = "恭喜你!"
            alertView.addButton(withTitle: "Cancel")
            alertView.show()
            // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
            return
        }
        
        
        
        // 插入更多塊塊
        let randomVal = Int(arc4random_uniform(10))
        m.insertTileAtRandomLocation(withValue: randomVal == 1 ? 4 : 2)
        
        // 判斷使用者是否輸
        if m.userHasLost() {
            // TODO: 跳出alert
            NSLog("You lost...")
            let alertController = UIAlertController(title: "Q Q", message: "很可惜失敗了", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "重新開始", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.reset()
            }
            let cancelAction = UIAlertAction(title: "輸入成績", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                
                //此動作要將分數傳到下個view controller
                self.present(self.rankVC, animated: true, completion: nil)
                self.delegate = self.rankVC as? FetchScoreDelegate
                self.delegate?.fetchScore(self.getScore())
                self.segueToSecondViewController()
                
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Commands
    @objc(up:)
    func upCommand(_ r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.up,
                    onCompletion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.down,
                    onCompletion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.left,
                    onCompletion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.right,
                    onCompletion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    // Protocol
    func scoreChanged(to score: Int) {
        if scoreView == nil {
            return
        }
        let s = scoreView!
        s.scoreChanged(to: score)
    }
    
    func getScore() -> Int {
        let s = scoreView!
        return s.getScore()
    }
    
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveOneTile(from: from, to: to, value: value)
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveTwoTiles(from: from, to: to, value: value)
    }
    
    func insertTile(at location: (Int, Int), withValue value: Int) {
        assert(board != nil)
        let b = board!
        b.insertTile(at: location, value: value)
    }
}

