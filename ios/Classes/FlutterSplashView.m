//
//  FlutterSplashView.m
//  adnet_qq
//
//  Created by Dolphin on 2019/7/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterSplashView.h"
#import "GDTSplashAd.h"
#import "PluginSettings.h"
#import "AdnetQqPlugin.h"

@implementation FlutterSplashView {
    NSString *posId;
    FlutterMethodChannel *_channel;
    //UIImageView *bg;
}

- (instancetype)init:posId backgroundImage:(NSString*)backgroundImage binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    if([super init]) {
        self->posId = posId;
        NSString *channelName = [PluginSettings getInstance]->SPLASH_VIEW_ID;
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result){
            [weakSelf onMethodCall:call result: result];
        }];
        //UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow;
        //bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width, mainWindow.frame.size.height)];
        //bg.backgroundColor = [UIColor whiteColor];
        //NSLog(@"----backgroundImage: %@",backgroundImage);
        //if(backgroundImage) {
        //    bg.image = [UIImage imageNamed:backgroundImage];
        //}
        //[mainWindow addSubview:bg];
        NSLog(@"----initWithFrame");
    }
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSLog(@"----onMethodCall");
    if([@"show" isEqual:call.method]) {
        [self showAd];
        result(@(YES));
        return;
    }
}

- (void)showAd{
    NSLog(@"----showAd");
    if(_splash) {
        return;
    }
    _splash = [[GDTSplashAd alloc] initWithAppId:[PluginSettings getInstance] -> APP_ID placementId: posId];
    _splash.delegate = self;
    _splash.fetchDelay = 3;
    [_splash loadAdAndShowInWindow:UIApplication.sharedApplication.keyWindow];
}

- (void)show{
    [self showAd];
}

- (void)close{
    [self removeAd];
}

- (void)removeAd{
    //[bg removeFromSuperview];
//    [UIApplication.sharedApplication.keyWindow makeKeyAndVisible];
    _splash.delegate = nil;
}

/**
 *  开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd{
    NSLog(@"onAdPresent");
    [_channel invokeMethod:@"onAdPresent" arguments:nil];
}

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error{
    NSLog(@"onNoAd %@", error);
    [self removeAd];
    [_channel invokeMethod:@"onNoAd" arguments:nil];
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd{
    NSLog(@"onAdApplicationWillEnterBackground");
}

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(GDTSplashAd *)splashAd{
    NSLog(@"onAdExposure");
    [_channel invokeMethod:@"onAdExposure" arguments:nil];
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd;{
    NSLog(@"onAdClicked");
    [_channel invokeMethod:@"onAdClicked" arguments:nil];
}

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd{
    NSLog(@"onAdWillClosed");
}

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(GDTSplashAd *)splashAd{
    NSLog(@"onAdClosed");
    [self removeAd];
    [_channel invokeMethod:@"onAdClosed" arguments:nil];
}

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"onAdWillPresentFullScreenModal");
}

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"onAdDidPresentFullScreenModal");
}

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"onAdWillDismissFullScreenModal");
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"onAdDismiss");
    [self removeAd];
    [_channel invokeMethod:@"onAdDismiss" arguments:nil];
}

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time{
    //NSLog(@"onAdLifeTime");
}

@end
