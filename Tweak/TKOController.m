#import "TKOController.h"
#import "IOSHeaders.h"

@interface TKOController ()
@end

@implementation TKOController
+ (TKOController *)sharedInstance {
    static TKOController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TKOController alloc] init];

        sharedInstance.bundles = [NSMutableArray new];
        sharedInstance.isTkoCall = NO;
    });
    return sharedInstance;
}

- (NSInteger) indexOfBundleID:(NSString *)bundleID {

    for(NSInteger i = self.bundles.count - 1; i >= 0; i--) {
       TKOBundle *bundle = self.bundles[i];
       if([bundle.ID isEqualToString:bundleID]) return i;
    }

    return NSNotFound;
}

// Every time a new notification is received, is redirected to here
- (void) insertNotificationRequest:(NCNotificationRequest *)req {
    NSString* bundleID = req.bulletin.sectionID;
    NCNotificationRequest *notif = [req copy];

    // [self.notifLock lock];
    NSInteger index = [self indexOfBundleID:bundleID]; 

    // bundle doesnt exists
    if(index == NSNotFound) {
        TKOBundle *newBundle = [TKOBundle initWithNCNotificationRequest:notif];

        [self.bundles addObject:newBundle];
        [self.view updateAllCells];
    
    } else {
        TKOBundle *bundle = self.bundles[index]; 
        [bundle newNotification:notif];

        // if that bundle is being showed right now, also insert to nlc
        if([self.view.selectedBundleID isEqualToString:bundleID]) [self insertNotificationToNlc:notif];

        // Also we update only this cell
        [self.view updateCellWithBundle:bundleID];
    }

    self.view.lastBundleUpdated = [NSString stringWithString:bundleID];

    // Update group
    if(self.groupView) [self.groupView update];
    // [self.notifLock lock] 
}


// Every time a new notification is modified, is redirected to here
- (void) modifyNotificationRequest:(NCNotificationRequest* )req {
    
    // If key exists, just add a new item to key (sectionID) array
    NSString* bundleID = req.bulletin.sectionID;
    NSInteger index = [self indexOfBundleID:bundleID]; 

    if(index != NSNotFound) {
        TKOBundle *bundle = self.bundles[index];
        [bundle updateNotification:req];
    }
}

// Every time a new notification is removed, is redirected to here
- (void) removeNotificationRequest:(NCNotificationRequest *)req {
    // Here we want to remove from our info but also from the system
    NSString* bundleID = req.bulletin.sectionID;
    NSInteger index = [self indexOfBundleID:bundleID]; 

    if(index == NSNotFound) {
        // This shoudnt happen
        // [self removeNotificationFromNlc:req];
    
    } else {
        TKOBundle *bundle = self.bundles[index]; 
        [bundle removeNotification:req];
        [self removeNotificationFromNlc:req];
        
        if(bundle.notifications.count == 0) {
            [self.bundles removeObjectAtIndex:index];
            [self.view updateAllCells];
            
            // We update group
            if(self.groupView) [self.groupView update];
    
        } else {
            [self.view updateCellWithBundle:bundleID];
        }
    }
}

- (void) insertNotificationToNlc:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc insertNotificationRequest:req];
    self.isTkoCall = NO;
}

- (void) insertAllNotificationsWithBundleID:(NSString *)bundleID {
    NSInteger index = [self indexOfBundleID:bundleID];
    if(index == NSNotFound) return;

    TKOBundle *bundle = self.bundles[index];
    for(int i = bundle.notifications.count - 1; i >= 0; i--) [self insertNotificationToNlc:bundle.notifications[i]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.nlc _resetCellWithRevealedActions];
    });
}

- (void) removeNotificationFromNlc:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc removeNotificationRequest:req];
    self.isTkoCall = NO;
}

- (void) hideAllNotificationsWithBundleID:(NSString *)bundleID {
    NSInteger index = [self indexOfBundleID:bundleID];
    if(index == NSNotFound) return;

    TKOBundle *bundle = self.bundles[index];
    for(int i = bundle.notifications.count - 1; i >= 0; i--) [self removeNotificationFromNlc:bundle.notifications[i]];
}

- (void) removeAllNotificationsWithBundleID:(NSString *)bundleID {
    NSInteger index = [self indexOfBundleID:bundleID];
    if(index == NSNotFound) return;

    __weak TKOBundle *bundle = self.bundles[index];

    [self.dispatcher destination:nil requestsClearingNotificationRequests:bundle.notifications];
    [self hideAllNotificationsWithBundleID:bundle.ID];
    [self.bundles removeObjectAtIndex:index];
    bundle.notifications = nil;

    if([self.view.selectedBundleID isEqualToString:bundleID]) self.view.selectedBundleID = nil;
    [self.view updateAllCells];
}

- (void) removeAllNotifications {
    for(NSInteger i = self.bundles.count - 1; i >= 0; i--) [self removeAllNotificationsWithBundleID:((TKOBundle *)self.bundles[i]).ID];
}

- (void) hideAllNotifications {
    NSArray *requests = [self.nlc allRequests];
    for(int i = requests.count - 1; i >= 0; i--) {
        NCNotificationRequest *req = requests[i];
        [self removeNotificationFromNlc:req];
    }
}

@end