
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
    
    @IBOutlet var resultTextView: UITextView!
    
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
        configuration.maximumNumberOfTrackedImages = 0
        return configuration
    }()
    
    var resultPlayer: AVPlayer?
    var winPlayer: AVPlayer?
    var losePlayer: AVPlayer?
    var EDPlayer: AVPlayer?
    
    var result: [String] = []
    
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
            score = [2,1,1,1,1,1,1,1,1,1,1]
        }
        if score.count < 12{
            score = [2,1,1,1,1,1,1,1,1,1,1]
        }
        
        for i in 1...10{
            if score[i] == 0{
                result.append("⭕️\n")
                scoreInt = scoreInt + 1
            }else{
                result.append("❌\n")
            }
        }
        resultTextView.text = result.joined()
        
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
        resultPlayer = AVPlayer(url: URL(fileURLWithPath: path))
        
        let playerLayer = AVPlayerLayer(player: resultPlayer)
        playerLayer.frame = self.movieView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -1
        movieView.layer.insertSublayer(playerLayer, at: 0)
        resultPlayer!.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: resultPlayer?.currentItem)
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
        movieView = nil
        resultPlayer = nil
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
                winPlayer = AVPlayer(url: URL(fileURLWithPath: pathWin))
                
                let playerLayerWin = AVPlayerLayer(player: winPlayer)
                playerLayerWin.frame = self.movieView2.bounds
                playerLayerWin.videoGravity = .resizeAspectFill
                playerLayerWin.zPosition = -1
                movieView2.layer.insertSublayer(playerLayerWin, at: 0)
                winPlayer!.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeWin), name: .AVPlayerItemDidPlayToEndTime, object: winPlayer?.currentItem)
            } else {
                let pathLose = Bundle.main.path(forResource: "resultLose", ofType: "mp4")!
                losePlayer = AVPlayer(url: URL(fileURLWithPath: pathLose))
                
                let playerLayerLose = AVPlayerLayer(player: losePlayer)
                playerLayerLose.frame = self.movieView2.bounds
                playerLayerLose.videoGravity = .resizeAspectFill
                playerLayerLose.zPosition = -1
                movieView2.layer.insertSublayer(playerLayerLose, at: 0)
                losePlayer!.play()
                NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeLose), name: .AVPlayerItemDidPlayToEndTime, object: losePlayer?.currentItem)
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
        movieView2 = nil
        winPlayer = nil
        losePlayer = nil
        movieView3.isHidden = false
        let pathED = Bundle.main.path(forResource: "ED", ofType: "mp4")!
        EDPlayer = AVPlayer(url: URL(fileURLWithPath: pathED))
        
        let playerLayerED = AVPlayerLayer(player: EDPlayer)
        playerLayerED.frame = self.movieView3.bounds
        playerLayerED.videoGravity = .resizeAspectFill
        playerLayerED.zPosition = -1
        movieView3.layer.insertSublayer(playerLayerED, at: 0)
        EDPlayer!.play()
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeED), name: .AVPlayerItemDidPlayToEndTime, object: EDPlayer?.currentItem)
    }
    
    @objc func didPlayToEndTimeED() {
        movieView3.isHidden = true
        movieView3 = nil
        EDPlayer = nil
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
