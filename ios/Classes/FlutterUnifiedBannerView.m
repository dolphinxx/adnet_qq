//
//  FlutterUnifiedBannerView.m
//  adnet_qq
//
//  Created by Dolphin on 2019/7/7.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterUnifiedBannerView.h"
#import "GDTUnifiedBannerView.h"
#import "PluginSettings.h"
#import "AdnetQqPlugin.h"

@implementation FlutterUnifiedBannerView {
    int64_t _viewId;
    GDTUnifiedBannerView *bv;
    FlutterMethodChannel* _channel;
    NSString *posId;
}

- (instancetype)initWithFrame:(CGRect)frame viewId:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    if([super init]) {
        NSDictionary *dict = args;
        posId = dict[@"posId"];
        _viewId = viewId;
        NSString *channelName = [NSString stringWithFormat:@"%@_%lld",[PluginSettings getInstance]->UNIFIED_BANNER_VIEW_ID,viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result){
            [weakSelf onMethodCall:call result: result];
        }];
        //bv = [[GDTUnifiedBannerView alloc] initWithFrame:frame appId:[PluginSettings getInstance]->APP_ID placementId:posId viewController:AdnetQqPlugin.getViewController];
    }
    return self;
}

- (nonnull GDTUnifiedBannerView *)getView{
    if(!bv) {
        CGRect rect = {CGPointZero, CGSizeMake(375, 60)};
        //NSLog(@"APP_ID:%@,posId:%@,viewController:%@",[PluginSettings getInstance] -> APP_ID,posId, [AdnetQqPlugin getViewController]);
        bv = [[GDTUnifiedBannerView alloc]
              initWithFrame:rect appId:[PluginSettings getInstance] -> APP_ID placementId: posId viewController:[AdnetQqPlugin getViewController]
              ];
        bv.animated = NO;
        bv.delegate = self;
    }
    return bv;
}

- (nonnull UIView *)view {
    return [self getView];
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    if([@"refresh" isEqual:call.method]) {
        [[self getView] loadAdAndShow];
        result(@(YES));
        return;
    }
    if([@"close" isEqual:call.method] && bv) {
        [bv removeFromSuperview];
        bv.delegate = nil;
        result(@(YES));
        return;
    }
}

/**
 *  请求广告条数据成功后调用
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdReceived");
    [_channel invokeMethod:@"onAdRecieved" arguments:nil];
}

/**
 *  请求广告条数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error
{
    NSLog(@"onNoAd %@", error);
    [_channel invokeMethod:@"onNoAd" arguments:nil];
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdExposure");
    [_channel invokeMethod:@"onAdExposure" arguments:nil];
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdClicked");
    [_channel invokeMethod:@"onAdClicked" arguments:nil];
}

/**
 *  banner2.0广告点击以后即将弹出全屏广告页
 */
- (void)unifiedBannerViewWillPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    
}

/**
 *  banner2.0广告点击以后弹出全屏广告页完毕
 */
- (void)unifiedBannerViewDidPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdOpenOverlay");
    [_channel invokeMethod:@"onAdOpenOverlay" arguments:nil];
}

/**
 *  全屏广告页即将被关闭
 */
- (void)unifiedBannerViewWillDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    
}

/**
 *  全屏广告页已经被关闭
 */
- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdCloseOverlay");
    [_channel invokeMethod:@"onAdCloseOverlay" arguments:nil];
}

/**
 *  当点击应用下载或者广告调用系统程序打开
 */
- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdLeftApplication");
    [_channel invokeMethod:@"onAdLeftApplication" arguments:nil];
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"onAdClosed");
    [_channel invokeMethod:@"onAdClosed" arguments:nil];
    self -> bv = nil;
}
@end

@implementation FlutterUnifiedBannerViewFactory {
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
    return [[FlutterUnifiedBannerView alloc] initWithFrame:frame viewId:viewId arguments:args binaryMessenger:_messenger];
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return FlutterStandardMessageCodec.sharedInstance;
}

@end
