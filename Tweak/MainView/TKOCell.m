#import <objc/runtime.h>
#import "TKOCell.h"

#import "../Controller/TKOController.h"

@interface TKOCell ()
@property(nonatomic) NSInteger _currentStyle;
@end

@implementation TKOCell
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // View settings
    self.layer.cornerRadius = 13;
    self.layer.cornerCurve = kCACornerCurveContinuous;
    self.backgroundColor = [UIColor clearColor];

    // Blur view
    self.blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    self.blur.layer.cornerRadius = 13;
    self.blur.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:self.blur];

    self.blur.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blur.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.blur.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.blur.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.blur.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;

    // Close view
    self.closeView = [TKOCloseView new];
    self.closeView.hidden = YES;
    [self addSubview:self.closeView];

    self.closeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.closeView.bottomAnchor constraintEqualToAnchor:self.topAnchor constant:-5].active = YES;
    [self.closeView.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.closeView.widthAnchor constraintEqualToConstant:22].active = YES;
    [self layoutIfNeeded];

    // Pan gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];

    self.panGesture.delegate = self;
    self.taptic = [[UINotificationFeedbackGenerator alloc] init];
    self.willBeRemoved = NO;


    // Save current value of cell style
    self._currentStyle = [TKOController sharedInstance].prefCellStyle;

    // Setup style
    [self setupStyle];

    return self;
}

+ (CGSize) cellSize {
    switch([TKOController sharedInstance].prefCellStyle) {
        case CellStyleDefault: return CGSizeMake(45, 60);
        case CellStyleAxonGrouped: return CGSizeMake(58, 36);
        case CellStyleFullIcon: return CGSizeMake(50, 51);
        case CellStyleFullIconWBottomBar: return CGSizeMake(50, 60);
    };

    return CGSizeZero;
}

- (void) update {

    // Update style if it has changed
    if(self._currentStyle != [TKOController sharedInstance].prefCellStyle) {
        // Load style
        self._currentStyle = [TKOController sharedInstance].prefCellStyle;

        // Remove old views
        [self.iconView removeFromSuperview];
        [self.countLabel removeFromSuperview];
        [self.bottomBar removeFromSuperview];

        self.blur.hidden = NO;
        self.bottomBar = nil; // To reduce memory (in case new style doesnt use bottom bar)
        self.layer.cornerRadius = 13;
        self.blur.layer.cornerRadius = 13;
        [self setupStyle];
    }
    

    // Default style
    if([TKOController sharedInstance].prefCellStyle == CellStyleDefault) {
       self.iconView.image = self.bundle.icon ?: [UIImage new];

    // Axon style
    } else if([TKOController sharedInstance].prefCellStyle == CellStyleAxonGrouped) {
        self.iconView.image = [self.bundle resizedIconWithSize:CGSizeMake(21, 21)];

        self.countLabel.backgroundColor = self.bundle.primaryColor;
        self.countLabel.textColor = self.bundle.foregroundColor;

    // Full icon
    } else if([TKOController sharedInstance].prefCellStyle == CellStyleFullIcon || [TKOController sharedInstance].prefCellStyle == CellStyleFullIconWBottomBar) {

        self.iconView.image = [self.bundle resizedIconWithSize:CGSizeMake(45, 45)];

        self.countLabel.backgroundColor = self.bundle.primaryColor;
        self.countLabel.textColor = self.bundle.foregroundColor;
        self.bottomBar.backgroundColor = self.bundle.primaryColor;
    }

    self.countLabel.text = [NSString stringWithFormat:@"%ld", self.bundle.notifications.count];
}

- (void) setupStyle {
    if([TKOController sharedInstance].prefCellStyle == CellStyleDefault) [self setupDefault];
    else if([TKOController sharedInstance].prefCellStyle == CellStyleAxonGrouped) [self setupAxonStyle];
    else if([TKOController sharedInstance].prefCellStyle == CellStyleFullIcon) [self setupFullIconWOBottomBar];
    else if([TKOController sharedInstance].prefCellStyle == CellStyleFullIconWBottomBar) [self setupFullIcon];
}

- (void) setupDefault {
    
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
    self.countLabel.font = [UIFont systemFontOfSize:14];

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
    [self.iconView.heightAnchor constraintEqualToConstant:21].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:21].active = YES;

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
    [self.countLabel.heightAnchor constraintEqualToConstant:21].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:21].active = YES;

    self.countLabel.layer.cornerRadius = 10;
    self.countLabel.layer.cornerCurve = kCACornerCurveContinuous;
}

- (void) setupFullIcon {
    CGFloat radius = 13;

    self.layer.cornerRadius = radius;
    self.blur.layer.cornerRadius = radius;
    self.blur.hidden = YES;

    self.iconView = [UIImageView new];
    self.iconView.userInteractionEnabled = NO;
    [self addSubview:self.iconView];

    // self.iconView.layer.cornerRadius = ;
    self.iconView.layer.cornerCurve = kCACornerCurveContinuous;
    self.iconView.clipsToBounds = YES;

    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5].active = YES;
    [self.iconView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-5].active = YES;
    [self.iconView.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:40].active = YES;

    self.countLabel = [UILabel new];
    self.countLabel.backgroundColor = [UIColor blackColor];
    self.countLabel.userInteractionEnabled = NO;
    [self addSubview:self.countLabel];

    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.clipsToBounds = YES;
    self.countLabel.font = [UIFont systemFontOfSize:11];

    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:-5].active = YES;
    [self.countLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:5].active = YES;
    [self.countLabel.heightAnchor constraintEqualToConstant:20].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:20].active = YES;

    self.countLabel.layer.cornerRadius = 10;
    self.countLabel.layer.cornerCurve = kCACornerCurveContinuous;

    // Bottom bar
    self.bottomBar = [UIView new];
    self.bottomBar.layer.cornerRadius = 3;
    self.bottomBar.backgroundColor = [UIColor blackColor];
    self.bottomBar.layer.cornerCurve = kCACornerCurveContinuous;
    [self addSubview:self.bottomBar];

    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBar.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4].active = YES;
    [self.bottomBar.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:10].active = YES;
    [self.bottomBar.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-10].active = YES;
    [self.bottomBar.heightAnchor constraintEqualToConstant:5].active = YES;
}

- (void) setupFullIconWOBottomBar {
    [self setupFullIcon];
    [self.bottomBar removeFromSuperview];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.iconView.image = nil;
    self.backgroundColor = [UIColor clearColor];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.bottomBar.backgroundColor = [UIColor clearColor];
    self.blur.hidden = NO;
    self.bundle = nil;

    // Only hide blur for full icon
    if([TKOController sharedInstance].prefCellStyle == CellStyleFullIcon || [TKOController sharedInstance].prefCellStyle == CellStyleFullIconWBottomBar) self.blur.hidden = YES;
}



- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];

    if(selected) {
        if([TKOController sharedInstance].prefCellStyle == CellStyleFullIcon || [TKOController sharedInstance].prefCellStyle == CellStyleFullIconWBottomBar) self.blur.hidden = NO;
        if([TKOController sharedInstance].prefUseAdaptiveBackground) self.backgroundColor = self.bundle.primaryColor;
    } else {
        if([TKOController sharedInstance].prefCellStyle == CellStyleFullIcon || [TKOController sharedInstance].prefCellStyle == CellStyleFullIconWBottomBar) self.blur.hidden = YES;
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
            break;
            
        case UIGestureRecognizerStateChanged:
            self.frame = CGRectMake(self.frame.origin.x, self.initialFrame.origin.y + movement, self.frame.size.width, self.frame.size.height);
            self.closeView.shapeLayer.strokeEnd = movement >= 30 ? 1 : movement / 30;
            
            self.willBeRemoved = movement >= 30;
            
            break;
            
        case UIGestureRecognizerStateEnded:
            if(self.willBeRemoved) {
                if([TKOController sharedInstance].prefUseHaptic) [self.taptic notificationOccurred:UINotificationFeedbackTypeSuccess];

                // Remove cell
                [[TKOController sharedInstance] removeAllNotificationsWithBundleID:self.bundle.ID];
            } else {
                if([TKOController sharedInstance].prefUseHaptic) [self.taptic notificationOccurred:UINotificationFeedbackTypeError];
            }
            self.closeView.hidden = YES;
            self.closeView.shapeLayer.strokeEnd = 0;
            self.frame = CGRectMake(self.frame.origin.x, self.initialFrame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
            
        default:
            self.closeView.hidden = YES;
            self.closeView.shapeLayer.strokeEnd = 0;
            self.frame = CGRectMake(self.frame.origin.x, self.initialFrame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
    }
}
@end
