//
//  FlutterUnifiedInterstitialView.h
//  Pods
//
//  Created by Dolphin on 2019/7/8.
//

#ifndef FlutterUnifiedInterstitialView_h
#define FlutterUnifiedInterstitialView_h

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "GDTUnifiedInterstitialAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterUnifiedInterstitialView : NSObject<GDTUnifiedInterstitialAdDelegate>

@property (strong, nonatomic) GDTUnifiedInterstitialAd *ad;

- (instancetype)init:(NSString *)posId binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)show;
- (void)close;
@end

NS_ASSUME_NONNULL_END

#endif /* FlutterUnifiedInterstitialView_h */
