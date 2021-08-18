#import "IOSHeaders.h"
#import "Tweak.h"

BOOL isLS = NO;
BOOL unavailable = NO;

void updatePrefs() {
    [TKOController sharedInstance].cellStyle = [prefCellStyle intValue];

    [TKOController sharedInstance].view.displayBy = [prefDisplayBy intValue];
    [TKOController sharedInstance].view.sortBy = [prefSortBy intValue];
    [TKOController sharedInstance].view.colView.pagingEnabled = prefUsePaging;
    [[TKOController sharedInstance].view updateAllCells];

    // Grouped
    [TKOController sharedInstance].groupView.iconsCount = [prefGroupedIconsCount intValue];
    [[TKOController sharedInstance].groupView reload];
}

%group TakoTweak

%hook CSCoverSheetViewController
-(void)viewDidAppear:(BOOL)animated {
    %orig;
    if(isLS) return;
    if(prefNCGroupedIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) {
        [[TKOController sharedInstance].groupView show];
    } else {
        [[TKOController sharedInstance].view prepareForDisplay];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    %orig;
    isLS = NO;
    [[TKOController sharedInstance].groupView hide];
}

-(void)prepareForUILock {
    %orig;
}

-(BOOL)handleLockButtonPress {
    if(!isLS) {
        [[TKOController sharedInstance].groupView hide];
        [[TKOController sharedInstance] hideAllNotifications];
        [TKOController sharedInstance].view.selectedBundleID = nil;
        [[TKOController sharedInstance].view.colView reloadData]; 
    }
    
    isLS = YES;
    return %orig;
}
    

-(void)_displayWillTurnOnWhileOnCoverSheet:(id)arg0 {
    %orig;
    if(prefLSGroupedIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) {
        [[TKOController sharedInstance].groupView show];
    } else {
        [[TKOController sharedInstance].view prepareForDisplay];
    }
}

-(BOOL)hasVisibleContentToReveal {
    return YES;
}
%end

%hook CSCombinedListViewController
-(BOOL)notificationStructuredListViewControllerShouldAllowNotificationHistoryReveal:(id)arg1 {
    return YES;
}
%end

%hook NCNotificationListView

- (void)setRevealed:(BOOL)arg1 { // always reveal notifications
    %orig(YES);
}

- (BOOL) revealed {
    return YES;
}
%end


// History notifications
%hook NCNotificationListSectionHeaderView
- (void) didMoveToWindow {
    self.hidden = YES;
}
- (CGRect) frame {
    return CGRectMake(0, 0, 0, 0);
}
- (BOOL) hidden {
    return YES;
}
%end

// Hide older notifications
%hook NCNotificationListSectionRevealHintView
- (void) didMoveToWindow {
    self.hidden = YES;
}

- (CGRect) frame {
    return CGRectMake(0, 0, 0, 0);
}

- (BOOL) hidden {
    return YES;
}
%end

// Hide controls on stack notifications
%hook NCNotificationListCoalescingHeaderCell
- (void) didMoveToWindow {
    self.hidden = YES;
}

- (CGRect) frame {
    return CGRectMake(0, 0, 0, 0);
}

- (BOOL) hidden {
    return YES;
}
%end

// Hide controls on stack notifications
%hook NCNotificationListCoalescingControlsCell
- (void) didMoveToWindow {
    self.hidden = YES;
}

- (CGRect) frame {
    return CGRectMake(0, 0, 0, 0);
}

- (BOOL) hidden {
    return YES;
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
    NSLog(@"[TakoTweak] modified %@", notification);
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

-(BOOL)shouldAllowNotificationHistoryReveal{
    return YES;
}

-(BOOL)notificationListRevealCoordinatorShouldAllowReveal:(id)arg0 {
    %orig;
    return YES;
}
%end

%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOView *tkoView;
%property (nonatomic, retain) TKOGroupView *tkoGroupView;

- (void) viewDidLoad {
    %orig;

    self.stackView.alignment = UIStackViewAlignmentCenter;
    self.stackView.distribution = UIStackViewDistributionEqualSpacing;

    // Group View
    if(!self.tkoGroupView && (prefLSGroupedIsEnabled || prefNCGroupedIsEnabled)) {
        self.tkoGroupView = [[TKOGroupView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

        self.tkoGroupView.iconsCount = [prefGroupedIconsCount intValue];
        [self.tkoGroupView reload];

        [TKOController sharedInstance].groupView = self.tkoGroupView;
        [self.stackView addArrangedSubview:self.tkoGroupView];
    }

    if(!self.tkoView) {
        CGFloat height = 0;
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;

        if([prefCellStyle intValue] == 0)  height = 110; // Default
        else if([prefCellStyle intValue] == 1) height = 65; // Axon grouped
        else if([prefCellStyle intValue] == 2) height = 100; // Axon grouped

        self.tkoView = [[TKOView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [TKOController sharedInstance].view = self.tkoView;
        updatePrefs(); // Todo check this
        [self.stackView addArrangedSubview:self.tkoView];
    }
}

-(void)_insertItem:(UIView *)arg0 animated:(BOOL)arg1 {
    // Needed for compatibility with groups
    self.stackView.frame = CGRectMake(0, 0, 0, 0);
    %orig;

    if(self.tkoGroupView) {
        [self.tkoGroupView hide];
        [self.tkoGroupView removeFromSuperview];

        // If user wants group above player
        if(prefGroupAbovePlayer) [self.stackView insertArrangedSubview:self.tkoGroupView atIndex:0];
        else [self.stackView addArrangedSubview:self.tkoGroupView];
        self.stackView.frame = CGRectMake(0, 0, 0, 0);
    }

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];

    if(!prefGroupWhenMusic) unavailable = YES;

    // Needed for compatibility with groups 
    self.stackView.frame = CGRectMake(0, 0, 0, 0);
}

-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    if(self.tkoGroupView) {
        [self.tkoGroupView hide];
        [self.tkoGroupView removeFromSuperview];
        [self.stackView addArrangedSubview:self.tkoView];
    }

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];
    
    if(!prefGroupWhenMusic) unavailable = NO;

    // Needed for compatibility with groups 
    self.stackView.frame = CGRectMake(0, 0, 0, 0);
}

%end
%end

%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.takopreferences"];
    [preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
    if(!isEnabled) return;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, (CFStringRef)@"com.xyaman.takopreferences/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    [preferences registerObject:&prefSortBy default:@(0) forKey:@"sortBy"];
    [preferences registerObject:&prefDisplayBy default:@(1) forKey:@"displayBy"];

    // Scroll
    [preferences registerBool:&prefUsePaging default:NO forKey:@"usePaging"];

    // Cells
    [preferences registerObject:&prefCellStyle default:@(0) forKey:@"cellStyle"];


    // Group
    [preferences registerBool:&prefLSGroupedIsEnabled default:NO forKey:@"LSGroupedIsEnabled"];
    [preferences registerBool:&prefNCGroupedIsEnabled default:NO forKey:@"NCGroupedIsEnabled"];
    [preferences registerBool:&prefGroupWhenMusic default:NO forKey:@"groupWhenMusic"];
    [preferences registerBool:&prefGroupAbovePlayer default:NO forKey:@"groupAbovePlayer"];
    [preferences registerObject:&prefGroupedIconsCount default:@(3) forKey:@"groupedIconsCount"];

    updatePrefs();
    %init(TakoTweak);
}