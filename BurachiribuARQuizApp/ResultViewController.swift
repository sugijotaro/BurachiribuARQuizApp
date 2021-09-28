
import UIKit
import SceneKit
import ARKit
import AVFoundation

class ResultViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 0
        return configuration
    }()
    
    @IBOutlet var movieView: UIView!
    
    @IBOutlet var resultView: UIView!
    @IBOutlet var scoreIntLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var endingImage: UIImageView!
    
    @IBOutlet var showResultButton: UIButton!
    
//    var menuBarButtonItem: UIBarButtonItem!
    
    var moviePlayer: AVPlayer?
    var audioPlayerInstanceDrum : AVAudioPlayer! = nil
    
    var resultScoreInt: Int = 0
    
    var isTapGestureAvailable = false
    var isResultAnnouncementFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView.isHidden = true
        endingImage.isHidden = true
        showResultButton.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "結果発表"
        
        resultScoreInt = GameService.resultScoreInt()
        print("スコア：\(resultScoreInt)/10")
        
        let stringAttributes1: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.red]
        let string1 = NSAttributedString(string: String(resultScoreInt), attributes: stringAttributes1)
        let stringAttributes2: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.black]
        let string2 = NSAttributedString(string: "／10", attributes: stringAttributes2)
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        
        scoreIntLabel.attributedText = mutableAttributedString
        
        var resultStringArray = GameService.resultBoolArray().map({ (value: Bool) -> String in
            if value {
                return "⭕️"
            }else{
                return "❌"
            }
        })
        resultLabel.text = resultStringArray.joined(separator: "\n")
        print(resultStringArray)
        
        nameLabel.text = GameService.resultName(score: resultScoreInt)
        print("称号：\(nameLabel.text)")
        
        FirebaseEventsService.result(resultBoolArray: GameService.resultBoolArray(), score: resultScoreInt)
        
        
        let soundFilePathDrum = Bundle.main.path(forResource: "drum", ofType: "mp3")!
        let soundDrum:URL = URL(fileURLWithPath: soundFilePathDrum)
        do {
            audioPlayerInstanceDrum = try AVAudioPlayer(contentsOf: soundDrum, fileTypeHint:nil)
        } catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
        audioPlayerInstanceDrum.prepareToPlay()
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
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
        print("result.mp4の再生開始")
        
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
    
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if isTapGestureAvailable{
            isTapGestureAvailable = false
            if isResultAnnouncementFinished{
                print("戻る")
                showResultButton.isEnabled = true
                resultView.isHidden = true
                endingImage.isHidden = false
            } else {
                self.resultView.isHidden = true
                self.movieView.isHidden = false
                
                if resultScoreInt >= 5{
                    let pathWin = Bundle.main.path(forResource: "resultWin", ofType: "mp4")!
                    moviePlayer = AVPlayer(url: URL(fileURLWithPath: pathWin))
                    
                    let playerLayerWin = AVPlayerLayer(player: moviePlayer)
                    playerLayerWin.frame = self.movieView.bounds
                    playerLayerWin.videoGravity = .resizeAspectFill
                    playerLayerWin.zPosition = -1
                    movieView.layer.insertSublayer(playerLayerWin, at: 0)
                    moviePlayer!.play()
                    print("resultWin.mp4の再生開始")
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
                    print("resultLose.mp4の再生開始")
                    NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeLose), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
                }
            }
        }
    }
    
    func startEndingMovie () {
        movieView.layer.sublayers = nil
        let pathED = Bundle.main.path(forResource: "ED", ofType: "mp4")!
        moviePlayer = AVPlayer(url: URL(fileURLWithPath: pathED))
        
        let playerLayerED = AVPlayerLayer(player: moviePlayer)
        playerLayerED.frame = self.movieView.bounds
        playerLayerED.videoGravity = .resizeAspectFill
        playerLayerED.zPosition = -1
        movieView.layer.insertSublayer(playerLayerED, at: 0)
        moviePlayer!.play()
        print("ED.mp4の再生開始")
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTimeED), name: .AVPlayerItemDidPlayToEndTime, object: moviePlayer?.currentItem)
    }
    
    @objc func didPlayToEndTime() {
        print("result.mp4の再生終了")
        movieView.isHidden = true
        movieView.layer.sublayers = nil
        audioPlayerInstanceDrum.play()
        print("ドラムロール再生開始")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("ドラムロール再生終了")
            self.resultView.isHidden = false
            self.isTapGestureAvailable = true
        }
    }
    
    @objc func didPlayToEndTimeWin() {
        print("resultWin.mp4の再生終了")
        startEndingMovie()
    }
    
    @objc func didPlayToEndTimeLose() {
        print("resultLose.mp4の再生終了")
        startEndingMovie()
    }
    
    @objc func didPlayToEndTimeED() {
        print("ED.mp4の再生終了")
        isResultAnnouncementFinished = true
        movieView.isHidden = true
        moviePlayer!.replaceCurrentItem(with: nil)
        endingImage.isHidden = false
        showResultButton.isHidden = false
//        menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "Image"), style: .plain, target: self, action: #selector(menuButtonTapped(_:)))
//        self.navigationItem.setLeftBarButtonItems([menuBarButtonItem], animated: true)
    }
    
    @IBAction func showResultButtonTapped() {
        print("結果発表画面表示")
        resultView.isHidden = false
        endingImage.isHidden = true
        showResultButton.isEnabled = false
        isTapGestureAvailable = true
    }
    
//    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
//        let toTutorial = UIAlertAction(title: "チュートリアルに戻る", style: .default) { _ in
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//        alert.addAction(toTutorial)
//
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction) in
//            })
//        }
//
//        alert.popoverPresentationController?.sourceView = view
//        alert.popoverPresentationController?.barButtonItem = menuBarButtonItem
//        self.present(alert, animated: true, completion: nil)
//    }
    
    private func freeMemory(){
        print("メモリ解放")
        movieView.removeFromSuperview()
        movieView = nil
        moviePlayer!.replaceCurrentItem(with: nil)
    }

}
