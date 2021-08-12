#import "Tweak.h"

%hook NCNotificationStructuredListViewController
- (id) init {
    id orig = %orig;
    [TKOController sharedInstance].nlc = self; // Save an instance of this class
    return orig;
}

-(void)insertNotificationRequest:(NCNotificationRequest *)notification {
    
    if([TKOController sharedInstance].isTkoCall) return %orig;

    // %orig;
    [[TKOController sharedInstance] insertNotificationRequest:notification];

    // NSLog(@"[TakoTweak] %@", notification.bulletin.sectionID);
    // NSLog(@"[TakoTweak] %@", notification.notificationIdentifier);
}

-(void)removeNotificationRequest:(NCNotificationRequest *)notification {
    if([TKOController sharedInstance].isTkoCall) return %orig;

    // %orig;
    [[TKOController sharedInstance] removeNotificationRequest:notification];

    // NSLog(@"[TakoTweak] removed: %@", notification.bulletin.sectionID);
}
%end


%hook CSNotificationAdjunctListViewController
%property (nonatomic, retain) TKOView *tkoView;
- (void) viewDidLoad {
    %orig;

    if(self.tkoView) return;

    self.stackView.alignment = UIStackViewAlignmentFill;

    self.tkoView = [[TKOView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];;
    [TKOController sharedInstance].view = self.tkoView;
    [self.stackView insertArrangedSubview:self.tkoView atIndex:0];
}

-(BOOL)isPresentingContent {
    return YES;
}

%end