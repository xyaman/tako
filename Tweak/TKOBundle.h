#import "CommonHeaders.h"

@interface TKOBundle : NSObject
@property(nonatomic, retain) NSString *ID;
@property(nonatomic, retain) UIImage *icon;
@property(nonatomic, retain) NSDate *lastUpdate;
@property(nonatomic, retain) NSMutableArray *notifications;

+ (instancetype) initWithNCNotificationRequest:(NCNotificationRequest *)req;

- (void) newNotification:(NCNotificationRequest *)req;
- (void) updateNotification:(NCNotificationRequest *)req;
- (void) removeNotification:(NCNotificationRequest *)req;
@end