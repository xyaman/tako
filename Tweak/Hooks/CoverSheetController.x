#import "Shared.h"

/* So this hooks decides:
 * - When to reload views (Main or Group),
 * - When to show/hide views
 */


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
BOOL isLS = NO;

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
