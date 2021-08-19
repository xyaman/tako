#import <UIKit/UIKit.h>

@interface TKOGroupView : UIView
@property(nonatomic, retain) NSMutableArray *iconsView;
// @property(nonatomic, retain) UILabel *moreView;
@property(nonatomic) BOOL isVisible;
@property(nonatomic, retain) UISelectionFeedbackGenerator *taptic;
@property(nonatomic) BOOL needsFrameZero;

// Settings
@property(nonatomic) BOOL roundedIcons;
@property(nonatomic) CGFloat width;
@property(nonatomic) NSInteger iconsCount;
@property(nonatomic) NSInteger iconSpacing;

@property(nonatomic, retain) UIView *blur;

- (void) show;
- (void) hide;
- (void) update;
- (void) reload;
@end