#import "TKOCell.h"
#import "TKOController.h"
#import "objc/runtime.h"

@interface TKOCell ()
@end

@implementation TKOCell
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 13;
    self.backgroundColor = [UIColor clearColor];

    // View blur
    self.blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    self.blur.frame = self.bounds;
    self.blur.layer.cornerRadius = 13;
    self.blur.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:self.blur];

    // Close view
    self.closeView = [UIView new];
    self.closeView.hidden = YES;
    self.closeView.layer.cornerRadius = 13;
    self.closeView.backgroundColor = [UIColor redColor];
    [self addSubview:self.closeView];

    self.closeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeView.bottomAnchor constraintEqualToAnchor:self.blur.topAnchor constant:-4].active = YES;
    [self.closeView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.closeView.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.closeView.widthAnchor constraintEqualToConstant:20].active = YES;
    [self layoutIfNeeded];

    // Close blur
    UIView *closeBlur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    closeBlur.frame = self.closeView.bounds;
    closeBlur.layer.cornerRadius = 13;
    closeBlur.layer.cornerCurve = kCACornerCurveContinuous;
    [self.closeView addSubview:closeBlur];

    // Close label
    UILabel *closeText = [UILabel new];
    closeText.textAlignment = NSTextAlignmentCenter;
    closeText.backgroundColor = [UIColor clearColor];
    closeText.frame = self.closeView.bounds;
    closeText.text = @"x";
    closeText.font = [UIFont systemFontOfSize:10];
    [self.closeView addSubview:closeText];
    
    // Close shape
    self.closeShapeLayer = [CAShapeLayer layer];
    self.closeShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.closeShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.closeShapeLayer.lineCap = kCALineCapRound;
    self.closeShapeLayer.lineWidth = 2;
    self.closeShapeLayer.strokeEnd = 0;
    
    self.closeShapeLayer.path = [UIBezierPath bezierPathWithArcCenter:self.closeView.center radius:10 startAngle:-M_PI/2 endAngle:2* M_PI clockwise:YES].CGPath;
    [self.layer addSublayer:self.closeShapeLayer];


    // Pan gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];

    self.panGesture.delegate = self;
    self.taptic = [[UINotificationFeedbackGenerator alloc] init];
    self.willBeRemoved = NO;

    // Setup style
    if([[TKOController sharedInstance].cellStyle intValue] == 0) [self setupUgly];
    else if([[TKOController sharedInstance].cellStyle intValue] == 1) [self setupAxonStyle];

    return self;
}

- (void) setupUgly {
    
    // Notification app icon
    self.iconView = [UIImageView new];
    self.iconView.userInteractionEnabled = NO;
    [self addSubview:self.iconView];

    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.iconView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.iconView.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:30].active = YES;

    // Notification count
    self.countLabel = [UILabel new];
    self.countLabel.userInteractionEnabled = NO;
    [self addSubview:self.countLabel];

    self.countLabel.textAlignment = NSTextAlignmentCenter;

    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel.topAnchor constraintEqualToAnchor:self.iconView.bottomAnchor].active = YES;
    [self.countLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.countLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:self.frame.size.width].active = YES;
}

- (void) setupAxonStyle {

    self.layer.cornerRadius = 16;
    self.blur.layer.cornerRadius = 16;

    // Notification app icon
    self.iconView = [UIImageView new];
    self.iconView.userInteractionEnabled = NO;
    [self addSubview:self.iconView];

    self.iconView.layer.cornerRadius = 10;
    self.iconView.layer.cornerCurve = kCACornerCurveContinuous;
    self.iconView.clipsToBounds = YES;

    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:6].active = YES;
    [self.iconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.iconView.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:20].active = YES;

    // Notification count
    self.countLabel = [UILabel new];
    self.countLabel.userInteractionEnabled = NO;
    [self addSubview:self.countLabel];

    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.clipsToBounds = YES;
    self.countLabel.font = [UIFont systemFontOfSize:10];

    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-6].active = YES;
    [self.countLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.countLabel.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:20].active = YES;
    [self layoutIfNeeded];

    self.countLabel.layer.cornerRadius = self.countLabel.frame.size.width / 2;
    self.countLabel.layer.cornerCurve = kCACornerCurveContinuous;
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.iconView.image = nil;
    self.backgroundColor = [UIColor clearColor];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.bundle = nil;
}

- (void) updateColors {
    UIColor *appColor = [Kuro getPrimaryColor:self.bundle.icon];

    // Axon version
    if([[TKOController sharedInstance].cellStyle intValue] == 1) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext){[self.bundle.icon drawInRect:(CGRect) {.origin = CGPointZero, .size = CGSizeMake(20, 20)}];}];
        self.iconView.image = [image imageWithRenderingMode:self.bundle.icon.renderingMode];

        self.countLabel.backgroundColor = [Kuro isDarkColor:appColor] ? [Kuro darkerColorForColor:appColor] : [Kuro lighterColorForColor:appColor];
        self.countLabel.textColor = [Kuro isDarkColor:appColor] ? [UIColor whiteColor] : [UIColor blackColor];

    } else {
        self.iconView.image = self.bundle.icon ?: [UIImage new];
    }

    self.countLabel.text = [NSString stringWithFormat:@"%ld", self.bundle.notifications.count];

}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];

    if(selected) {
        self.backgroundColor = [Kuro getPrimaryColor:self.iconView.image];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [[objc_getClass("SBIdleTimerGlobalCoordinator") sharedInstance] resetIdleTimer];
    if(gestureRecognizer != self.panGesture) return YES;

    CGPoint velocity = [self.panGesture velocityInView:self];
    return fabs(velocity.y) > fabs(velocity.x);
}


- (void) handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];

    CGFloat movement = translation.y > 0 ? pow(translation.y, 0.7) : -pow(-translation.y, 0.7);

    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.initialFrame = self.frame;
            self.willBeRemoved = NO;
            self.closeView.hidden = NO;
            [self.layer addSublayer:self.closeShapeLayer];
            break;
            
        case UIGestureRecognizerStateChanged:
            self.frame = CGRectMake(self.initialFrame.origin.x, self.initialFrame.origin.y + movement, self.frame.size.width, self.frame.size.height);
            self.closeShapeLayer.strokeEnd = movement >= 30 ? 1 : movement / 30;
            
            if(movement >= 30 && !self.willBeRemoved) {
                self.willBeRemoved = YES;
                // [self.taptic notificationOccurred:UINotificationFeedbackTypeWarning];
            
            } else if(movement < 30) {
                self.willBeRemoved = NO;
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            if(self.willBeRemoved) {
                [self.taptic notificationOccurred:UINotificationFeedbackTypeSuccess];
                // Remove cell
                [[TKOController sharedInstance] removeAllNotificationsWithBundleID:self.bundle.ID];
            } else {
                [self.taptic notificationOccurred:UINotificationFeedbackTypeError];
            }
            [self.closeShapeLayer removeFromSuperlayer];
            self.closeView.hidden = YES;
            self.closeShapeLayer.strokeEnd = 0;
            self.frame = self.initialFrame;
            break;
            
        default:
            self.closeView.hidden = YES;
            [self.closeShapeLayer removeFromSuperlayer];
            self.closeShapeLayer.strokeEnd = 0;
            self.frame = self.initialFrame;
            break;
    }
}
@end