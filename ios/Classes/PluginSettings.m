//
//  PluginSettings.m
//  adnet_qq
//
//  Created by Dolphin on 2019/7/7.
//

#import <Foundation/Foundation.h>
#import "PluginSettings.h"



@implementation PluginSettings {
    
}

static PluginSettings *_instance = nil;

+ (instancetype) getInstance
{
    if (! _instance) {
        _instance = [[PluginSettings alloc] init];
    }
    return _instance;
}

- (instancetype)init
{
    if(!_instance) {
        _instance = [super init];
        PLUGIN_ID = @"com.whaleread.flutter.plugin.adnet_qq";
        UNIFIED_BANNER_VIEW_ID = [NSString stringWithFormat:@"%@/unified_banner",PLUGIN_ID];
        NATIVE_EXPRESS_VIEW_ID = [NSString stringWithFormat:@"%@/native_express",PLUGIN_ID];
        UNIFIED_INTERSTITIAL_VIEW_ID = [NSString stringWithFormat:@"%@/unified_interstitial",PLUGIN_ID];
        SPLASH_VIEW_ID = [NSString stringWithFormat:@"%@/splash",PLUGIN_ID];
    }
    return _instance;
}

@end
