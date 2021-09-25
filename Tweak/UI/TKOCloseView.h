#import "UIKit/UIKit.h"
#import "../IOSHeaders.h"

@interface TKOCloseView : UIView
@property(nonatomic, retain) CAShapeLayer *shapeLayer;
@property(nonatomic, retain) UIView *blurView;
@property(nonatomic, retain) UIImageView *iconView;

// Constraints
@property(nonatomic, retain) NSLayoutConstraint* bottomConstraint;
@property(nonatomic, retain) NSLayoutConstraint* rightConstraint;
@end
