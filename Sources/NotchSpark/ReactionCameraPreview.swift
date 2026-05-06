import AVFoundation
import SwiftUI

struct ReactionCameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.updateMirroring()
        return view
    }

    func updateNSView(_ nsView: PreviewView, context: Context) {
        nsView.previewLayer.session = session
        nsView.updateMirroring()
    }

    final class PreviewView: NSView {
        let previewLayer = AVCaptureVideoPreviewLayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer = previewLayer
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.masksToBounds = true
        }

        required init?(coder: NSCoder) {
            nil
        }

        override func layout() {
            super.layout()
            previewLayer.frame = bounds
            previewLayer.cornerRadius = min(bounds.width, bounds.height) / 2
            updateMirroring()
        }

        func updateMirroring() {
            guard let connection = previewLayer.connection else {
                return
            }

            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
    }
}
