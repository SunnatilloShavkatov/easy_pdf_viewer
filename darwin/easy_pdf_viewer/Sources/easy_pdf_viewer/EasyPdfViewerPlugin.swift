import Foundation
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/// Registration only: Dart calls `EasyPdfViewerApi` through the Objective-C runtime, so there is no channel to set
/// up. The class stays because Flutter's plugin registrant needs one.
public class EasyPdfViewerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {}
}
