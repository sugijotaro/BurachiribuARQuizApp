
import UIKit
import SceneKit
import ARKit
import AVFoundation

class QuizViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var referenceImages: Set<ARReferenceImage>?
    
    var uiVideoPlayer: AVPlayer?
    var avPlayer: AVPlayer?
    var correctVideoPlayer: AVPlayer?
    var incorrectVideoPlayer: AVPlayer?
    
    @IBOutlet var choiceButtons: [UIButton] = []
    
    @IBOutlet var symbolDisplayImageView :UIImageView!
    
    @IBOutlet var quizView :UIView!
    @IBOutlet var seigoView :UIView!
    @IBOutlet var backGroundImageView: UIImageView!
    
    @IBOutlet var findNewsImageView: UIImageView!
    @IBOutlet var newsUIImageView: UIImageView!
    
    var isPlayerFinishedWatchQuizVideo: Bool = false
    
    var quizNumber: Int = 1
    
    var audioPlayerInstanceCorrect : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
    var audioPlayerInstanceIncorrect : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
    
    var score: [Int] = [1]   //0=正解 1=不正解
    var correctNumber: [Int] = [0,3,2,3,1,3,4,2,4,2,3] 
    var userDefaults = UserDefaults(suiteName: "group.com.burachiribu")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        sceneView.delegate = self
        
        if 1 <= quizNumber && quizNumber <= 10{
            print("quizNumber:\(quizNumber)")
            referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-\(quizNumber)", bundle: Bundle.main)
            self.navigationItem.title = "部長とクイズバトルQ\(quizNumber)"
            newsUIImageView.image = UIImage(named: "news\(quizNumber+1)UI.png")
            findNewsImageView.image = UIImage(named: "findnews\(quizNumber+1).png")
            uiVideoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)UI", ofType: "mp4")!))
        }
        
        for choiceButton in choiceButtons{
            choiceButton.clipsToBounds = true
            choiceButton.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 1, green: 1, blue: 1, alpha: 0)), for: .normal)
            choiceButton.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 226/255, green: 225_255, blue: 232/255, alpha: 0.7)), for: .highlighted)
            choiceButton.isHidden = true
        }
        
        symbolDisplayImageView.isHidden = true   //非表示
        quizView.isHidden = true    //非表示
        backGroundImageView.alpha = 0    //非表示
        seigoView.isHidden = true    //非表示
        newsUIImageView.isHidden = true //非表示
        findNewsImageView.isHidden = false  //表示
        
        self.navigationItem.hidesBackButton = true
        
        
        // 正解のサウンドファイルのパスを生成
        let soundFilePathCorrect = Bundle.main.path(forResource: "correct", ofType: "mp3")!
        
        let soundCorrect:URL = URL(fileURLWithPath: soundFilePathCorrect)
        // AVAudioPlayerのインスタンスを作成,ファイルの読み込み
        do {
            audioPlayerInstanceCorrect = try AVAudioPlayer(contentsOf: soundCorrect, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        // 再生準備
        audioPlayerInstanceCorrect.prepareToPlay()
        
        
        // 不正解のサウンドファイルのパスを生成
        let soundFilePathIncorrect = Bundle.main.path(forResource: "incorrect", ofType: "mp3")!
        
        let soundIncorrect:URL = URL(fileURLWithPath: soundFilePathIncorrect)
        // AVAudioPlayerのインスタンスを作成,ファイルの読み込み
        do {
            audioPlayerInstanceIncorrect = try AVAudioPlayer(contentsOf: soundIncorrect, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        // 再生準備
        audioPlayerInstanceIncorrect.prepareToPlay()
        
        //user defaultsリセット
        if quizNumber == 1{
            score = [2]
            userDefaults!.set(score, forKey: "scoreData")
        }
    }
    
    private func createImageFromUIColor(color: UIColor) -> UIImage {
        // 1x1のbitmapを作成
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        // bitmapを塗りつぶし
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        // UIImageに変換
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for choiceButton in choiceButtons{
            choiceButton.layer.cornerRadius = choiceButtons[0].bounds.height * 0.55
        }
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            let title: String = "カメラにアクセスできません"
            let message: String = "設定アプリでこのアプリのカメラへのアクセスを許可してください"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定アプリへ", style: .default, handler: { (_) -> Void in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            let closeAction: UIAlertAction = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
        // Run the view's session
        sceneView.session.run(configuration)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.findNewsImageView.alpha = 0    //繰り返し表示
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView?.session.pause()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    lazy var playerLayer: AVPlayerLayer? = AVPlayerLayer(player: uiVideoPlayer)
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if 1 <= quizNumber && quizNumber <= 10{
            avPlayer = AVPlayer(url: Bundle.main.url(forResource: "news\(quizNumber+1)", withExtension: "mp4")!)
        }
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor , !isPlayerFinishedWatchQuizVideo{
            // SKSceneを生成する
            let skScene = SKScene(size: CGSize(width: CGFloat(1000), height: CGFloat(1000)))
            NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
            
            // AVPlayerからSKVideoNodeの生成する（サイズはskSceneと同じ大きさ）
            let skNode = SKVideoNode(avPlayer: avPlayer!)
            skNode.position = CGPoint(x: skScene.size.width / 2.0, y: skScene.size.height / 2.0)
            skNode.size = skScene.size
            skNode.yScale = -1.0 // 座標系を上下逆にする
            skNode.play()
            skScene.addChild(skNode)
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = skScene
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            // 下の部分読み込み
            
            uiVideoPlayer!.play()
            
            // AVPlayer用のLayerを生成
            
            playerLayer!.frame = quizView.bounds
            playerLayer!.videoGravity = .resizeAspectFill
            playerLayer!.zPosition = -1 // ボタン等よりも後ろに表示
            quizView.layer.insertSublayer(playerLayer!, at: 0) // 動画をレイヤーとして追加
            
            findNewsImageView.isHidden = true //非表示
            backGroundImageView.alpha = 1    //表示
            quizView.isHidden = false //表示
            quizView.bringSubviewToFront(backGroundImageView)  //重ね順
        }
        return node
    }
    
    
    
    lazy var playerLayerCorrect: AVPlayerLayer? = AVPlayerLayer(player: correctVideoPlayer)
    
    
    lazy var playerLayerIncorrect: AVPlayerLayer? = AVPlayerLayer(player: incorrectVideoPlayer)
    
    @IBAction func choiceAnswer(sender: UIButton) {
        if 1 <= quizNumber && quizNumber <= 10{
            correctVideoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)correct", ofType: "mp4")!))
            
            incorrectVideoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)incorrect", ofType: "mp4")!))
        }
        if sender.tag == correctNumber[quizNumber] {    //正解
            symbolDisplayImageView.isHidden = false  //表示
            autoreleasepool {
                symbolDisplayImageView.image = UIImage(named: "true.png")
            }
            audioPlayerInstanceCorrect.play()
            print("Q\(quizNumber)正解")
            for choiceButton in choiceButtons{
                choiceButton.isHidden = true
            }
            FirebaseEventsService.quizSelect(isCorrect: true, quizNumber: quizNumber, selectedNumber: sender.tag)
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
            score += [0]
            print(score)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.symbolDisplayImageView.isHidden = true  //時間差で非表示にする
                self.seigoView.isHidden = false    //表示
                self.newsUIImageView.isHidden = false
                
                self.correctVideoPlayer?.play()
                self.playerLayerCorrect!.frame = self.seigoView.bounds
                self.playerLayerCorrect!.videoGravity = .resizeAspectFill
                self.playerLayerCorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.seigoView.layer.insertSublayer(self.playerLayerCorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeCorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.correctVideoPlayer?.currentItem)
                
            }
        } else {    //不正解
            symbolDisplayImageView.isHidden = false  //表示
            autoreleasepool {
                symbolDisplayImageView.image = UIImage(named: "false.png")
            }
            audioPlayerInstanceIncorrect.play()
            print("Q\(quizNumber)不正解")
            for choiceButton in choiceButtons{
                choiceButton.isHidden = true
            }
            FirebaseEventsService.quizSelect(isCorrect: false, quizNumber: quizNumber, selectedNumber: sender.tag)
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
            score += [1]
            print(score)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.symbolDisplayImageView.isHidden = true  //時間差で非表示にする
                self.seigoView.isHidden = false    //表示
                self.newsUIImageView.isHidden = false
                
                self.incorrectVideoPlayer!.play()
                self.playerLayerIncorrect!.frame = self.seigoView.bounds
                self.playerLayerIncorrect!.videoGravity = .resizeAspectFill
                self.playerLayerIncorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.seigoView.layer.insertSublayer(self.playerLayerIncorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeIncorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.incorrectVideoPlayer?.currentItem)
                
            }
        }
        
    }
    
    @objc func didPlayToEndTime() {
        // news2.mp4の再生が終了したら呼ばれる
        if !isPlayerFinishedWatchQuizVideo{
            print("Q\(quizNumber)再生終了")
            
            for choiceButton in choiceButtons{
                choiceButton.isHidden = false
            }
            isPlayerFinishedWatchQuizVideo = true
        }
        
    }
    
    @objc func didPlayToEndTimeCorrect() {
        resultMovieFinished()
    }
    
    @objc func didPlayToEndTimeIncorrect() {
        resultMovieFinished()
    }
    
    func resultMovieFinished(){
        symbolDisplayImageView.image = nil
        findNewsImageView.image = nil
        newsUIImageView.image = nil
        avPlayer = nil
        sceneView.removeFromSuperview()
        sceneView = nil
        uiVideoPlayer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        correctVideoPlayer = nil
        playerLayerCorrect?.removeFromSuperlayer()
        playerLayerCorrect = nil
        incorrectVideoPlayer = nil
        playerLayerIncorrect?.removeFromSuperlayer()
        playerLayerIncorrect = nil
        print("nilにした")
        userDefaults!.set(score, forKey: "scoreData")
        if quizNumber < 10{
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "QuizView") as! QuizViewController
            nextView.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            nextView.quizNumber = self.quizNumber + 1
            navigationController?.pushViewController(nextView, animated: true)
        }else{
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }
    }
    
    
}
