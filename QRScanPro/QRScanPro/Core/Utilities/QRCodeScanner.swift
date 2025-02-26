import AVFoundation
import UIKit

class QRCodeScanner: NSObject, ObservableObject {
    @Published var scannedCodes: [QRCodeResult] = []
    @Published var error: Error?
    @Published var isFlashOn = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDevice: AVCaptureDevice?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video device found"])
            return
        }
        
        self.videoDevice = videoCaptureDevice
        
        do {
            // 配置设备以获得最佳性能
            try configureDevice(videoCaptureDevice)
            
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
            
            self.captureSession = captureSession
            
            // 初始化和配置预览层
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            
            // 设置视频方向为横向
            if #available(iOS 17.0, *) {
                previewLayer.connection?.videoRotationAngle = 90 // 90度表示横向
            } else {
                previewLayer.connection?.videoOrientation = .landscapeRight
            }
            
            self.previewLayer = previewLayer
            
            // 开始会话
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        } catch {
            self.error = error
        }
    }
    
    private func configureDevice(_ device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        
        // 启用连续自动对焦
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        // 启用连续自动曝光
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        
        // 启用自动白平衡
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            device.whiteBalanceMode = .continuousAutoWhiteBalance
        }
        
        // 设置最小帧率
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30)
        // device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
        
        device.unlockForConfiguration()
    }
    
    func start() {
        if captureSession == nil {
            setupCaptureSession()
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
                
                DispatchQueue.main.async {
                    self?.error = nil
                }
            }
        }
    }
    
    func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    func toggleFlash() {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    isFlashOn = true
                } else {
                    device.torchMode = .off
                    isFlashOn = false
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            self.error = error
        }
    }
    
    // 手动触发对焦
    func focus(at point: CGPoint) {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
            // 2秒后恢复连续自动对焦
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.resetFocus()
            }
        } catch {
            self.error = error
        }
    }
    
    private func resetFocus() {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
        } catch {
            self.error = error
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    func clearScannedCodes() {
        scannedCodes.removeAll()
    }
    
    func convertToViewCoordinates(_ bounds: CGRect) -> CGRect? {
        guard let previewLayer = self.previewLayer else { return nil }
        return previewLayer.layerRectConverted(fromMetadataOutputRect: bounds)
    }
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 创建新的扫描结果数组
        var newCodes: [QRCodeResult] = []
        
        // 处理所有检测到的二维码
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { continue }
            
            // 转换二维码在预览图层中的位置
            if let transformedObject = previewLayer?.transformedMetadataObject(for: readableObject) as? AVMetadataMachineReadableCodeObject {
                let qrCode = QRCodeResult(
                    content: stringValue,
                    bounds: transformedObject.bounds
                )
                newCodes.append(qrCode)
            }
        }
        
        // 比较新旧扫描结果的内容
        let shouldUpdate = shouldUpdateScannedCodes(newCodes: newCodes, oldCodes: scannedCodes)
        
        if shouldUpdate {
            DispatchQueue.main.async { [weak self] in
                self?.scannedCodes = newCodes
            }
        }
    }
    
    // 比较新旧扫描结果，只比较内容而不是位置
    private func shouldUpdateScannedCodes(newCodes: [QRCodeResult], oldCodes: [QRCodeResult]) -> Bool {
        guard newCodes.count == oldCodes.count else { return true }
        
        let newContents = Set(newCodes.map { $0.content })
        let oldContents = Set(oldCodes.map { $0.content })
        
        return newContents != oldContents
    }
}
