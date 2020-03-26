#import <CoreLocation/CoreLocation.h>
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@interface CameraPermissionsPlugin
    : NSObject<FlutterPlugin, CLLocationManagerDelegate>
@end
