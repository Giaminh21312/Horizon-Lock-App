import UIKit
import AVFoundation
import CoreVideo

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CameraViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: CALayer?
    private var isHorizonLocked = true
    private var targetFPS = 60
    
    private let horizonButton = UIButton()
    private let fpsButton = UIButton()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }

    private func setupUI() {
        statusLabel.frame = CGRect(x: 0, y: 40, width: view.bounds.width, height: 30)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .yellow
        statusLabel.font = .systemFont(ofSize: 14, weight: .bold)
        statusLabel.text = "S26 ULTRA MODE: ACTIVE"
        view.addSubview(statusLabel)

        horizonButton.frame = CGRect(x: 50, y: view.bounds.height - 100, width: 140, height: 50)
        horizonButton.backgroundColor = .systemBlue
        horizonButton.setTitle("Horizon: ON", for: .normal)
        horizonButton.layer.cornerRadius = 10
        horizonButton.addTarget(self, action: #selector(toggleHorizon), for: .touchUpInside)
        view.addSubview(horizonButton)

        fpsButton.frame = CGRect(x: view.bounds.width - 190, y: view.bounds.height - 100, width: 140, height: 50)
        fpsButton.backgroundColor = .systemRed
        fpsButton.setTitle("FPS: 60", for: .normal)
        fpsButton.layer.cornerRadius = 10
        fpsButton.addTarget(self, action: #selector(toggleFPS), for: .touchUpInside)
        view.addSubview(fpsButton)
    }

    @objc private func toggleHorizon() {
        isHorizonLocked.toggle()
        horizonButton.setTitle(isHorizonLocked ? "Horizon: ON" : "Horizon: OFF", for: .normal)
        horizonButton.backgroundColor = isHorizonLocked ? .systemBlue : .darkGray
        animateCrop(isLocked: isHorizonLocked)
    }

    @objc private func toggleFPS() {
        targetFPS = (targetFPS == 60) ? 30 : 60
        fpsButton.setTitle("FPS: \(targetFPS)", for: .normal)
        configureCameraFPS(fps: Double(targetFPS))
    }

    private func animateCrop(isLocked: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        previewLayer?.contentsRect = isLocked ? 
            CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8) : 
            CGRect(x: 0, y: 0, width: 1, height: 1)
        CATransaction.commit()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .hd1920x1080

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else { return }

        if captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession!.canAddOutput(videoOutput) {
            captureSession!.addOutput(videoOutput)
        }

        previewLayer = CALayer()
        previewLayer?.frame = view.layer.bounds
        previewLayer?.contentsGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer!, at: 0)

        DispatchQueue.global().async {
            self.captureSession?.startRunning()
            self.configureCameraFPS(fps: 60)
        }
    }

    private func configureCameraFPS(fps: Double) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        try? device.lockForConfiguration()
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(fps))
        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(fps))
        device.unlockForConfiguration()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        DispatchQueue.main.async {
            if self.isHorizonLocked {
                self.previewLayer?.transform = CATransform3DMakeRotation(0, 0, 0, 1)
            } else {
                self.previewLayer?.transform = CATransform3DIdentity
            }
            
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                self.previewLayer?.contents = cgImage
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}