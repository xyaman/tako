#import <UIKit/UIKit.h>

@interface TKOGroupView : UIView
@property(nonatomic, retain) NSMutableArray *iconsView;
@property(nonatomic) BOOL isVisible;
@property(nonatomic) NSInteger iconsCount;
@property(nonatomic) CGFloat width;

@property(nonatomic, retain) UIView *blur;

- (void) show;
- (void) hide;
- (void) update;
- (void) reload;
@end