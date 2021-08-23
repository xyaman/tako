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

    // Shape layer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor labelColor].CGColor;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineWidth = 3;
    self.shapeLayer.strokeEnd = 0;

    [self.layer addSublayer:self.shapeLayer];
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    // Radius
    self.layer.cornerRadius = self.frame.size.width / 2;

    // Shapelayer
    self.shapeLayer.bounds = self.bounds;

    // Shape layer path
    CGPoint center = CGPointMake(self.frame.size.width, self.frame.size.height);
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:self.frame.size.width/2 startAngle:-M_PI/2 endAngle:2* M_PI clockwise:YES].CGPath;
}
@end