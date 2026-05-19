#import "include/EasyPdfViewerPlugin.h"
#if __has_include(<easy_pdf_viewer/easy_pdf_viewer-Swift.h>)
#import <easy_pdf_viewer/easy_pdf_viewer-Swift.h>
#else
#import "easy_pdf_viewer-Swift.h"
#endif

@implementation EasyPdfViewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftEasyPdfViewerPlugin registerWithRegistrar:registrar];
}
@end
