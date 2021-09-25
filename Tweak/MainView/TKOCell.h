#import <UIKit/UIKit.h>

#import "../Controller/TKOBundle.h"
#import "../UI/TKOCloseView.h"


@interface TKOCell : UICollectionViewCell <UIGestureRecognizerDelegate>
@property(nonatomic, retain) TKOBundle *bundle;

// Close view
@property(nonatomic, retain) TKOCloseView *closeView;

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
