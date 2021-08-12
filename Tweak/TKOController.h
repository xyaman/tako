#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "CommonHeaders.h"
#import "TKOView.h"

@interface TKOController : NSObject
@property(nonatomic, retain) NSMutableDictionary *notifications;
@property(nonatomic, retain) TKOView *view;

// Notification list controller
@property(nonatomic, retain) NCNotificationStructuredListViewController *nlc;
@property(nonatomic) BOOL isTkoCall;

+ (TKOController *) sharedInstance;

- (void) insertNotificationRequest:(NCNotificationRequest *)req;
- (void) removeNotificationRequest:(NCNotificationRequest *)req;
- (UIImage *) getIconForIdentifier:(NSString *)index;
@end