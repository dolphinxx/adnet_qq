#import <Flutter/Flutter.h>

@interface AdnetQqPlugin : NSObject<FlutterPlugin>
+(UIViewController*)getViewController;
+(void)removeInterstitial:(NSString*)posId;
@end
