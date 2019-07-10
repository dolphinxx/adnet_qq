//
//  FlutterUnifiedBannerView.h
//  Pods
//
//  Created by Dolphin on 2019/7/7.
//

#ifndef FlutterUnifiedBannerView_h
#define FlutterUnifiedBannerView_h

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "GDTUnifiedBannerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterUnifiedBannerView : NSObject<FlutterPlatformView>

- (instancetype)initWithFrame: (CGRect)frame
                       viewId:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;

@end

@interface FlutterUnifiedBannerViewFactory : NSObject<FlutterPlatformViewFactory>
- (instancetype)init:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END


#endif /* FlutterUnifiedBannerView_h */
