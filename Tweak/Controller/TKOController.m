#import <Cephei/HBPreferences.h>
#import "TKOController.h"
#import "../IOSHeaders.h"

@interface TKOController ()
@end

@implementation TKOController {
    HBPreferences *_preferences;
}

+ (TKOController *)sharedInstance {
    static TKOController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TKOController alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];

    self.bundles = [NSMutableArray new];
    self.isTkoCall = NO;

    // Preferences
    _preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.takopreferences"];
    [_preferences registerBool:&_isEnabled default:NO forKey:@"isEnabled"];
    if(!self.isEnabled) { return self; }

    [_preferences registerInteger:&_prefSortBy default:0 forKey:@"sortBy"];
    [_preferences registerInteger:&_prefDisplayBy default:1 forKey:@"displayBy"];

    // Coloring
    [_preferences registerBool:&_prefUseStockColoring default:NO forKey:@"stockColoring"];
    [_preferences registerBool:&_prefUseAdaptiveBackground default:YES forKey:@"useAdaptiveBackground"];

    // Cell options
    [_preferences registerInteger:&_prefCellStyle default:0 forKey:@"cellStyle"];
    [_preferences registerFloat:&_prefCellSpacing default:10 forKey:@"cellSpacing"];

    // Group view
    [_preferences registerBool:&_prefLSGroupIsEnabled default:NO forKey:@"LSGroupedIsEnabled"];
    [_preferences registerBool:&_prefNCGroupIsEnabled default:NO forKey:@"NCGroupedIsEnabled"];
    [_preferences registerBool:&_prefGroupAuthentication default:NO forKey:@"groupAuthentication"];
    [_preferences registerBool:&_prefGroupRoundedIcons default:NO forKey:@"groupRoundedIcons"];
    [_preferences registerBool:&_prefGroupWhenMusic default:NO forKey:@"groupWhenMusic"];
    [_preferences registerInteger:&_prefGroupIconsCount default:3 forKey:@"groupedIconsCount"];
    [_preferences registerFloat:&_prefGroupIconSize default:20 forKey:@"groupIconSize"];
    [_preferences registerFloat:&_prefGroupIconSpacing default:5 forKey:@"groupIconSpacing"];

    // Miscelaneous
    [_preferences registerBool:&_prefForceCentering default:NO forKey:@"forceCentering"];
    [_preferences registerBool:&_prefUseHaptic default:YES forKey:@"useHaptic"];

    return self;
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
    if(!req.bulletin.sectionID) return;

    NSString* bundleID = [req.bulletin.sectionID copy];
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
