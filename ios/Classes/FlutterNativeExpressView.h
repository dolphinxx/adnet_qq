//
//  FlutterNativeExpressView.h
//  Pods
//
//  Created by Dolphin on 2019/7/8.
//

#ifndef FlutterNativeExpressView_h
#define FlutterNativeExpressView_h
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterNativeExpressView : NSObject<FlutterPlatformView>

- (instancetype)initWithFrame: (CGRect)frame
                       viewId:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;

@end

@interface FlutterNativeExpressViewFactory : NSObject<FlutterPlatformViewFactory>
- (instancetype)init:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END

#endif /* FlutterNativeExpressView_h */
