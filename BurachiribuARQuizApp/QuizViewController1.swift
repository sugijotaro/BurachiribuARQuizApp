import UIKit
import SceneKit
import ARKit
import AVFoundation

class QuizViewController1: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var referenceImages: Set<ARReferenceImage>?
    
    var UIPlayer: AVPlayer?
    
    var avPlayer: AVPlayer?
    
    var CorrectPlayer: AVPlayer?
    var IncorrectPlayer: AVPlayer?
    
    //選択肢のボタン
    @IBOutlet var choiceButtons1: UIButton!
    @IBOutlet var choiceButtons2: UIButton!
    @IBOutlet var choiceButtons3: UIButton!
    @IBOutlet var choiceButtons4: UIButton!
    
    @IBOutlet var seigo :UIImageView!
    
    @IBOutlet var QuizView :UIView!
    @IBOutlet var SeigoView :UIView!
    @IBOutlet var BGView: UIImageView!
    
    @IBOutlet var findnews: UIImageView!
    @IBOutlet var newsUI: UIImageView!
    
    var PlayerCondition: Int = 0 //まだ再生してない＝0　再生が終わった＝1
    
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
            newsUI.image = UIImage(named: "news\(quizNumber+1)UI.png")
            findnews.image = UIImage(named: "findnews\(quizNumber+1).png")
            UIPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)UI", ofType: "mp4")!))
        }
        
        choiceButtons1.isHidden = true  //ボタン非表示
        choiceButtons2.isHidden = true
        choiceButtons3.isHidden = true
        choiceButtons4.isHidden = true
        seigo.isHidden = true   //非表示
        QuizView.isHidden = true    //非表示
        BGView.alpha = 0    //非表示
        SeigoView.isHidden = true    //非表示
        newsUI.isHidden = true //非表示
        findnews.isHidden = false  //表示
        
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
        } else {
            if userDefaults?.array(forKey: "scoreData") != nil{
                score = userDefaults?.array(forKey: "scoreData") as! [Int]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
        // Run the view's session
        sceneView.session.run(configuration)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.findnews.alpha = 0    //繰り返し表示
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView?.session.pause()
    }
    
    
    lazy var playerLayer: AVPlayerLayer? = AVPlayerLayer(player: UIPlayer)
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if 1 <= quizNumber && quizNumber <= 10{
            avPlayer = AVPlayer(url: Bundle.main.url(forResource: "news\(quizNumber+1)", withExtension: "mp4")!)
        }
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor , PlayerCondition == 0{
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
            
            UIPlayer!.play()
            
            // AVPlayer用のLayerを生成
            
            playerLayer!.frame = QuizView.bounds
            playerLayer!.videoGravity = .resizeAspectFill
            playerLayer!.zPosition = -1 // ボタン等よりも後ろに表示
            QuizView.layer.insertSublayer(playerLayer!, at: 0) // 動画をレイヤーとして追加
            
            findnews.isHidden = true //非表示
            BGView.alpha = 1    //表示
            QuizView.isHidden = false //表示
            QuizView.bringSubviewToFront(BGView)  //重ね順
        }
        return node
    }
    
    
    
    lazy var playerLayerCorrect: AVPlayerLayer? = AVPlayerLayer(player: CorrectPlayer)
    
    
    lazy var playerLayerIncorrect: AVPlayerLayer? = AVPlayerLayer(player: IncorrectPlayer)
    
    @IBAction func choiceAnswer(sender: UIButton) {
        if 1 <= quizNumber && quizNumber <= 10{
            CorrectPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)correct", ofType: "mp4")!))
            
            IncorrectPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)incorrect", ofType: "mp4")!))
        }
        if sender.tag == correctNumber[quizNumber] {    //正解
            seigo.isHidden = false  //表示
            autoreleasepool {
                seigo.image = UIImage(named: "true.png")
            }
            audioPlayerInstanceCorrect.play()
            print("Q\(quizNumber)正解")
            choiceButtons1.isHidden = true //ボタン非表示
            choiceButtons2.isHidden = true
            choiceButtons3.isHidden = true
            choiceButtons4.isHidden = true
            
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
            score += [0]
            userDefaults!.set(score, forKey: "scoreData")
            print(score)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.seigo.isHidden = true  //時間差で非表示にする
                self.SeigoView.isHidden = false    //表示
                self.newsUI.isHidden = false
                
                self.CorrectPlayer?.play()
                self.playerLayerCorrect!.frame = self.SeigoView.bounds
                self.playerLayerCorrect!.videoGravity = .resizeAspectFill
                self.playerLayerCorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.SeigoView.layer.insertSublayer(self.playerLayerCorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeCorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.CorrectPlayer?.currentItem)
                
            }
        } else {    //不正解
            seigo.isHidden = false  //表示
            autoreleasepool {
                seigo.image = UIImage(named: "false.png")
            }
            audioPlayerInstanceIncorrect.play()
            print("Q\(quizNumber)不正解")
            choiceButtons1.isHidden = true //ボタン非表示
            choiceButtons2.isHidden = true
            choiceButtons3.isHidden = true
            choiceButtons4.isHidden = true
            
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
            score += [1]
            userDefaults!.set(score, forKey: "scoreData")
            print(score)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.seigo.isHidden = true  //時間差で非表示にする
                self.SeigoView.isHidden = false    //表示
                self.newsUI.isHidden = false
                
                self.IncorrectPlayer!.play()
                self.playerLayerIncorrect!.frame = self.SeigoView.bounds
                self.playerLayerIncorrect!.videoGravity = .resizeAspectFill
                self.playerLayerIncorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.SeigoView.layer.insertSublayer(self.playerLayerIncorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeIncorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.IncorrectPlayer?.currentItem)
                
            }
        }
        
    }
    
    @objc func didPlayToEndTime() {
        // news2.mp4の再生が終了したら呼ばれる
        if PlayerCondition == 0{
            print("Q\(quizNumber)再生終了")
            choiceButtons1.isHidden = false //ボタン表示
            choiceButtons2.isHidden = false
            choiceButtons3.isHidden = false
            choiceButtons4.isHidden = false
            PlayerCondition = 1
        }
        
    }
    
    @objc func didPlayToEndTimeCorrect() {
        resultMovieFinished()
    }
    
    @objc func didPlayToEndTimeIncorrect() {
        resultMovieFinished()
    }
    
    func resultMovieFinished(){
        seigo.image = nil
        findnews.image = nil
        newsUI.image = nil
        avPlayer = nil
        sceneView.removeFromSuperview()
        sceneView = nil
        UIPlayer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        CorrectPlayer = nil
        playerLayerCorrect?.removeFromSuperlayer()
        playerLayerCorrect = nil
        IncorrectPlayer = nil
        playerLayerIncorrect?.removeFromSuperlayer()
        playerLayerIncorrect = nil
        print("nilにした")
        if quizNumber < 10{
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Q1") as! QuizViewController1
            nextView.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            nextView.quizNumber = self.quizNumber + 1
            navigationController?.pushViewController(nextView, animated: true)
        }else{
            self.performSegue(withIdentifier: "toResult_iPad", sender: nil)
        }
    }
    
    
}
