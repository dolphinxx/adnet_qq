//
//  PluginSettings.h
//  Pods
//
//  Created by Dolphin on 2019/7/7.
//

#ifndef PluginSettings_h
#define PluginSettings_h

@interface PluginSettings : NSObject {
     @public NSString* APP_ID;
     @public NSString* PLUGIN_ID;
     @public NSString* UNIFIED_BANNER_VIEW_ID;
    @public NSString* NATIVE_EXPRESS_VIEW_ID;
    @public NSString* UNIFIED_INTERSTITIAL_VIEW_ID;
    @public NSString* SPLASH_VIEW_ID;
}


+ (instancetype)getInstance;

@end



#endif /* PluginSettings_h */
