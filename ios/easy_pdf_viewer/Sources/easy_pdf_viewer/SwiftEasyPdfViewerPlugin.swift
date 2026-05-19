import Flutter
import UIKit

@objc public class SwiftEasyPdfViewerPlugin: NSObject, FlutterPlugin {

    private static let directory = "EasyPdfViewer"
    private static var fileName = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "easy_pdf_viewer_plugin",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftEasyPdfViewerPlugin()
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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let docs = paths.first else { return }
        let dir = (docs as NSString).appendingPathComponent(Self.directory)
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
        let width = sourceRect.size.width * dpi
        let height = sourceRect.size.height * dpi

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.interpolationQuality = .high
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        context.fill(context.boundingBoxOfClipPath)
        context.translateBy(x: 0.0, y: height)
        context.scaleBy(x: dpi, y: -dpi)
        context.saveGState()
        context.drawPDFPage(page)
        context.restoreGState()

        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let pngData = image.pngData() else { return nil }
        try? pngData.write(to: URL(fileURLWithPath: imageFilePath), options: .atomic)
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
