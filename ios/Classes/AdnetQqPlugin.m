#import "AdnetQqPlugin.h"
#import "PluginSettings.h"
#import "FlutterUnifiedBannerView.h"
#import "FlutterNativeExpressView.h"
#import "FlutterSplashView.h"
#import "FlutterUnifiedInterstitialView.h"
#import <Flutter/Flutter.h>
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

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"config" isEqualToString:call.method]) {
      NSDictionary* arguments = call.arguments;
      if([arguments[@"appId"] isEqual: [NSNull null]]) {
          result(@(NO));
          return;
      }
      [PluginSettings getInstance] -> APP_ID = arguments[@"appId"];
      result(@(YES));
  } else if([@"showSplash" isEqualToString:call.method]){
      NSDictionary* arguments = call.arguments;
      NSString* posId = arguments[@"posId"];
      NSString* backgroundImage = arguments[@"backgroundImage"];
      [[[FlutterSplashView alloc] init:posId backgroundImage:backgroundImage binaryMessenger:_registrar.messenger] show];
  } else if([@"closeSplash"isEqualToString:call.method]) {
      
  } else if([@"createUnifiedInterstitialAd" isEqualToString:call.method]) {
      NSDictionary* arguments = call.arguments;
      NSString* posId = arguments[@"posId"];
      if(interstitials[posId]) {
          [interstitials[posId] close];
      }
      interstitials[posId] = [[FlutterUnifiedInterstitialView alloc] init:posId binaryMessenger:_registrar.messenger];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
