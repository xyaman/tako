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
        [self.notifications[req.bulletin.sectionID] addObject:req];

    // If it doesn't exist, create array, then add item
    } else {
        [self.notifications setObject:[NSMutableArray new] forKey:req.bulletin.sectionID];
        [self.notifications[req.bulletin.sectionID] addObject:req];
        // [self.view update];
    }
    
    [self.view update];
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
            [reqList removeObjectAtIndex:i];
            break;
        }
    }

    if(reqList.count == 0) {
        [self.notifications removeObjectForKey:req.bulletin.sectionID];
        [self.view update];
    }
    
}

- (UIImage *) getIconForIdentifier:(NSString *)identifier {
    SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance]; 
    SBIcon *icon = [iconController.model applicationIconForBundleIdentifier:identifier];

    return [icon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];
}

@end