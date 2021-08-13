#import "TKOController.h"

@interface TKOController ()
@end

@implementation TKOController
+ (TKOController *)sharedInstance {
    static TKOController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TKOController alloc] init];

        sharedInstance.notifications = [NSMutableDictionary new];
        sharedInstance.isTkoCall = NO;
    });
    return sharedInstance;
}

// Every time a new notification is received, is redirected to here
- (void) insertNotificationRequest:(NCNotificationRequest *)req {
    NSString* bundleID = req.bulletin.sectionID;
    NCNotificationRequest *notif = [req copy];
    // [self.notifLock lock];

    // If key exists just add to our data
    if([self.notifications objectForKey:bundleID]) {
        [self.notifications[bundleID] addObject:notif];

        // if that bundle is being showed right now, also insert to nlc
        if([self.view.selectedBundleID isEqualToString:bundleID]) [self insertNotificationToNlc:notif];

        // Also we update only this cell
        [self.view updateCellWithBundle:bundleID];
    
    // Key doesnt exists, we add but we also want to update our view
    } else {
        [self.notifications setObject:[NSMutableArray new] forKey:bundleID];
        [self.notifications[bundleID] addObject:notif];
        [self.view updateAllCells];
        self.view.lastBundleUpdated = [bundleID copy];
    }

    // [self.notifLock lock] 
}


// Every time a new notification is modified, is redirected to here
- (void) modifyNotificationRequest:(NCNotificationRequest* )req {
    
    // If key exists, just add a new item to key (sectionID) array
    if([self.notifications objectForKey:req.bulletin.sectionID]) {
    
        NSArray *bundleNotifications = self.notifications[req.bulletin.sectionID];

        for (NSInteger i = bundleNotifications.count - 1; i >= 0; i--) {
            NCNotificationRequest* not = self.notifications[req.bulletin.sectionID][i];
            if([not.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
                [self.notifications[req.bulletin.sectionID] removeObjectAtIndex:i];
                [self.notifications[req.bulletin.sectionID] insertObject:[req copy] atIndex:i];
                break;
            }
        }

    }
}

// Every time a new notification is removed, is redirected to here
- (void) removeNotificationRequest:(NCNotificationRequest *)req {
    // Here we want to remove from our info but also from the system
    NSString* bundleID = req.bulletin.sectionID;

    // [self.notifLock lock];

    // If key exists just add to our data
    if([self.notifications objectForKey:bundleID]) {
        // Get array
        NSMutableArray *bundleNotifs = self.notifications[bundleID];

        // Remove notification from array
        for (NSInteger i = bundleNotifs.count - 1; i >= 0; i--) {
            if([((NCNotificationRequest *)bundleNotifs[i]).notificationIdentifier isEqualToString:req.notificationIdentifier]) {
                [self removeNotificationFromNlc:bundleNotifs[i]];
                [bundleNotifs removeObjectAtIndex:i];
                break;
            }
        }

        // Also we update only this cell
        if(bundleNotifs.count == 0) {
            [self.notifications removeObjectForKey:bundleID];
            [self.view updateAllCells];
    
        } else {
            [self.view updateCellWithBundle:bundleID];
        }
    
    // THIS SHOULDNT HAPPEN
    } else {
        NSLog(@"[TakoTweak] Weird notification removed: %@", req);
        [self removeNotificationFromNlc:req];
    }

    // [self.notifLock lock] 

}

- (void) insertNotificationToNlc:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc insertNotificationRequest:req];
    self.isTkoCall = NO;
}

- (void) insertAllNotificationsWithBundleID:(NSString *)bundleID {
    for(NCNotificationRequest *notif in self.notifications[bundleID]) [self insertNotificationToNlc:notif];
}

- (void) removeNotificationFromNlc:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc removeNotificationRequest:req];
    self.isTkoCall = NO;
}

- (void) removeAllNotificationsWithBundleID:(NSString *)bundleID {
    for(NCNotificationRequest *notif in self.notifications[bundleID]) [self removeNotificationFromNlc:notif];
}

- (void) removeAllNotifications {
    for(NSString *bundleID in self.notifications) [self removeAllNotificationsWithBundleID:bundleID];
}

- (UIImage *) getIconForIdentifier:(NSString *)identifier {
    SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance]; 
    SBIcon *sbIcon = [iconController.model applicationIconForBundleIdentifier:identifier];

    UIImage *icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];

    // Fallback icon
    if(!icon) {
        sbIcon = [iconController.model applicationIconForBundleIdentifier:@"com.apple.Preferences"];
        icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];
    }

    return icon;
}

@end