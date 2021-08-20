#import "TKOCloseView.h"
#import "objc/runtime.h"

@interface TKOCloseView ()
@end

@implementation TKOCloseView
- (instancetype) init {
    self = [super init];

    self.clipsToBounds = YES;
    self.layer.cornerCurve = kCACornerCurveContinuous;
    
    // Blur
    self.blurView = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    [self addSubview:self.blurView];

    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blurView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.blurView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.blurView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;

    // Icon View
    self.iconView = [UIImageView new];
    self.iconView.tintColor = [UIColor labelColor];
    self.iconView.image = [UIImage systemImageNamed:@"xmark"];
    [self addSubview:self.iconView];

    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.iconView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5].active = YES;
    [self.iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:7].active = YES;
    [self.iconView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-7].active = YES;

    self.backgroundColor = [UIColor redColor];

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    self.layer.cornerRadius = self.frame.size.width / 2;
}
@end