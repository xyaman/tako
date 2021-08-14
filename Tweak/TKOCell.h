#import <UIKit/UIKit.h>

#import <Kuro/libKuro.h>

@interface TKOCell : UICollectionViewCell <UIGestureRecognizerDelegate>
// Close view
@property(nonatomic, retain) UIView *closeView;
@property(nonatomic, retain) CAShapeLayer *closeShapeLayer;

// Main view
@property(nonatomic, retain) UIImageView *iconView;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic, retain) UIView *blur;
@property(nonatomic, retain) NSString *bundleID;

// Gesture
@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property(nonatomic, retain) UINotificationFeedbackGenerator *taptic;
@property(nonatomic) BOOL willBeRemoved;
@property(nonatomic) CGRect initialFrame;

// This also adds icon
- (void) setBundleIdentifier:(NSString *)identifier;
- (void) setCount:(NSInteger) count;
@end