
import UIKit
import SceneKit
import ARKit
import AVFoundation

class ResultViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var resultView: UIView!
    @IBOutlet var touchButton: UIButton!
    
    @IBOutlet var movieView: UIView!
    
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var sum: UILabel!
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var EDimage: UIImageView!
    
    @IBOutlet var showresult: UIButton!
    
    var score: [Int] = [1]   //0=正解 1=不正解
    var userDefaults = UserDefaults(suiteName: "group.com.burachiribu")
    
    var shareImage: UIImage?
    
    var scoreInt: Int = 0
    
    var I: Int = 0
    
    var audioPlayerInstanceDrum : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
    
    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 0
        return configuration
    }()
    
    var moviePlayer: AVPlayer?
    
    var result: [String] = []
    
    var menuBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView.isHidden = true
        touchButton.isHidden = true
        EDimage.isHidden = true
        showresult.isHidden = true
        
        
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "結果発表"
        
        
        if userDefaults?.array(forKey: "scoreData") != nil{
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
        } else {
            score = [2,1,1,1,1,1,1,1,1,1,1]
        }
        if score.count < 12{
            score = [2,1,1,1,1,1,1,1,1,1,1]
//            score = [2,0,0,0,0,0,0,0,0,0,0]
        }
        
        for i in 1...10{
            if score[i] == 0{
                result.append("⭕️")
                scoreInt = scoreInt + 1
            }else{
                result.append("❌")
            }
        }
        resultLabel.text = result.joined(separator: "\n")
        
        let stringAttributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.red
        ]
        let string1 = NSAttributedString(string: String(scoreInt), attributes: stringAttributes1)
        
        let stringAttributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.black
        ]
        let string2 = NSAttributedString(string: "／10", attributes: stringAttributes2)
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        
        sum.attributedText = mutableAttributedString
        print(scoreInt)
        
        if scoreInt > 9{
            name.text = "えいえんのブラチリブ部員"
        } else if scoreInt > 7{
            name.text = "カリスマブラチリブ部員"
        } else if scoreInt > 5{
            name.text = "スーパーブラチリブ部員"
        } else if scoreInt > 3{
            name.text = "まことのブラチリブ部員"
        } else if scoreInt >= 0{
            name.text = "ふつうのブラチリブ部員"
        }
        
        let soundFilePathDrum = Bundle.main.path(forResource: "drum", ofType: "mp3")!
        
        let soundDrum:URL = URL(fileURLWithPath: soundFilePathDrum)
        // AVAudioPlayerのインスタンスを作成,ファイルの読み込み
        do {
            audioPlayerInstanceDrum = try AVAudioPlayer(contentsOf: soundDrum, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        // 再生準備
        audioPlayerInstanceDrum.prepareToPlay()
        
        UIGraphicsBeginImageContextWithOptions(resultView.bounds.size, false, 0.0)
        resultView.layer.render(in: UIGraphicsGetCurrentContext()!)
//        self.view.drawHierarchy(in: self.resultView.bounds, afterScreenUpdates: true)
        shareImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = Bundle.main.path(forResource: "result", ofType: "mp4")!
        moviePlayer = AVPlayer(url: URL(fileURLWithPath: path))
        
        let playerLayer = AVPlayerLayer(player: moviePlayer)
        playerLayer.frame = self.movieView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -1
        movieView.layer.insertSublayer(playerLayer, at: 0)
        moviePlayer!.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(imageConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    @objc func didPlayToEndTime() {
        movieView.isHidden = true
        movieView.layer.sublayers = nil
        audioPlayerInstanceDrum.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.resultView.isHidden = false
            self.touchButton.isHidden = false
        }
    }
    
    @IBAction func touched(){
        if I == 0{
            self.resultView.isHidden = true
            self.touchButton.isHidden = true
            self.movieView.isHidden = false
            if scoreInt >= 5{
                let pathWin = Bundle.main.path(forResource: "resultWin", ofType: "mp4")!
                moviePlayer = AVPlayer(url: URL(fileURLWithPath: pathWin))
                
                let playerLayerWin = AVPlayerLayer(player: moviePlayer)
                playerLayerWin.frame = self.movieView.bounds
                playerLayerWin.videoGravity = .resizeAspectFill
                playerLayerWin.zPosition = -1
                movieView.layer.insertSublayer(playerLayerWin, at: 0)
                moviePlayer!.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeWin), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
            } else {
                let pathLose = Bundle.main.path(forResource: "resultLose", ofType: "mp4")!
                moviePlayer = AVPlayer(url: URL(fileURLWithPath: pathLose))
                
                let playerLayerLose = AVPlayerLayer(player: moviePlayer)
                playerLayerLose.frame = self.movieView.bounds
                playerLayerLose.videoGravity = .resizeAspectFill
                playerLayerLose.zPosition = -1
                movieView.layer.insertSublayer(playerLayerLose, at: 0)
                moviePlayer!.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeLose), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
            }
        }else {
            resultView.isHidden = true
            touchButton.isHidden = true
        }
        
    }
    
    @objc func didPlayToEndTimeWin() {
        ED()
    }
    
    @objc func didPlayToEndTimeLose() {
        ED()
    }
    
    func ED () {
        movieView.layer.sublayers = nil
        let pathED = Bundle.main.path(forResource: "ED", ofType: "mp4")!
        moviePlayer = AVPlayer(url: URL(fileURLWithPath: pathED))
        
        let playerLayerED = AVPlayerLayer(player: moviePlayer)
        playerLayerED.frame = self.movieView.bounds
        playerLayerED.videoGravity = .resizeAspectFill
        playerLayerED.zPosition = -1
        movieView.layer.insertSublayer(playerLayerED, at: 0)
        moviePlayer!.play()
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeED), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
    }
    
    @objc func didPlayToEndTimeED() {
        movieView.isHidden = true
        moviePlayer = nil
        EDimage.isHidden = false
        showresult.isHidden = false
        menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "Image"), style: .plain, target: self, action: #selector(menuButtonTapped(_:)))
        self.navigationItem.setLeftBarButtonItems([menuBarButtonItem], animated: true)
    }
    
    @IBAction func showResultED() {
        resultView.isHidden = false
        touchButton.isHidden = false
        I = 1
    }
    
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        let toTutorial = UIAlertAction(title: "チュートリアルに戻る", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(toTutorial)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction) in
            })
        }

        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.barButtonItem = menuBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }

}


extension ResultViewController: ARSCNViewDelegate {

}
