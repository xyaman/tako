#import "objc/runtime.h"
#import "TKOGroupView.h"

#import "../Controller/TKOController.h"

@interface TKOGroupView ()
@property(nonatomic) CGRect oldTkoViewFrame;
@end

@implementation TKOGroupView
- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];

    self.iconsView = [NSMutableArray arrayWithCapacity:3];
    self.isVisible = NO;
    self.hidden = YES;
    self.taptic = [UISelectionFeedbackGenerator new];

    // View blur
    self.blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    self.blur.userInteractionEnabled = NO;
    self.blur.frame = self.bounds;
    self.blur.layer.cornerRadius = 13;
    self.blur.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:self.blur];

    self.width = 20;
    self.iconsCount = 3;
    self.iconSpacing = 5;

    // More notifications circle
    // self.moreView = [UILabel new];
    // self.moreView.userInteractionEnabled = NO;
    // [self addSubview:self.moreView];

    // self.moreView.textAlignment = NSTextAlignmentCenter;
    // self.moreView.clipsToBounds = YES;
    // self.moreView.font = [UIFont systemFontOfSize:10];

    // Tap recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];

    return self;
}

// This loads all settings and set up imageviews
- (void) reload {

    self.iconsCount = [TKOController sharedInstance].prefGroupIconsCount;
    self.roundedIcons = [TKOController sharedInstance].prefGroupRoundedIcons;
    self.iconSpacing = [TKOController sharedInstance].prefGroupIconSpacing;
    self.width = [TKOController sharedInstance].prefGroupIconSize;

    for(UIImageView *iconView in self.iconsView) [iconView removeFromSuperview];

    [self.iconsView removeAllObjects];

    for(NSInteger i = 0; i < self.iconsCount; i++) {
        // We create a new UIImageView
        UIImageView *iconView = [UIImageView new];

        // We add it to our array and then we add it as a subview of TKOGroupView
        [self.iconsView addObject:iconView];
        [self addSubview:iconView];

        // Icon settings
        iconView.userInteractionEnabled = NO;

        // Frame options
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:self.iconSpacing + (i*self.width + i*self.iconSpacing)].active = YES;
        [iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:self.iconSpacing].active = YES;
        [iconView.heightAnchor constraintEqualToConstant:self.width].active = YES;
        [iconView.widthAnchor constraintEqualToConstant:self.width].active = YES;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void) show {
    if(self.isVisible || self.isUpdating) return;
    self.isVisible = YES;
    self.hidden = NO;

    [self update];

    [[TKOController sharedInstance] hideAllNotifications];

    // Get old frame
    self.oldTkoViewFrame = [TKOController sharedInstance].view.frame;
    [TKOController sharedInstance].view.hidden = YES;

    if(self.needsFrameZero) self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height - self.oldTkoViewFrame.size.height);
}

- (void) hide {
    if(!self.isVisible) return;
    self.isVisible = NO;

    if([TKOController sharedInstance].prefUseHaptic) [self.taptic selectionChanged];

    // Animate dissapear
    [UIView animateWithDuration:0.3
        animations:^{self.alpha = 0.0;}
        completion:^(BOOL finished){
            self.alpha = 1.0;

            self.hidden = YES;
            [TKOController sharedInstance].view.hidden = NO;
            [TKOController sharedInstance].view.selectedBundleID = nil;
            [[TKOController sharedInstance].view.colView reloadData];

            [self.superview setNeedsLayout];
            [self.superview layoutIfNeeded]; 

            if(self.needsFrameZero) self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height + self.oldTkoViewFrame.size.height);
        }
    ];
}

- (void) update {
    NSInteger bundlesCount = [TKOController sharedInstance].view.cellsInfo.count > self.iconsCount ? self.iconsCount : [TKOController sharedInstance].view.cellsInfo.count;
    NSRange range = NSMakeRange(0, bundlesCount);
    NSArray *cellsInfo = [[TKOController sharedInstance].view.cellsInfo subarrayWithRange:range];

    // First we hide all icons
    for(UIImageView *iconView in self.iconsView) iconView.hidden = YES;

    // Configure each image view
    for(NSInteger i = 0; i < bundlesCount; i++) {
        UIImageView *iconView = self.iconsView[i];
        TKOBundle *bundle = cellsInfo[i];

        iconView.image = [bundle resizedIconWithSize:CGSizeMake(self.width, self.width)];
        iconView.hidden = NO;

        if(self.roundedIcons) {
            iconView.clipsToBounds = YES;
            iconView.layer.cornerRadius = self.width / 2;
            iconView.layer.cornerCurve = kCACornerCurveContinuous;
        }
    }

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, bundlesCount * (self.width + self.iconSpacing) + self.iconSpacing, self.width + 2 * self.iconSpacing);
    self.blur.frame = self.bounds;
    [self invalidateIntrinsicContentSize];
}

// iPad issue
-(void)setSizeToMimic:(CGSize)arg1 {}
-(CGSize)sizeToMimic {return self.frame.size;}
@end
