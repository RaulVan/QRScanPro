import Vision
import UIKit

class QRCodeDetector {
    static func detectQRCode(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation],
                  let qrCode = results.first(where: { $0.symbology == .qr }),
                  let payload = qrCode.payloadStringValue else {
                completion(nil)
                return
            }
            
            completion(payload)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
} 