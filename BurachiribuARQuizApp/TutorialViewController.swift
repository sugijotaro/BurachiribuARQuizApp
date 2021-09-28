
import UIKit
import SceneKit
import ARKit
import AVFoundation

class TutorialViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    let imageConfiguration = ARImageTrackingConfiguration()
    let imageConfiguration1 = ARImageTrackingConfiguration()
    
    @IBOutlet var actionButon: UIBarButtonItem!
    
    @IBOutlet var slideImageView: UIImageView!
    
    private var avPlayer: AVPlayer?
    
    private var slideCount: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        slideImageView.isHidden = false
        slideImageView.image = UIImage(named: "slide1")
        
        self.navigationItem.title = "チュートリアル"
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        
        avPlayer = AVPlayer(url: Bundle.main.url(forResource: "tutorial", withExtension: "mp4")!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        imageConfiguration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-tutorial", bundle: nil)!
        imageConfiguration.maximumNumberOfTrackedImages = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(imageConfiguration1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView?.session.pause()
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    
    @IBAction func menuButton () {
        let alert = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        let toTutorial = UIAlertAction(title: "ARトラッキング素材をダウンロードする", style: .default) { _ in
            let url = URL(string: "https://drive.google.com/drive/folders/1MrIoVWPqcHykcmGArWzKvkz3fV2dVHnU?usp=sharing")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                FirebaseEventsService.ARDownloadEvent()
            }
        }
        alert.addAction(toTutorial)
        
        //デバッグ用
        let skipTutorial = UIAlertAction(title: "チュートリアルスキップ", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "toQuizView", sender: nil)
            self.freeMemory()
        })
        alert.addAction(skipTutorial)

        let toResult = UIAlertAction(title: "結果", style: .default, handler: { _ in
            UserDefaults(suiteName: "group.com.burachiribu")!.set([2,1,1,1,1,1,1,1,1,1,1], forKey: "scoreData")
            self.performSegue(withIdentifier: "toResult", sender: nil)
            self.freeMemory()
        })
        alert.addAction(toResult)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction) in
            })
        }
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.barButtonItem = actionButon
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func leftswipe(){
        if slideCount == 2{
            slideCount = 1
            showImageView()
        }else if slideCount == 3{
            slideCount = 2
            showImageView()
            sceneView.session.run(imageConfiguration1)
        }
    }
    
    @IBAction func rightswipe(){
        if slideCount == 1{
            slideCount = 2
            showImageView()
        }else if slideCount == 2{
            slideCount = 3
            showImageView()
            sceneView.session.run(imageConfiguration)
        }
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if slideCount == 1{
            slideCount = 2
            showImageView()
        }else if slideCount == 2{
            slideCount = 3
            showImageView()
            sceneView.session.run(imageConfiguration)
        }
    }
    
    private func showImageView(){
        switch slideCount {
        case 1:
            slideImageView.isHidden = false
            autoreleasepool {
                slideImageView.image = UIImage(named: "slide1")
            }
        case 2:
            slideImageView.isHidden = false
            autoreleasepool {
                slideImageView.image = UIImage(named: "slide2")
            }
        case 3:
            slideImageView.isHidden = true
        default: break
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
        
        print(slideCount)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let skScene = SKScene(size: CGSize(width: CGFloat(1000), height: CGFloat(1000)))
            
            NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
            
            let skNode = SKVideoNode(avPlayer: avPlayer!)
            skNode.position = CGPoint(x: skScene.size.width / 2.0, y: skScene.size.height / 2.0)
            skNode.size = skScene.size
            skNode.yScale = -1.0
            skNode.play()
            skScene.addChild(skNode)
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = skScene
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            slideCount = 4
            
            FirebaseEventsService.tutorialBegin()
        }
        return node
    }
    
    @objc func didPlayToEndTime() {
        print("動画再生終了")
        avPlayer?.pause()
        
        FirebaseEventsService.tutorialComplete()
        
        freeMemory()
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "toQuizView", sender: nil)
    }
    
    
    private func freeMemory(){
        sceneView.removeFromSuperview()
        sceneView = nil
        slideImageView.image = nil
        avPlayer!.replaceCurrentItem(with: nil)
    }
    
}
