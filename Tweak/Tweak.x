#import "IOSHeaders.h"
#import "Hooks/Shared.h"
#import "Tweak.h"

BOOL isLS = NO;

%group TakoTweak

%hook SparkAutoUnlockX // From axon repo
-(BOOL)externalBlocksUnlock {
    if ([TKOController sharedInstance].bundles.count > 0) return YES;
    return %orig;
}
%end

/* So iOS notifications works this way:
 *
 * If there are notifications being displayed and screen is OFF when viewDidAppear
 * is called, the notifications may be moved to history (and because how the Tweak is
 * build, this may lead to some notifications just disappear).
 *
 * So we need to found a method that is called that indicates us that the screen is off,
 * and also that is called before viewDidAppear (or viewWillAppear)
 * In this case "handleLockButtonPress" works (only when user locks the device using lock button,
 * for now it is just okay)
 */

%hook CSCoverSheetViewController
-(void)viewDidAppear:(BOOL)animated {
    %orig;
    if(!isLS) [[TKOController sharedInstance].view prepareForDisplay];
}

// Also called when device is unlocked and we are out of LS
-(void)viewDidDisappear:(BOOL)animated {
    %orig;
    isLS = NO;
    [[TKOController sharedInstance].view prepareToHide];
}

-(BOOL)handleLockButtonPress {
    // This block is called when device is unlocked and is going to be locked. (we are entering to LS)
    if(!isLS) {
        [[TKOController sharedInstance].groupView hide];
        [[TKOController sharedInstance] hideAllNotifications];
        [TKOController sharedInstance].view.selectedBundleID = nil;
        [[TKOController sharedInstance].view.colView reloadData]; 
    
    // We are already on LS
    } else {
        [[TKOController sharedInstance].view prepareToHide];
    }
    
    isLS = YES;
    return %orig;
}
    
// Called every time screen is turned ON (so we are always on LS)
-(void)_displayWillTurnOnWhileOnCoverSheet:(id)arg0 {
    %orig;
    [[TKOController sharedInstance].view prepareForDisplay];
}

-(BOOL)hasVisibleContentToReveal {
    return [TKOController sharedInstance].bundles.count > 0;
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
        [self.stackView addArrangedSubview:self.tkoView];
    }
}

-(void)_insertItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    // This way the view is always below the media player
    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];
}

-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 {
    %orig;

    // This way the view is always below the media player
    [self.tkoView removeFromSuperview];
    [self.stackView addArrangedSubview:self.tkoView];
}

%end
%end

%ctor {
    if(![TKOController sharedInstance].isEnabled) return;
    %init(TakoTweak);
}
