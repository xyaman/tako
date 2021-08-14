#import "TKOCell.h"
#import "TKOController.h"
#import "objc/runtime.h"

@interface TKOCell ()
@property(nonatomic, retain) UIPanGestureRecognizer *pan;
@property(nonatomic) CGRect initialFrame;
@property(nonatomic) BOOL willBeRemoved;
@property(nonatomic, retain) UINotificationFeedbackGenerator *taptic;

// Close option fill
@property(nonatomic) CAShapeLayer *shapeLayer;
@end

@implementation TKOCell

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // Settings
    self.layer.cornerRadius = 13;
    
    // Blur
    self.backgroundColor = [UIColor clearColor];

    UIView *blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    blur.frame = self.bounds;
    blur.layer.cornerRadius = 13;
    blur.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:blur];

    // Notification app icon
    self.icon = [UIImageView new];
    self.icon.userInteractionEnabled = NO;
    [self addSubview:self.icon];

    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.icon.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.icon.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.icon.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.icon.widthAnchor constraintEqualToConstant:30].active = YES;

    // Notification count
    self.countLabel = [UILabel new];
    self.countLabel.userInteractionEnabled = NO;
    [self addSubview:self.countLabel];

    self.countLabel.textAlignment = NSTextAlignmentCenter;

    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel.topAnchor constraintEqualToAnchor:self.icon.bottomAnchor].active = YES;
    [self.countLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.countLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:self.frame.size.width].active = YES;


    // Close view
    self.closeView = [UIView new];
    self.closeView.hidden = YES;
    self.closeView.layer.cornerRadius = 13;
    self.closeView.backgroundColor = [UIColor redColor];
    [self addSubview:self.closeView];

    self.closeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeView.bottomAnchor constraintEqualToAnchor:blur.topAnchor constant:-4].active = YES;
    [self.closeView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.closeView.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.closeView.widthAnchor constraintEqualToConstant:20].active = YES;;
    [self layoutIfNeeded];

    // self.closeView = [UIImageView new];
    // self.closeView.image = [UIImage systemImageNamed:@"xmark.circle"];
    // self.closeView.tintColor = [UICol

    UIView *blur2 = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    blur2.frame = self.closeView.bounds;
    blur2.layer.cornerRadius = 13;
    blur2.layer.cornerCurve = kCACornerCurveContinuous;
    [self.closeView addSubview:blur2];

    UILabel *X = [UILabel new];
    X.textAlignment = NSTextAlignmentCenter;
    X.backgroundColor = [UIColor clearColor];
    X.frame = self.closeView.bounds;
    X.text = @"x";
    X.font = [UIFont systemFontOfSize:10];
    [self.closeView addSubview:X];
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.lineCap = kCALineCapRound;

    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeEnd = 0;
    
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:self.closeView.center radius:10 startAngle:-M_PI/2 endAngle:2* M_PI clockwise:YES].CGPath;

    [self.layer addSublayer:self.shapeLayer];
    

    // Pan gesture
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.pan];

    self.pan.delegate = self;
    self.taptic = [[UINotificationFeedbackGenerator alloc] init];
    self.willBeRemoved = NO;
    
    return self;
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    // CGFloat yDistance = self.frame.origin.y - self.initialFrame.origin.y;

    CGFloat movement = translation.y > 0 ? pow(translation.y, 0.7) : -pow(-translation.y, 0.7);

    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.initialFrame = self.frame;
            self.willBeRemoved = NO;
            self.closeView.hidden = NO;
            break;
            
        case UIGestureRecognizerStateChanged:
            self.frame = CGRectMake(self.initialFrame.origin.x, movement, self.frame.size.width, self.frame.size.height);
            self.shapeLayer.strokeEnd = movement >= self.frame.size.height / 3 ? 1 : movement / (self.frame.size.height / 3);
            
            if(movement >= self.frame.size.height / 3 && !self.willBeRemoved) {
                self.willBeRemoved = YES;
                // [self.taptic notificationOccurred:UINotificationFeedbackTypeWarning];
            
            } else if(movement < self.frame.size.height / 3) {
                self.willBeRemoved = NO;
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            if(self.willBeRemoved) {
                [self.taptic notificationOccurred:UINotificationFeedbackTypeSuccess];
                // Remove cell
                [[TKOController sharedInstance] removeAllNotificationsWithBundleID:self.bundleID];
            } else {
                [self.taptic notificationOccurred:UINotificationFeedbackTypeError];
            }
            self.frame = self.initialFrame;
            self.shapeLayer.strokeEnd = 0;
            self.closeView.hidden = YES;
            break;
            
        default:
            self.frame = self.initialFrame;
            self.shapeLayer.strokeEnd = 0;
            self.closeView.hidden = YES;
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [[objc_getClass("SBIdleTimerGlobalCoordinator") sharedInstance] resetIdleTimer];
    if(gestureRecognizer != self.pan) return YES;

    CGPoint velocity = [self.pan velocityInView:self];
    return fabs(velocity.y) > fabs(velocity.x);
}

// - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//     // CGPoint velocity = [self.pan velocityInView:self];
//     // return fabs(velocity.y) > fabs(velocity.x);
//     return YES;
// }

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.icon.image = nil;
    self.backgroundColor = [UIColor clearColor];
    self.bundleID = nil;
}

- (void) setBundleIdentifier:(NSString *)identifier {
    self.bundleID = identifier;
    UIImage *appIcon = [[[TKOController sharedInstance] getIconForIdentifier:identifier] copy];
    self.icon.image = appIcon ?: [UIImage new];
}

- (void) setCount:(NSInteger) count {
    self.countLabel.text = [NSString stringWithFormat:@"%ld", count];
}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];

    if(selected) {
        self.backgroundColor = [Kuro getPrimaryColor:self.icon.image];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
