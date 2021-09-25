#import "../IOSHeaders.h"
#import <Kuro/libKuro.h>

@interface TKOBundle : NSObject
@property(nonatomic, retain) NSString *ID;
@property(nonatomic, retain) UIImage *icon;
@property(nonatomic, retain) UIColor *primaryColor;
@property(nonatomic, retain) UIColor *foregroundColor;
@property(nonatomic, retain) NSDate *lastUpdate;
@property(nonatomic, retain) NSMutableArray *notifications;

+ (instancetype) initWithNCNotificationRequest:(NCNotificationRequest *)req;

// Utils
- (UIImage *) resizedIconWithSize:(CGSize)size;

- (void) newNotification:(NCNotificationRequest *)req;
- (void) updateNotification:(NCNotificationRequest *)req;
- (void) removeNotification:(NCNotificationRequest *)req;
@end
