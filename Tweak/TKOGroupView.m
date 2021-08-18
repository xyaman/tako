#import "TKOGroupView.h"
#import "TKOController.h"
#import "objc/runtime.h"

@interface TKOGroupView ()
@end

@implementation TKOGroupView
- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];

    self.iconsView = [NSMutableArray arrayWithCapacity:3];
    self.isVisible = NO;
    self.hidden = YES;

    // View blur
    self.blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    self.blur.userInteractionEnabled = NO;
    self.blur.frame = self.bounds;
    self.blur.layer.cornerRadius = 13;
    self.blur.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:self.blur];

    self.width = 20;
    self.iconsCount = 3;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];

    return self;
}

- (void) reload {

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
        [iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5 + (i * self.width + i*5)].active = YES;
        [iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
        [iconView.heightAnchor constraintEqualToConstant:self.width].active = YES;
        [iconView.widthAnchor constraintEqualToConstant:self.width].active = YES;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void) show {
    if(self.isVisible) return [self update];
    [self update];
    self.isVisible = YES;
    self.hidden = NO;

    [[TKOController sharedInstance] hideAllNotifications];
    [TKOController sharedInstance].view.hidden = YES;

    self.superview.frame = CGRectMake(0, 0, 0, 0);
}

- (void) hide {
    if(!self.isVisible) return;
    self.isVisible = NO;
    self.hidden = YES;

    [TKOController sharedInstance].view.hidden = NO;

    // [[TKOController sharedInstance].view setNeedsLayout];
    // [[TKOController sharedInstance].view layoutIfNeeded];
    // [[TKOController sharedInstance].view invalidateIntrinsicContentSize];

    self.superview.frame = CGRectMake(0, 0, 0, 0);
    // [self.superview sizeToFit];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
}

- (void) update {
    NSInteger bundlesCount = [TKOController sharedInstance].view.cellsInfo.count > self.iconsCount ? self.iconsCount : [TKOController sharedInstance].view.cellsInfo.count;
    NSRange range = NSMakeRange(0, bundlesCount);
    NSArray *cellsInfo = [[TKOController sharedInstance].view.cellsInfo subarrayWithRange:range];

    // First we hide all icons
    for(UIImageView *iconView in self.iconsView) iconView.hidden = YES;

    // We 
    for(NSInteger i = 0; i < cellsInfo.count; i++) {
        UIImageView *iconView = self.iconsView[i];
        TKOBundle *bundle = cellsInfo[i];

        iconView.image = bundle.icon;
        iconView.hidden = NO;
    }

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, bundlesCount * (self.width + 5) + 5, self.width + 10);
    self.blur.frame = self.bounds;
    [self invalidateIntrinsicContentSize];
}
@end