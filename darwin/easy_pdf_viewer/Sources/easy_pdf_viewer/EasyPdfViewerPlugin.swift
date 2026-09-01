#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import AppKit
import FlutterMacOS
#endif
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public class EasyPdfViewerPlugin: NSObject, FlutterPlugin {

    private static let directory = "EasyPdfViewer"
    private static var fileName = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
#if os(iOS)
        let messenger = registrar.messenger()
#elseif os(macOS)
        let messenger = registrar.messenger
#endif
        let channel = FlutterMethodChannel(
            name: "easy_pdf_viewer_plugin",
            binaryMessenger: messenger
        )
        let instance = EasyPdfViewerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .default).async {
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterMethodNotImplemented)
                return
            }
            switch call.method {
            case "getPage":
                guard let pageNumber = args["pageNumber"] as? Int,
                      let filePath = args["filePath"] as? String else {
                    result(nil)
                    return
                }
                result(self.getPage(filePath, ofPage: pageNumber))
            case "getNumberOfPages":
                guard let filePath = args["filePath"] as? String else {
                    result(nil)
                    return
                }
                let clearCache = args["clearCacheDir"] as? Bool ?? false
                result(self.getNumberOfPages(filePath, clearCacheDir: clearCache))
            case "clearCacheDir":
                self.clearCacheDir()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func clearCacheDir() {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let cacheDir = paths.first else { return }
        let dir = (cacheDir as NSString).appendingPathComponent(Self.directory)
        guard FileManager.default.fileExists(atPath: dir) else { return }
        NSLog("[EasyPdfViewerPlugin] Removing old documents cache")
        do {
            try FileManager.default.removeItem(atPath: dir)
        } catch {
            NSLog("Clear directory error: \(error)")
        }
    }

    private func getNumberOfPages(_ url: String, clearCacheDir: Bool) -> String? {
        guard let sourceURL = resolveURL(url) else { return nil }
        guard let document = CGPDFDocument(sourceURL as CFURL) else { return nil }
        let numberOfPages = document.numberOfPages

        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let cacheDir = paths.first else { return nil }
        let dir = (cacheDir as NSString).appendingPathComponent(Self.directory)

        if clearCacheDir { self.clearCacheDir() }

        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        } catch {
            NSLog("Create directory error: \(error)")
            return nil
        }

        Self.fileName = UUID().uuidString
        NSLog("[EasyPdfViewerPlugin] File has \(numberOfPages) pages")
        NSLog("[EasyPdfViewerPlugin] File will be saved in cache as \(Self.fileName)")
        return "\(numberOfPages)"
    }

    private func getPage(_ url: String, ofPage pageNumber: Int) -> String? {
        guard let sourceURL = resolveURL(url) else { return nil }
        guard let document = CGPDFDocument(sourceURL as CFURL) else { return nil }
        let numberOfPages = document.numberOfPages
        let actualPage = min(pageNumber, numberOfPages)

        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let cacheDir = paths.first else { return nil }
        let dir = (cacheDir as NSString).appendingPathComponent(Self.directory)

        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        } catch {
            NSLog("Create directory error: \(error)")
            return nil
        }

        guard let page = document.page(at: actualPage) else { return nil }

        let relPath = "\(Self.directory)/\(Self.fileName)-\(actualPage).png"
        let imageFilePath = (cacheDir as NSString).appendingPathComponent(relPath)

        let sourceRect = page.getBoxRect(.mediaBox)
        let dpi: CGFloat = 300.0 / 72.0
        let width = Int(sourceRect.size.width * dpi)
        let height = Int(sourceRect.size.height * dpi)
        guard width > 0, height > 0 else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.interpolationQuality = .high
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.scaleBy(x: dpi, y: dpi)
        if sourceRect.origin.x != 0 || sourceRect.origin.y != 0 {
            context.translateBy(x: -sourceRect.origin.x, y: -sourceRect.origin.y)
        }
        context.drawPDFPage(page)

        guard let cgImage = context.makeImage() else { return nil }

        let destinationURL = URL(fileURLWithPath: imageFilePath) as CFURL
        guard let destination = CGImageDestinationCreateWithURL(destinationURL, "public.png" as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return imageFilePath
    }

    private func resolveURL(_ url: String) -> URL? {
        let prefix = "file:///"
        if url.contains(prefix) {
            return URL(string: url)
        }
        return URL(string: prefix + url)
    }
}
