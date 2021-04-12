
import UIKit
import SceneKit
import ARKit
import AVFoundation

class ResultViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var resultView: UIView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var touchButton: UIButton!
    
    @IBOutlet var movieView: UIView!
    @IBOutlet var movieView2: UIView!
    @IBOutlet var movieView3: UIView!
    
    @IBOutlet var Q1: UILabel!
    @IBOutlet var Q2: UILabel!
    @IBOutlet var Q3: UILabel!
    @IBOutlet var Q4: UILabel!
    @IBOutlet var Q5: UILabel!
    @IBOutlet var Q6: UILabel!
    @IBOutlet var Q7: UILabel!
    @IBOutlet var Q8: UILabel!
    @IBOutlet var Q9: UILabel!
    @IBOutlet var Q10: UILabel!
    
    @IBOutlet var sum: UILabel!
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var EDimage: UIImageView!
    
    @IBOutlet var showresult: UIButton!
    
    @IBOutlet var quizName: UITextView!
    
    var score: [Int] = [1]   //0=正解 1=不正解
    var userDefaults = UserDefaults(suiteName: "group.com.burachiribu")
    
    var shareImage: UIImage?
    
    var scoreInt: Int = 0
    
    var I: Int = 0
    
    var audioPlayerInstanceDrum : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
    
    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-tutorial", bundle: nil)
        configuration.trackingImages = images!
        configuration.maximumNumberOfTrackedImages = 3
        return configuration
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView.isHidden = true
        touchButton.isHidden = true
        movieView2.isHidden = true
        movieView3.isHidden = true
        EDimage.isHidden = true
        showresult.isHidden = true
        
        quizName.font = UIFont.boldSystemFont(ofSize: 26)
        
        
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "結果発表"
        
        
        if userDefaults?.array(forKey: "scoreData") != nil{
            score = userDefaults?.array(forKey: "scoreData") as! [Int]
        } else {
            score = [1,1,1,1,1,1,1,1,1,1,1]
        }
        
        if score.count > 1 {
            if self.score[1] == 0{
                Q1.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q1.text = "❌"
            }
            
            if self.score[2] == 0{
                Q2.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q2.text = "❌"
            }
            
            if self.score[3] == 0{
                Q3.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q3.text = "❌"
            }
            
            if score[4] == 0{
                Q4.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q4.text = "❌"
            }
            
            if score[5] == 0{
                Q5.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q5.text = "❌"
            }
            
            if score[6] == 0{
                Q6.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q6.text = "❌"
            }
            
            if score[7] == 0{
                Q7.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q7.text = "❌"
            }
            
            if score[8] == 0{
                Q8.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q8.text = "❌"
            }
            
            if score[9] == 0{
                Q9.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q9.text = "❌"
            }
            
            if score[10] == 0{
                Q10.text = "⭕️"
                scoreInt = scoreInt + 1
            } else {
                Q10.text = "❌"
            }
        }
        
        sum.text = String(scoreInt)
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
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.movieView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -1
        movieView.layer.insertSublayer(playerLayer, at: 0)
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(imageConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    
    @objc func didPlayToEndTime() {
        movieView.isHidden = true
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
            self.movieView2.isHidden = false
            if scoreInt >= 5{
                let pathWin = Bundle.main.path(forResource: "resultWin", ofType: "mp4")!
                let playerWin = AVPlayer(url: URL(fileURLWithPath: pathWin))
                
                let playerLayerWin = AVPlayerLayer(player: playerWin)
                playerLayerWin.frame = self.movieView2.bounds
                playerLayerWin.videoGravity = .resizeAspectFill
                playerLayerWin.zPosition = -1
                movieView2.layer.insertSublayer(playerLayerWin, at: 0)
                playerWin.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeWin), name: .AVPlayerItemDidPlayToEndTime, object: playerWin.currentItem)
            } else {
                let pathLose = Bundle.main.path(forResource: "resultLose", ofType: "mp4")!
                let playerLose = AVPlayer(url: URL(fileURLWithPath: pathLose))
                
                let playerLayerLose = AVPlayerLayer(player: playerLose)
                playerLayerLose.frame = self.movieView2.bounds
                playerLayerLose.videoGravity = .resizeAspectFill
                playerLayerLose.zPosition = -1
                movieView2.layer.insertSublayer(playerLayerLose, at: 0)
                playerLose.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeLose), name: .AVPlayerItemDidPlayToEndTime, object: playerLose.currentItem)
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
        movieView2.isHidden = true
        movieView3.isHidden = false
        let pathED = Bundle.main.path(forResource: "ED", ofType: "mp4")!
        let playerED = AVPlayer(url: URL(fileURLWithPath: pathED))
        
        let playerLayerED = AVPlayerLayer(player: playerED)
        playerLayerED.frame = self.movieView3.bounds
        playerLayerED.videoGravity = .resizeAspectFill
        playerLayerED.zPosition = -1
        movieView3.layer.insertSublayer(playerLayerED, at: 0)
        playerED.play()
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeED), name: .AVPlayerItemDidPlayToEndTime, object: playerED.currentItem)
    }
    
    @objc func didPlayToEndTimeED() {
        movieView3.isHidden = true
        EDimage.isHidden = false
        showresult.isHidden = false
    }
    
    @IBAction func showResultED() {
        resultView.isHidden = false
        touchButton.isHidden = false
        I = 1
    }

}


extension ResultViewController: ARSCNViewDelegate {

}
