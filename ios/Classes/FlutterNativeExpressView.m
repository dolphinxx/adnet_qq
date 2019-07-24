//
//  FlutterNativeExpressView.m
//  adnet_qq
//
//  Created by Dolphin on 2019/7/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterNativeExpressView.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "PluginSettings.h"
#import "AdnetQqPlugin.h"

@implementation FlutterNativeExpressViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)init:(NSObject<FlutterBinaryMessenger>*) messenger
{
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    return [[FlutterNativeExpressView alloc] initWithFrame:frame viewId:viewId arguments:args binaryMessenger:_messenger];
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return FlutterStandardMessageCodec.sharedInstance;
}

@end

@implementation FlutterNativeExpressView {
    int64_t _viewId;
    GDTNativeExpressAdView *adv;
    GDTNativeExpressAd *ad;
    FlutterMethodChannel* _channel;
    NSString *posId;
    UIView *container;
    NSInteger count;
}

- (instancetype)initWithFrame:(CGRect)frame viewId:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    if([super init]) {
        NSDictionary *dict = args;
        posId = dict[@"posId"];
        if(dict[@"count"] && ![dict[@"count"] isEqual:[NSNull null]]) {
            NSNumber *_count = dict[@"count"];
            count = _count.integerValue;
        } else {
            count = 5;
        }
        _viewId = viewId;
        container = [[UIView alloc] initWithFrame:frame];
        NSString *channelName = [NSString stringWithFormat:@"%@_%lld",[PluginSettings getInstance]->NATIVE_EXPRESS_VIEW_ID,viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result){
            [weakSelf onMethodCall:call result: result];
        }];
        NSLog(@"----initWithFrame %@",posId);
    }
    return self;
}

- (nonnull UIView *)view {
    //NSLog(@"----view %@",posId);
    return container;
}

- (void)refreshAd{
    //NSLog(@"----refreshAd");
    ad = [[GDTNativeExpressAd alloc]
          initWithAppId: [PluginSettings getInstance] -> APP_ID placementId: posId adSize:CGSizeMake(UIApplication.sharedApplication.keyWindow.frame.size.width, -2) ];
    ad.delegate = self;
    [ad loadAd:count];
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    //NSLog(@"----onMethodCall");
    if([@"refresh" isEqual:call.method]) {
        [self refreshAd];
        result(@(YES));
        return;
    }
    if([@"close" isEqual:call.method] && adv) {
        [adv removeFromSuperview];
        ad.delegate = nil;
        adv = nil;
        result(@(YES));
        return;
    }
    result(FlutterMethodNotImplemented);
}

/**
 * 拉取原生模板广告成功
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSMutableArray<__kindof GDTNativeExpressAdView *> *)views{
    NSLog(@"onAdLoaded");
    [_channel invokeMethod:@"onAdLoaded" arguments:nil];
    if(adv) {
        [adv removeFromSuperview];
    }
    adv = views[0];
    adv.controller = [AdnetQqPlugin getViewController];
    [adv render];
    [container addSubview:adv];
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error{
    NSLog(@"%@", [NSString stringWithFormat:@"onNoAd %@",error]);
    [_channel invokeMethod:@"onNoAd" arguments:nil];
}

/**
 * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
 */
- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onRenderSuccess");
    [_channel invokeMethod:@"onRenderSuccess" arguments:nil];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:[NSNumber numberWithDouble:adv.bounds.size.width] forKey:@"width"];
    [params setValue:[NSNumber numberWithDouble:adv.bounds.size.height] forKey:@"height"];
    [_channel invokeMethod:@"onLayout" arguments:params];
}

/**
 * 原生模板广告渲染失败
 */
- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onRenderFail");
    [_channel invokeMethod:@"onRenderFail" arguments:nil];
}

/**
 * 原生模板广告曝光回调
 */
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdExposure");
    [_channel invokeMethod:@"onAdExposure" arguments:nil];
}

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdClicked");
    [_channel invokeMethod:@"onAdClicked" arguments:nil];
}

/**
 * 原生模板广告被关闭
 */
- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdClosed");
    [_channel invokeMethod:@"onAdClosed" arguments:nil];
    [adv removeFromSuperview];
    adv = nil;
}

/**
 * 点击原生模板广告以后即将弹出全屏广告页
 */
- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdOpenOverlay");
    [_channel invokeMethod:@"onAdOpenOverlay" arguments:nil];
}

/**
 * 点击原生模板广告以后弹出全屏广告页
 */
- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdDidPresentScreen");
}

/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewWillDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdWillDismissScreen");
}

/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewDidDissmissScreen:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdCloseOverlay");
    [_channel invokeMethod:@"onAdCloseOverlay" arguments:nil];
}

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)nativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdLeftApplication");
    [_channel invokeMethod:@"onAdLeftApplication" arguments:nil];
}

/**
 * 原生模板视频广告 player 播放状态更新回调
 */
- (void)nativeExpressAdView:(GDTNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status{
    NSLog(@"onAdPlayerStatusChanged");
}

/**
 * 原生视频模板详情页 WillPresent 回调
 */
- (void)nativeExpressAdViewWillPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdWillPresentVideoVC");
}

/**
 * 原生视频模板详情页 DidPresent 回调
 */
- (void)nativeExpressAdViewDidPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdDidPresentVideoVC");
}

/**
 * 原生视频模板详情页 WillDismiss 回调
 */
- (void)nativeExpressAdViewWillDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdWillDismissVideoVC");
}

/**
 * 原生视频模板详情页 DidDismiss 回调
 */
- (void)nativeExpressAdViewDidDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView{
    NSLog(@"onAdDidDismissVideoVC");
}

@end
