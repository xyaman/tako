#import "Shared.h"

void updatePrefs() {

    CGRect newFrame = [TKOController sharedInstance].view.frame;
    if([TKOController sharedInstance].prefCellStyle == 0)  newFrame.size.height = 90; // Default
    else if([TKOController sharedInstance].prefCellStyle == 1) newFrame.size.height = 65; // Axon grouped
    else if([TKOController sharedInstance].prefCellStyle == 2) newFrame.size.height = 80; // Full icon
    else if([TKOController sharedInstance].prefCellStyle == 3) newFrame.size.height = 80; // Full icon w/ bottom bar

    [TKOController sharedInstance].view.frame = newFrame;
    [TKOController sharedInstance].view.superview.frame = CGRectZero; // This forces a layout update

    [[TKOController sharedInstance].view reload]; // Reload main view
    [[TKOController sharedInstance].groupView reload]; // Relod group view
}

// Change iOS Notification count for our logic
%hook NCNotificationMasterList
- (void) setNotificationCount:(unsigned long long)arg1 {
    %orig([TKOController sharedInstance].bundles.count);
}

- (unsigned long long) notificationCount {
    return [TKOController sharedInstance].bundles.count;
}
%end

// Dispatcher useful for really removing notifications (and not just visually removed)
%hook SBNCNotificationDispatcher
-(id)init {
    %orig;
    [TKOController sharedInstance].dispatcher = self.dispatcher;
    return self;
}

-(void)setDispatcher:(NCNotificationDispatcher *)arg1 {
    %orig;
    [TKOController sharedInstance].dispatcher = arg1;
}
%end

%hook NCNotificationStructuredListViewController
- (id) init {
    id orig = %orig;
    [TKOController sharedInstance].nlc = self; // Save an instance of this class
    return orig;
}

-(void)insertNotificationRequest:(NCNotificationRequest *)notification {
    if([TKOController sharedInstance].isTkoCall) return %orig;
    [[TKOController sharedInstance] insertNotificationRequest:notification];
}

-(void) modifyNotificationRequest:(NCNotificationRequest* )notification {
    // Probably never lol
    if([TKOController sharedInstance].isTkoCall) return %orig;
    [[TKOController sharedInstance] modifyNotificationRequest:notification];
}

-(void)removeNotificationRequest:(NCNotificationRequest *)notification {
    if([TKOController sharedInstance].isTkoCall) return %orig;
    [[TKOController sharedInstance] removeNotificationRequest:notification];
}

// TODO: Change this
%new
- (NSArray *) allRequests {
    NSMutableArray *requests = [NSMutableArray new];
    NSArray *sections = self.masterList.notificationSections;
    for(NSInteger i = sections.count - 1; i >= 0; i--) {
        NCNotificationStructuredSectionList *list = sections[i];
        [requests addObjectsFromArray:list.allNotificationRequests];
    }

    return requests;
}
%end


// AutoUnlockX compatibility
%hook SparkAutoUnlockX // From axon repo
-(BOOL)externalBlocksUnlock {
    if ([TKOController sharedInstance].bundles.count > 0) return YES;
    return %orig;
}
%end

%ctor {
    if([TKOController sharedInstance].isEnabled) %init();

    // Preferences update observer
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, (CFStringRef)@"com.xyaman.takopreferences/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}

