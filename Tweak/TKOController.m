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

- (void) insertNotificationRequest:(NCNotificationRequest *)req {

    // If key exists, just add a new item to key (sectionID) array
    if([self.notifications objectForKey:req.bulletin.sectionID]) {

        [self.notifications[req.bulletin.sectionID] addObject:[req copy]];

        if([self.view.selectedBundle isEqualToString:req.bulletin.sectionID]) [self showNotification:[req copy]]; // Remove copy

        [self.view updateCellWithIdentifier:req.bulletin.sectionID];
        return;

    // If it doesn't exist, create array, then add item
    } else {
        @synchronized(self.notifications) {[self.notifications setObject:[NSMutableArray new] forKey:req.bulletin.sectionID];}
        [self.notifications[req.bulletin.sectionID] addObject:[req copy]];
        [self.view update];
    }
}

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


    // THIS SHOULDNT HAPPEN. If it doesn't exist, create array, then add item
    } else {
        // [self.notifications setObject:[NSMutableArray new] forKey:req.bulletin.sectionID];
        // [self.notifications[req.bulletin.sectionID] addObject:[req copy]];
        // [self.view update];
    } 

    // [self.view update];
}

- (void) removeNotificationRequest:(NCNotificationRequest *)req {

    // If key doesn't exist just return
    // This shouldnt happen, but just in case
    if(![self.notifications objectForKey:req.bulletin.sectionID]) return;

    // Get array
    NSMutableArray *reqList = self.notifications[req.bulletin.sectionID];

    // Remove notification from array
    for (NSInteger i = reqList.count - 1; i >= 0; i--) {
        NCNotificationRequest* not = reqList[i];
        if([not.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
            [self hideNotification:not]; // Remove notification permanently
            [reqList removeObjectAtIndex:i];
            break;
        }
    }

    if(reqList.count == 0) {
        @synchronized(self.notifications) {[self.notifications removeObjectForKey:req.bulletin.sectionID];}
        [self.view update];
    
    } else {
        [self.view updateCellWithIdentifier:req.bulletin.sectionID];
    }
    
}

- (void) showNotificationAllWithIdentifier:(NSString *)identifier {
    if(![self.notifications objectForKey:identifier]) return;
    for(NCNotificationRequest *req in self.notifications[identifier]) [self showNotification:req];
}

- (void) showNotification:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc insertNotificationRequest:req];
    self.isTkoCall = NO;
}

- (void) hideAllNotifications {
    @synchronized(self.notifications) {
        for(NSString *key in self.notifications) [self hideNotificationAllWithIdentifier:key];
    }
}

- (void) hideNotificationAllWithIdentifier:(NSString *)identifier {
    if(![self.notifications objectForKey:identifier]) return;
    for(NCNotificationRequest *req in self.notifications[identifier]) [self hideNotification:req];
}

- (void) hideNotification:(NCNotificationRequest *)req {
    self.isTkoCall = YES;
    [self.nlc removeNotificationRequest:req];
    self.isTkoCall = NO;
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