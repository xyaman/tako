#import "Shared.h"

%group TakoTweak

// View placement
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
