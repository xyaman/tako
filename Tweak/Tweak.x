#import "IOSHeaders.h"
#import "Tweak.h"

BOOL isLS = NO;
BOOL unavailable = NO;


void updatePrefs() {
    // TODO
}

%group GroupAuthentication
%hook SBDashBoardBiometricUnlockController
- (void)setAuthenticated:(BOOL)arg1 {
    %orig;

    if(arg1 && isLS) {
        [[TKOController sharedInstance].groupView hide];
    }
}
%end
%end

%group TakoTweak

%hook SparkAutoUnlockX

/* The only way I know of... AutoUnlockX */

-(BOOL)externalBlocksUnlock {
    if ([TKOController sharedInstance].bundles.count > 0) return YES;
    return %orig;
}

%end

%hook CSCoverSheetViewController
-(void)viewDidAppear:(BOOL)animated {
    %orig;
    if(isLS) return;
    if([TKOController sharedInstance].prefNCGroupIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) {
        [[TKOController sharedInstance].groupView show];
    } else {
        [[TKOController sharedInstance].view prepareForDisplay];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    %orig;
    isLS = NO;
    [[TKOController sharedInstance].view prepareToHide];

    // Grouping
    if([TKOController sharedInstance].prefNCGroupIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) [[TKOController sharedInstance].groupView show];
    else [[TKOController sharedInstance].groupView hide];
}

-(BOOL)handleLockButtonPress {
    if(!isLS) {
        [[TKOController sharedInstance].groupView hide];
        [[TKOController sharedInstance] hideAllNotifications];
        [TKOController sharedInstance].view.selectedBundleID = nil;
        [[TKOController sharedInstance].view.colView reloadData]; 
    
    } else {
        [[TKOController sharedInstance].view prepareToHide];
    }
    
    isLS = YES;
    return %orig;
}
    

-(void)_displayWillTurnOnWhileOnCoverSheet:(id)arg0 {
    %orig;
    if([TKOController sharedInstance].prefLSGroupIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) {
        [[TKOController sharedInstance].groupView show];
    } else {
        [[TKOController sharedInstance].view prepareForDisplay];
    }
}

-(BOOL)hasVisibleContentToReveal {
    return [TKOController sharedInstance].bundles.count > 0;
}
%end


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

-(BOOL)notificationMasterListShouldAllowNotificationHistoryReveal:(id)arg1 {
    return YES;
}

-(void)insertNotificationRequest:(NCNotificationRequest *)notification {
    if([TKOController sharedInstance].isTkoCall) {
        %orig;
        [self revealNotificationHistory:YES animated:YES];
        return;
    }
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

%hook NCNotificationMasterList
- (void) setNotificationCount:(unsigned long long)arg1 {
    %orig([TKOController sharedInstance].bundles.count);
}

- (unsigned long long) notificationCount {
    return [TKOController sharedInstance].bundles.count;
}
%end

%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOView *tkoView;

- (void) viewDidLoad {
    %orig;

    if([TKOController sharedInstance].prefForceCentering) self.stackView.alignment = UIStackViewAlignmentCenter;

    // This method shouldn't be called more than once, but just in case.
    if(!self.tkoView) {
        CGFloat height = 0;
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;

        if([TKOController sharedInstance].prefCellStyle == 0)  height = 90; // Default
        else if([TKOController sharedInstance].prefCellStyle == 1) height = 65; // Axon grouped
        else if([TKOController sharedInstance].prefCellStyle == 2) height = 80; // Full icon
        else if([TKOController sharedInstance].prefCellStyle == 3) height = 90; // Full icon w/ bottom bar

        self.tkoView = [[TKOView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [TKOController sharedInstance].view = self.tkoView;
        updatePrefs(); // Todo check this
        [self.stackView addArrangedSubview:self.tkoView];

        if(self.tkoGroupView) [self.tkoGroupView hide];
    }
}

-(void)_insertItem:(UIView *)arg0 animated:(BOOL)arg1 {
    %orig;

    // TODO: Split this
    if(self.tkoGroupView) {
        [self.tkoGroupView hide];
    }

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];

    if(![TKOController sharedInstance].prefGroupWhenMusic) unavailable = YES;
    else {
        self.tkoGroupView.needsFrameZero = YES;
    }
}

-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    if(self.tkoGroupView) {
        [self.tkoGroupView hide];
        if([TKOController sharedInstance].prefGroupWhenMusic) self.tkoGroupView.isUpdating = YES;
    }

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];
    
    if(![TKOController sharedInstance].prefGroupWhenMusic) unavailable = NO;
    else {
        // Ugly fix, but this prevent for not updating stackview frame
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.tkoGroupView.needsFrameZero = NO;
            self.tkoGroupView.isUpdating = NO;
        });
    }
}

%end
%end

%ctor {
    if(![TKOController sharedInstance].isEnabled) return;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, (CFStringRef)@"com.xyaman.takopreferences/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    // Group
    if([TKOController sharedInstance].prefGroupAuthentication && [TKOController sharedInstance].prefLSGroupedIsEnabled) %init(GroupAuthentication);

    updatePrefs();
    %init(TakoTweak);
}
