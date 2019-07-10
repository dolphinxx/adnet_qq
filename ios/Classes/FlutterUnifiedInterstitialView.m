//
//  FlutterUnifiedInterstitialView.m
//  adnet_qq
//
//  Created by Dolphin on 2019/7/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "GDTUnifiedInterstitialAd.h"
#import "FlutterUnifiedInterstitialView.h"
#import "PluginSettings.h"

@implementation FlutterUnifiedInterstitialView{
    NSString *posId;
    FlutterMethodChannel *_channel;
}

- (instancetype)init:posId binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    if([super init]) {
        self->posId = posId;
        NSString *channelName = [NSString stringWithFormat:@"%@_%@",[PluginSettings getInstance]->UNIFIED_INTERSTITIAL_VIEW_ID, posId];
        NSLog(@"----channelName:%@",channelName);
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result){
            [weakSelf onMethodCall:call result: result];
        }];
        NSLog(@"----init");
    }
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSLog(@"----onMethodCall");
    if([@"load" isEqualToString:call.method]) {
        [self loadAd];
        result(@(YES));
    } else if([@"show" isEqual:call.method] || [@"popup" isEqualToString:call.method]) {
        [self show];
        result(@(YES));
    } else if([@"close" isEqualToString:call.method]) {
        [self close];
        result(@(YES));
    }
}

- (void)loadAd{
    if (self.ad) {
        self.ad.delegate = nil;
    }
    self.ad = [[GDTUnifiedInterstitialAd alloc] initWithAppId:[PluginSettings getInstance] -> APP_ID placementId:posId];
    self.ad.delegate = self;
    [self.ad loadAd];
}

- (void)show {
    [self.ad presentAdFromRootViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
}

- (void)close{
    self.ad.delegate = nil;
}

/**
 *  插屏2.0广告预加载成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdReceived");
    [_channel invokeMethod:@"onAdReceived" arguments:nil];
}

/**
 *  插屏2.0广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error{
    NSLog(@"onNoAd %@",error);
    [_channel invokeMethod:@"onNoAd" arguments:nil];
}

/**
 *  插屏2.0广告将要展示回调
 *  插屏2.0广告即将展示回调该函数
 */
- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdWillPresentScreen");
}

/**
 *  插屏2.0广告视图展示成功回调
 *  插屏2.0广告展示成功回调该函数
 */
- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdDidPresentScreen");
}

/**
 *  插屏2.0广告展示结束回调
 *  插屏2.0广告展示结束回调该函数
 */
- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdClosed");
    [_channel invokeMethod:@"onAdClosed" arguments:nil];
}

/**
 *  当点击下载应用时会调用系统程序打开其它App或者Appstore时回调
 */
- (void)unifiedInterstitialWillLeaveApplication:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdLeftApplication");
    [_channel invokeMethod:@"onAdLeftApplication" arguments:nil];
}

/**
 *  插屏2.0广告曝光回调
 */
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdExposure");
    [_channel invokeMethod:@"onAdExposure" arguments:nil];
}

/**
 *  插屏2.0广告点击回调
 */
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdClicked");
    [_channel invokeMethod:@"onAdClicked" arguments:nil];
}

/**
 *  点击插屏2.0广告以后即将弹出全屏广告页
 */
- (void)unifiedInterstitialAdWillPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdWillPresentFullScreenModal");
}

/**
 *  点击插屏2.0广告以后弹出全屏广告页
 */
- (void)unifiedInterstitialAdDidPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdOpened");
    [_channel invokeMethod:@"onAdOpened" arguments:nil];
}

/**
 *  全屏广告页将要关闭
 */
- (void)unifiedInterstitialAdWillDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdWillDismissFullScreenModal");
}

/**
 *  全屏广告页被关闭
 */
- (void)unifiedInterstitialAdDidDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"onAdDidDismissFullScreenModal");
}
@end
