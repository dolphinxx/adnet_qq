//
//  FlutterSplashView.h
//  Pods
//
//  Created by Dolphin on 2019/7/8.
//

#ifndef FlutterSplashView_h
#define FlutterSplashView_h

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "GDTSplashAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterSplashView : NSObject<GDTSplashAdDelegate>

@property (strong, nonatomic) GDTSplashAd *splash;

- (instancetype)init:(NSString *)posId backgroundImage:(NSString *)backgroundImage
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)show;
- (void)close;
@end

NS_ASSUME_NONNULL_END

#endif /* FlutterSplashView_h */
