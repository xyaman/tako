#import <UIKit/UIKit.h>
#import "TKOBundle.h"


@interface TKOCell : UICollectionViewCell <UIGestureRecognizerDelegate>
@property(nonatomic, retain) TKOBundle *bundle;

// Close view
@property(nonatomic, retain) UIView *closeView;
@property(nonatomic, retain) CAShapeLayer *closeShapeLayer;

// Main view
@property(nonatomic, retain) UIImageView *iconView;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic, retain) UIView *blur;
@property(nonatomic, retain) UIView *bottomBar;

// Gesture
@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property(nonatomic, retain) UINotificationFeedbackGenerator *taptic;
@property(nonatomic) BOOL willBeRemoved;
@property(nonatomic) CGRect initialFrame;

+ (CGSize) cellSize;
- (void) update;
@end