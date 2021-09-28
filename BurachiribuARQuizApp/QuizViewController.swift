
import UIKit
import SceneKit
import ARKit
import AVFoundation

class QuizViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    let imageConfiguration = ARImageTrackingConfiguration()
    
    @IBOutlet var findNewsImageView: UIImageView!
    @IBOutlet var symbolDisplayImageView :UIImageView!
    @IBOutlet weak var explanationVideoView :UIView!
    
    @IBOutlet var quizView :UIView!
    @IBOutlet var newsUIImageView: UIImageView!
    @IBOutlet var quizBackGroundImageView: UIImageView!
    
    @IBOutlet var choiceButtons: [UIButton] = []
    
    private var uiVideoPlayer: AVPlayer?
    private weak var quizVideoPlayer: AVPlayer?
    private var correctVideoPlayer: AVPlayer?
    private var incorrectVideoPlayer: AVPlayer?
    
    var quizNumber: Int = 1
    
    private  var isPlayerFinishedWatchQuizVideo: Bool = false
    
    private var audioPlayerInstanceCorrect : AVAudioPlayer! = nil
    private var audioPlayerInstanceIncorrect : AVAudioPlayer! = nil
    
    lazy var playerLayer: AVPlayerLayer? = AVPlayerLayer(player: uiVideoPlayer)
    lazy var playerLayerCorrect: AVPlayerLayer? = AVPlayerLayer(player: correctVideoPlayer)
    lazy var playerLayerIncorrect: AVPlayerLayer? = AVPlayerLayer(player: incorrectVideoPlayer)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        print("クイズ\(quizNumber)問目")
        
        if 1 <= quizNumber && quizNumber <= 10{
            imageConfiguration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-\(quizNumber)", bundle: nil)!
            imageConfiguration.maximumNumberOfTrackedImages = 1
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
        
        symbolDisplayImageView.isHidden = true
        quizView.isHidden = true
        quizBackGroundImageView.alpha = 0
        explanationVideoView.isHidden = true
        newsUIImageView.isHidden = true
        findNewsImageView.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        
        let soundFilePathCorrect = Bundle.main.path(forResource: "correct", ofType: "mp3")!
        let soundCorrect:URL = URL(fileURLWithPath: soundFilePathCorrect)
        do {
            audioPlayerInstanceCorrect = try AVAudioPlayer(contentsOf: soundCorrect, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        audioPlayerInstanceCorrect.prepareToPlay()
        
        let soundFilePathIncorrect = Bundle.main.path(forResource: "incorrect", ofType: "mp3")!
        let soundIncorrect:URL = URL(fileURLWithPath: soundFilePathIncorrect)
        do {
            audioPlayerInstanceIncorrect = try AVAudioPlayer(contentsOf: soundIncorrect, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        audioPlayerInstanceIncorrect.prepareToPlay()
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
        
        sceneView.session.run(imageConfiguration)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.findNewsImageView.alpha = 0
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView?.session.pause()
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        quizVideoPlayer = AVPlayer(url: Bundle.main.url(forResource: "news\(quizNumber+1)", withExtension: "mp4")!)
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor , !isPlayerFinishedWatchQuizVideo{
            let skScene = SKScene(size: CGSize(width: CGFloat(1000), height: CGFloat(1000)))
            NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: quizVideoPlayer?.currentItem)
            
            let skNode = SKVideoNode(avPlayer: quizVideoPlayer!)
            skNode.position = CGPoint(x: skScene.size.width / 2.0, y: skScene.size.height / 2.0)
            skNode.size = skScene.size
            skNode.yScale = -1.0
            skNode.play()
            print("Q\(quizNumber)再生開始")
            skScene.addChild(skNode)
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = skScene
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            uiVideoPlayer!.play()
            
            playerLayer!.frame = quizView.bounds
            playerLayer!.videoGravity = .resizeAspectFill
            playerLayer!.zPosition = -1
            quizView.layer.insertSublayer(playerLayer!, at: 0)
            
            findNewsImageView.isHidden = true
            quizBackGroundImageView.alpha = 1
            quizView.isHidden = false
            quizView.bringSubviewToFront(quizBackGroundImageView)
        }
        return node
    }
    
    
    @IBAction func tappedChoiceButton(sender: UIButton) {
        correctVideoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)correct", ofType: "mp4")!))
        incorrectVideoPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "news\(quizNumber+1)incorrect", ofType: "mp4")!))
        
        symbolDisplayImageView.isHidden = false
        for choiceButton in choiceButtons{
            choiceButton.isHidden = true
        }
        
        if GameService.isCorrect(quizNumber: quizNumber, userSelectedNumber: sender.tag){
            print("Q\(quizNumber)正解")
            symbolDisplayImageView.image = UIImage(named: "true.png")
            audioPlayerInstanceCorrect.play()
            FirebaseEventsService.quizSelect(isCorrect: true, quizNumber: quizNumber, selectedNumber: sender.tag)
            GameService.recordScore(isCorrect: true, quizNumber: quizNumber)
            
        } else {
            print("Q\(quizNumber)不正解")
            symbolDisplayImageView.image = UIImage(named: "false.png")
            audioPlayerInstanceIncorrect.play()
            FirebaseEventsService.quizSelect(isCorrect: false, quizNumber: quizNumber, selectedNumber: sender.tag)
            GameService.recordScore(isCorrect: false, quizNumber: quizNumber)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {   //1秒後の処理
            self.symbolDisplayImageView.isHidden = true
            self.explanationVideoView.isHidden = false
            self.newsUIImageView.isHidden = false
            
            if GameService.isCorrect(quizNumber: self.quizNumber, userSelectedNumber: sender.tag){
                self.correctVideoPlayer?.play()
                print("正解動画再生開始")
                self.playerLayerCorrect!.frame = self.explanationVideoView.bounds
                self.playerLayerCorrect!.videoGravity = .resizeAspectFill
                self.playerLayerCorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.explanationVideoView.layer.insertSublayer(self.playerLayerCorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeCorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.correctVideoPlayer?.currentItem)
            } else {
                self.incorrectVideoPlayer?.play()
                print("不正解動画再生開始")
                self.playerLayerIncorrect!.frame = self.explanationVideoView.bounds
                self.playerLayerIncorrect!.videoGravity = .resizeAspectFill
                self.playerLayerIncorrect!.zPosition = -1 // ボタン等よりも後ろに表示
                self.explanationVideoView.layer.insertSublayer(self.playerLayerIncorrect!, at: 0)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTimeIncorrect), name: .AVPlayerItemDidPlayToEndTime, object: self.incorrectVideoPlayer?.currentItem)
            }
        }
        
    }
    
    @objc func didPlayToEndTime() {
        print("Q\(quizNumber)再生終了")
        
        for choiceButton in choiceButtons{
            choiceButton.isHidden = false
        }
        isPlayerFinishedWatchQuizVideo = true
    }
    
    @objc func didPlayToEndTimeCorrect() {
        resultMovieFinished()
    }
    
    @objc func didPlayToEndTimeIncorrect() {
        resultMovieFinished()
    }
    
    private func resultMovieFinished(){
        freeMemory()
        if quizNumber < 10{
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "QuizView") as! QuizViewController
            nextView.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            nextView.quizNumber = self.quizNumber + 1
            navigationController?.pushViewController(nextView, animated: true)
        }else{
            print("結果発表へ")
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }
    }
    
    private func freeMemory(){
        print("メモリ解放")
        sceneView.removeFromSuperview()
        sceneView = nil
        findNewsImageView.removeFromSuperview()
        findNewsImageView.image = nil
        findNewsImageView = nil
        symbolDisplayImageView.removeFromSuperview()
        symbolDisplayImageView.image = nil
        symbolDisplayImageView = nil
        explanationVideoView.removeFromSuperview()
        explanationVideoView = nil
        quizView.removeFromSuperview()
        quizView = nil
        newsUIImageView.removeFromSuperview()
        newsUIImageView = nil
        quizBackGroundImageView.removeFromSuperview()
        quizBackGroundImageView = nil
        uiVideoPlayer!.replaceCurrentItem(with: nil)
        quizVideoPlayer!.replaceCurrentItem(with: nil)
        correctVideoPlayer!.replaceCurrentItem(with: nil)
        incorrectVideoPlayer!.replaceCurrentItem(with: nil)
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
    
}
