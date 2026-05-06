import AVFoundation
import Foundation

final class ReactionCameraManager {
    private let sessionQueue = DispatchQueue(label: "com.ibraheemganayim.notchspark.reaction-camera")
    private let captureSession = AVCaptureSession()
    private var isConfigured = false
    private var configurationFailed = false

    var session: AVCaptureSession {
        captureSession
    }

    var canShowPreview: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
            && AVCaptureDevice.default(for: .video) != nil
            && !configurationFailed
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            preparePreview(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }

                self.preparePreview(completion: completion)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func preparePreview(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            let canShow = self.configureIfNeeded()
            DispatchQueue.main.async {
                completion(canShow)
            }
        }
    }

    func startSessionIfNeeded() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            return
        }

        sessionQueue.async { [weak self] in
            guard let self, self.configureIfNeeded(), !self.captureSession.isRunning else {
                return
            }

            self.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else {
                return
            }

            self.captureSession.stopRunning()
        }
    }

    private func configureIfNeeded() -> Bool {
        if isConfigured {
            return true
        }

        if configurationFailed {
            return false
        }

        guard let device = AVCaptureDevice.default(for: .video) else {
            configurationFailed = true
            return false
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .low

            guard captureSession.canAddInput(input) else {
                captureSession.commitConfiguration()
                configurationFailed = true
                return false
            }

            captureSession.addInput(input)
            captureSession.commitConfiguration()
            isConfigured = true
            return true
        } catch {
            configurationFailed = true
            return false
        }
    }
}
