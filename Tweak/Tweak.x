#import "IOSHeaders.h"
#import "Tweak.h"

BOOL isLS = NO;
BOOL unavailable = NO;

static BBServer* bbServer = nil;

static dispatch_queue_t getBBServerQueue() {

    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak* pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;
}

%hook BBServer
- (id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc {
    if (bbServer == self) bbServer = nil;
    %orig;
}
%end

static void fakeNotification(NSString* sectionID, NSDate* date, NSString* message, bool banner) {
    
	BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];

	bulletin.title = @"Tako";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
        });
    } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4];
        });
    }

}

void TKOTestNotifications() {

    SpringBoard* springboard = (SpringBoard *)[objc_getClass("SpringBoard") sharedApplication];
	[springboard _simulateLockButtonPress];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.Preferences", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.facetime", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.mobilephone", [NSDate date], @"Hello, I'm Tako", false);
    });
}

void updatePrefs() {
    [TKOController sharedInstance].cellStyle = [prefCellStyle intValue];

    [TKOController sharedInstance].view.displayBy = [prefDisplayBy intValue];
    [TKOController sharedInstance].view.sortBy = [prefSortBy intValue];
    [TKOController sharedInstance].view.colView.pagingEnabled = prefUsePaging;
    [TKOController sharedInstance].view.colLayout.minimumLineSpacing = [prefCellSpacing floatValue];
    [[TKOController sharedInstance].view updateAllCells];

    // Grouped
    [TKOController sharedInstance].groupView.iconsCount = [prefGroupIconsCount intValue];
    [[TKOController sharedInstance].groupView reload];
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
    [[TKOController sharedInstance].view prepareToHide];

    // Grouping
    if(prefNCGroupedIsEnabled && !unavailable && [TKOController sharedInstance].bundles.count > 0) [[TKOController sharedInstance].groupView show];
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

    if(prefForceCentering) self.stackView.alignment = UIStackViewAlignmentCenter;

    // Group View
    if(!self.tkoGroupView && (prefLSGroupedIsEnabled || prefNCGroupedIsEnabled)) {
        // self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.distribution = UIStackViewDistributionFill;

        self.tkoGroupView = [[TKOGroupView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

        self.tkoGroupView.iconsCount = [prefGroupIconsCount intValue];
        self.tkoGroupView.roundedIcons = prefGroupRoundedIcons;
        self.tkoGroupView.iconSpacing = [prefGroupIconSpacing intValue];
        self.tkoGroupView.width = [prefGroupIconSize intValue];
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

        if(self.tkoGroupView) [self.tkoGroupView hide];
    }
}

-(void)_insertItem:(UIView *)arg0 animated:(BOOL)arg1 {
    %orig;

    if(self.tkoGroupView) [self.tkoGroupView hide];

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];

    if(!prefGroupWhenMusic) unavailable = YES;
    else self.tkoGroupView.needsFrameZero = YES;
}

-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    if(self.tkoGroupView) [self.tkoGroupView hide];

    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];
    
    if(!prefGroupWhenMusic) unavailable = NO;
    else self.tkoGroupView.needsFrameZero = NO;
}

%end
%end

%ctor {
    %init; // For notifications
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TKOTestNotifications, (CFStringRef)@"com.xyaman.takopreferences/TestNotifications", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.takopreferences"];
    [preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
    if(!isEnabled) return;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, (CFStringRef)@"com.xyaman.takopreferences/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    [preferences registerObject:&prefSortBy default:@(0) forKey:@"sortBy"];
    [preferences registerObject:&prefDisplayBy default:@(1) forKey:@"displayBy"];

    // Other options
    [preferences registerBool:&prefForceCentering default:NO forKey:@"forceCentering"];

    // Scroll
    [preferences registerBool:&prefUsePaging default:NO forKey:@"usePaging"];

    // Cells
    [preferences registerObject:&prefCellStyle default:@(0) forKey:@"cellStyle"];
    [preferences registerObject:&prefCellSpacing default:@(10) forKey:@"cellSpacing"];


    // Group
    [preferences registerBool:&prefGroupAuthentication default:NO forKey:@"groupAuthentication"];
    [preferences registerBool:&prefGroupRoundedIcons default:NO forKey:@"groupRoundedIcons"];
    [preferences registerBool:&prefLSGroupedIsEnabled default:NO forKey:@"LSGroupedIsEnabled"];
    [preferences registerBool:&prefNCGroupedIsEnabled default:NO forKey:@"NCGroupedIsEnabled"];
    [preferences registerBool:&prefGroupWhenMusic default:NO forKey:@"groupWhenMusic"];
    [preferences registerObject:&prefGroupIconsCount default:@(3) forKey:@"groupedIconsCount"];
    [preferences registerObject:&prefGroupIconSize default:@(20) forKey:@"groupIconSize"];
    [preferences registerObject:&prefGroupIconSpacing default:@(5) forKey:@"groupIconSpacing"];

    if(prefGroupAuthentication && prefLSGroupedIsEnabled) %init(GroupAuthentication);

    updatePrefs();
    %init(TakoTweak);
}