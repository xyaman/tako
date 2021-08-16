#import "IOSHeaders.h"
#import "Tweak.h"

CSCombinedListViewController *cs = nil;

void updatePrefs() {
    [TKOController sharedInstance].cellStyle = [prefCellStyle intValue];

    [TKOController sharedInstance].view.displayBy = [prefDisplayBy intValue];
    [TKOController sharedInstance].view.sortBy = [prefSortBy intValue];
    [TKOController sharedInstance].view.colView.pagingEnabled = prefUsePaging;
    [[TKOController sharedInstance].view.colView reloadData];
}

%group TakoTweak

%hook CSCoverSheetViewController
-(void)viewWillAppear:(BOOL)animated {
    [[TKOController sharedInstance].view prepareForDisplay];
    %orig;
}

-(void)viewWillDisappear:(BOOL)animated {
    [[TKOController sharedInstance].view prepareToHide];
    %orig;
}
%end

%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
    %orig;
    // Screen is on
    if(value > 0.0f) {
        [[TKOController sharedInstance].view prepareForDisplay];
    } else {
       [TKOController sharedInstance].view.selectedBundleID = nil; 
       [[TKOController sharedInstance].view.colView reloadData]; 
       [[TKOController sharedInstance].view prepareToHide];
    }
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


%hook CSCombinedListViewController
-(BOOL)notificationStructuredListViewControllerShouldAllowNotificationHistoryReveal:(id)arg1 {
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

-(void) viewDidAppear:(BOOL)arg0 {
    %orig;
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

-(void)modifyNotificationRequest:(NCNotificationRequest* )notification {
    // Probably never lol
    if([TKOController sharedInstance].isTkoCall) return %orig;

    [[TKOController sharedInstance] modifyNotificationRequest:notification];
}

-(void)removeNotificationRequest:(NCNotificationRequest *)notification {
    if([TKOController sharedInstance].isTkoCall) return %orig;
    [[TKOController sharedInstance] removeNotificationRequest:notification];
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
    return YES;
}
%end

%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOView *tkoView;
- (void) viewDidLoad {
    %orig;

    if(self.tkoView) return;
    self.stackView.alignment = UIStackViewAlignmentCenter;
    // self.stackView.distribution = UIStackViewDistributionFillProportionally;

    CGFloat height = 0;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 20;

    if([prefCellStyle intValue] == 0)  height = 110; // Default
    else if([prefCellStyle intValue] == 1) height = 65; // Axon grouped
    else if([prefCellStyle intValue] == 2) height = 100; // Axon grouped

    self.tkoView = [[TKOView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    updatePrefs(); // Todo check this
    [TKOController sharedInstance].view = self.tkoView;
    [self.stackView addArrangedSubview:self.tkoView];
}

-(void)_insertItem:(UIView *)arg0 animated:(BOOL)arg1 {
    %orig;

    [self.tkoView removeFromSuperview];
    // [self.stackView addSubview:self.tkoView];
    [self.stackView addArrangedSubview:self.tkoView];
}

-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    [self.tkoView removeFromSuperview];
    // [self.stackView insertArrangedSubview:self.tkoView atIndex:0];
    [self.stackView addArrangedSubview:self.tkoView];

    // Force stackview update
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

    updatePrefs();
    %init(TakoTweak);
}