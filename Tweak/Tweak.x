#import "Tweak.h"

void updatePrefs() {
    [TKOController sharedInstance].view.sortBy = [prefSortBy intValue];
    [TKOController sharedInstance].view.displayBy = [prefDisplayBy intValue];
    [[TKOController sharedInstance].view.colView reloadData];
}

%group TakoTweak

// %hook CSCoverSheetViewController
// - (void)viewWillAppear:(BOOL)animated {
//     %orig;
//     [[TKOController sharedInstance].view prepareForDisplay];
// }

// - (void)viewWillDisappear:(BOOL)animated {
//     %orig;

// }
// %end

%hook CSPageViewController
-(void)viewWillAppear:(BOOL)animated {
    %orig;
    [[TKOController sharedInstance].view prepareForDisplay];
}
%end

%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
    %orig;
    // Screen is on
    if(value > 0.0f) {
        [[TKOController sharedInstance].view prepareForDisplay];
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

%hook NCNotificationStructuredListViewController
- (id) init {
    id orig = %orig;
    [TKOController sharedInstance].nlc = self; // Save an instance of this class
    return orig;
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

%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOView *tkoView;
- (void) viewDidLoad {
    %orig;

    if(self.tkoView) return;

    self.tkoView = [[TKOView alloc] initWithFrame:CGRectMake(0, 0, 359, 110)];;

    [TKOController sharedInstance].view = self.tkoView;
    updatePrefs(); // Todo check this

    [self.stackView insertArrangedSubview:self.tkoView atIndex:0];

    // [self.stackView setCustomSpacing:10 afterView:self.tkoView];
}

-(void)_insertItem:(id)arg0 animated:(BOOL)arg1 {
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

    updatePrefs();
    %init(TakoTweak);
}