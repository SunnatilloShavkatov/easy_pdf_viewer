// Objective-C view of `EasyPdfViewerApi` (EasyPdfViewerApi.swift), read by `dart run tool/ffigen.dart` and by the
// generated wrapper easy_pdf_viewer_darwin.m. It is private (not in include/), so it never clashes with the Swift
// class. Keep it identical to the Swift @objc API: selectors, parameter types and block signatures are matched at
// runtime. A ResultBlock is (value, errorCode, errorMessage, errorDetails); a non-nil errorCode marks a failure.
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasyPdfViewerApi : NSObject

+ (void)getNumberOfPages:(NSString *)filePath clearCacheDir:(BOOL)clearCacheDir callback:(void (^)(NSString *_Nullable value, NSString *_Nullable errorCode, NSString *_Nullable errorMessage, NSString *_Nullable errorDetails))callback;
+ (void)getPage:(NSString *)filePath pageNumber:(NSInteger)pageNumber callback:(void (^)(NSString *_Nullable value, NSString *_Nullable errorCode, NSString *_Nullable errorMessage, NSString *_Nullable errorDetails))callback;
+ (void)clearCacheDir:(void (^)(NSString *_Nullable value, NSString *_Nullable errorCode, NSString *_Nullable errorMessage, NSString *_Nullable errorDetails))callback;

@end

NS_ASSUME_NONNULL_END
