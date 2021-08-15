#import <UIKit/UIKit.h>
#import "TKOBundle.h"

#import <Kuro/libKuro.h>

@interface TKOCell : UICollectionViewCell <UIGestureRecognizerDelegate>
// Close view
@property(nonatomic, retain) UIView *closeView;
@property(nonatomic, retain) CAShapeLayer *closeShapeLayer;

// Main view
@property(nonatomic, retain) UIImageView *iconView;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic, retain) UIView *blur;
@property(nonatomic, retain) TKOBundle *bundle;

// Gesture
@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property(nonatomic, retain) UINotificationFeedbackGenerator *taptic;
@property(nonatomic) BOOL willBeRemoved;
@property(nonatomic) CGRect initialFrame;

- (void) updateColors;
@end