#import <UIKit/UIKit.h>

@interface TKOGroupView : UIView
@property(nonatomic, retain) NSMutableArray *iconsView;
@property(nonatomic) BOOL isVisible;
@property(nonatomic) BOOL needsFrameZero;
@property(nonatomic) BOOL isUpdating;

// Other
@property(nonatomic, retain) UISelectionFeedbackGenerator *taptic;

// Settings
@property(nonatomic) BOOL roundedIcons;
@property(nonatomic) CGFloat width;
@property(nonatomic) NSInteger iconsCount;
@property(nonatomic) CGFloat iconSpacing;

@property(nonatomic, retain) UIView *blur;

- (void) show;
- (void) hide;
- (void) update;
- (void) reload;
@end
