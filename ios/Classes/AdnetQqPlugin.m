#import "AdnetQqPlugin.h"
#import "PluginSettings.h"
#import "FlutterUnifiedBannerView.h"
#import "FlutterNativeExpressView.h"
#import "FlutterSplashView.h"
#import "FlutterUnifiedInterstitialView.h"
#import <Flutter/Flutter.h>
#import "GDTSDKConfig.h"
static NSObject<FlutterPluginRegistrar> *_registrar = nil;
static NSMutableDictionary<NSString*, FlutterUnifiedInterstitialView*> *interstitials = nil;

@implementation AdnetQqPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    _registrar = registrar;
  interstitials = [[NSMutableDictionary alloc] init];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:[PluginSettings getInstance] -> PLUGIN_ID
            binaryMessenger:[registrar messenger]];
  AdnetQqPlugin* instance = [[AdnetQqPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    FlutterUnifiedBannerViewFactory *unifiedBannerViewFactory = [[FlutterUnifiedBannerViewFactory alloc] init:registrar.messenger];
    [registrar registerViewFactory:unifiedBannerViewFactory withId:[PluginSettings getInstance] -> UNIFIED_BANNER_VIEW_ID];
    FlutterNativeExpressViewFactory *nativeExpressViewFactory = [[FlutterNativeExpressViewFactory alloc] init:registrar.messenger];
    [registrar registerViewFactory:nativeExpressViewFactory withId:[PluginSettings getInstance] -> NATIVE_EXPRESS_VIEW_ID];
}

+ (UIViewController*)getViewController{
    return UIApplication.sharedApplication.keyWindow.rootViewController;
}

+ (void)removeInterstitial:(NSString*)posId {
    [interstitials removeObjectForKey:posId];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"config" isEqualToString:call.method]) {
      NSDictionary* arguments = call.arguments;
      if([arguments[@"appId"] isEqual: [NSNull null]]) {
          result(@(NO));
          return;
      }
      [PluginSettings getInstance] -> APP_ID = arguments[@"appId"];
      [GDTSDKConfig registerAppId:arguments[@"appId"]];
      if(arguments[@"adChannel"] && ![arguments[@"adChannel"] isEqual:[NSNull null]]) {
          NSNumber *_channel = arguments[@"adChannel"];
          [GDTSDKConfig setChannel:_channel.integerValue];
      }
      result(@(YES));
  } else if([@"showSplash" isEqualToString:call.method]){
      NSDictionary* arguments = call.arguments;
      NSString* posId = arguments[@"posId"];
      NSString* backgroundImage = arguments[@"backgroundImage"];
      [[[FlutterSplashView alloc] init:posId backgroundImage:backgroundImage binaryMessenger:_registrar.messenger] show];
      result(@(YES));
  } else if([@"closeSplash"isEqualToString:call.method]) {
      result(@(YES));
  } else if([@"createUnifiedInterstitialAd" isEqualToString:call.method]) {
      NSDictionary* arguments = call.arguments;
      NSString* posId = arguments[@"posId"];
      if(interstitials[posId]) {
          [interstitials[posId] close];
      }
      interstitials[posId] = [[FlutterUnifiedInterstitialView alloc] init:posId binaryMessenger:_registrar.messenger];
      result(@(YES));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
