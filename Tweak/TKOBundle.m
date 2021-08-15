#import "TKOBundle.h"
#import <objc/runtime.h>
#import "TKOController.h"


@interface TKOBundle ()
@end

@implementation TKOBundle
+ (instancetype) initWithNCNotificationRequest:(NCNotificationRequest *)req {
    TKOBundle *bundle = [TKOBundle alloc];

    bundle.ID = [req.bulletin.sectionID copy];
    bundle.notifications = [@[[req copy]] mutableCopy];
    bundle.lastUpdate = [NSDate date];
    
    SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance]; 
    SBIcon *sbIcon = [iconController.model applicationIconForBundleIdentifier:bundle.ID];

    bundle.icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];

    // Fallback icon is preferences
    if(!bundle.icon) {
        sbIcon = [iconController.model applicationIconForBundleIdentifier:@"com.apple.Preferences"];
        bundle.icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];
    }

    return bundle;
}

- (void) newNotification:(NCNotificationRequest *) req{
    self.lastUpdate = [NSDate date];
    [self.notifications addObject:req];
}

- (void) updateNotification:(NCNotificationRequest *) req{
    for(int i = self.notifications.count - 1; i >= 0; i--) {
        NCNotificationRequest *oldReq = self.notifications[i];
        if([oldReq.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
            [self.notifications removeObjectAtIndex:i];
            [self.notifications insertObject:[req copy] atIndex:i];
            break;
        }
    }
}

- (void) removeNotification:(NCNotificationRequest *)req {
    for (NSInteger i = self.notifications.count - 1; i >= 0; i--) {
        NCNotificationRequest *oldReq = self.notifications[i];
        if([oldReq.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
            [self.notifications removeObjectAtIndex:i];
            break;
        }
    }
}
@end