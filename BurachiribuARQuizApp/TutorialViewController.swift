

import UIKit
import SceneKit
import ARKit
import AVFoundation

class TutorialViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var slide :UIImageView!
    @IBOutlet var SlideView :UIView!
    
    @IBOutlet var actionButon: UIBarButtonItem!
    
    var menu: Int = 0
    
    var slideCount : Int = 1
    private var TutorialNode1: SCNNode?
    
    var avPlayer: AVPlayer?
    
    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-tutorial", bundle: nil)
        configuration.trackingImages = images!
        configuration.maximumNumberOfTrackedImages = 3
        return configuration
    }()
    
    let imageConfiguration1: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-tutorial", bundle: nil)
        //        configuration.trackingImages = images!
        configuration.maximumNumberOfTrackedImages = 3
        return configuration
    }()
    
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        slide.isHidden = false
        SlideView.isHidden = false
        autoreleasepool {
            slide.image = UIImage(named: "slide1")
        }
        
        self.navigationItem.title = "チュートリアル"
        
        avPlayer = AVPlayer(url: Bundle.main.url(forResource: "tutorial", withExtension: "mp4")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(imageConfiguration1)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView?.session.pause()
    }
    
    @objc func didPlayToEndTime() {
        // 再生が終了したら呼ばれる
        print("動画再生終了")
        avPlayer?.pause()
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "toQ1", sender: nil)
        segue()
    }
    
    
    @IBAction func menuButton () {
        let alert = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        let toTutorial = UIAlertAction(title: "ARトラッキング素材をダウンロードする", style: .default) { _ in
            let url = URL(string: "https://drive.google.com/drive/folders/1MrIoVWPqcHykcmGArWzKvkz3fV2dVHnU?usp=sharing")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        
        alert.addAction(toTutorial)
        
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.barButtonItem = actionButon
        //        // ここで表示位置を調整
        //        // xは画面中央、yは画面下部になる様に指定
        self.present(alert, animated: true, completion: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            
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
            
            slideCount = 4
            
        }
        return node
    }
    
    @IBAction func leftswipe (){
        if slideCount == 2{
            slideCount = 1
            showImageView()
        }else if slideCount == 3{
            slideCount = 2
            showImageView()
            TutorialNode1?.isHidden = true
            sceneView.session.run(imageConfiguration1)
        }
    }
    
    @IBAction func rightswipe (){
        if slideCount == 1{
            slideCount = 2
            showImageView()
        }else if slideCount == 2{
            slideCount = 3
            showImageView()
            sceneView.session.run(imageConfiguration)
            TutorialNode1?.isHidden = false
        }
    }
    
    @IBAction func touch (){
        if slideCount == 1{
            slideCount = 2
            showImageView()
        }else if slideCount == 2{
            slideCount = 3
            showImageView()
            sceneView.session.run(imageConfiguration)
            TutorialNode1?.isHidden = false
        }
    }
    
    func showImageView(){
        if slideCount == 1 {
            slide.isHidden = false
            SlideView.isHidden = false
            autoreleasepool {
                slide.image = UIImage(named: "slide1")
            }
        }else if slideCount == 2 {
            slide.isHidden = false
            SlideView.isHidden = false
            autoreleasepool {
                slide.image = UIImage(named: "slide2")
            }
        }else if slideCount == 3 {
            slide.isHidden = true
            SlideView.isHidden = true
        }
        
        if status == AVAuthorizationStatus.denied {
            let title: String = "カメラの使用が許可されていません。"
            let message: String = "カメラへのアクセスを許可してください。"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            })
            let closeAction: UIAlertAction = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        print(slideCount)
    }
    
    func segue(){
        slide.image = nil
        avPlayer = nil
        sceneView.removeFromSuperview()
        sceneView = nil
        print("nilにした")
    }
    
}

