#import "../IOSHeaders.h"
#import "Shared.h"

%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOGroupView *tkoGroupView;

-(void)viewDidLoad {
    %orig;

    // This method shoudn't be called more than once, but just in case
    if(!self.tkoGroupView) {
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;

        self.tkoGroupView = [[TKOGroupView alloc] initWithFrame:CGRectZero];
        [self.tkoGroupView reload];

        [TKOController sharedInstance].groupView = self.tkoGroupView;

        // Always at top
        [self.stackView insertArrangedSubview:self.tkoGroupView atIndex:0];
    }
}

-(void)_insertItem:(UIView *)arg0 animated:(BOOL)arg1 {
    %orig;

    // Make group be always at top
    [self.tkoGroupView removeFromSuperview];
    [self.stackView insertArrangedSubview:self.tkoGroupView atIndex:0];
}
%end


%ctor {
    if(![TKOController sharedInstance].isEnabled) return;

    // Only activate group view is enabled for lockscreen or notification center
    if([TKOController sharedInstance].prefLSGroupIsEnabled || [TKOController sharedInstance].prefNCGroupIsEnabled) {
        %init();
    }
}
