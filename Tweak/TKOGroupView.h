#import <UIKit/UIKit.h>

@interface TKOGroupView : UIView
@property(nonatomic, retain) NSMutableArray *iconsView;
@property(nonatomic) NSInteger iconsCount;
@property(nonatomic) CGFloat width;

@property(nonatomic, retain) UIView *blur;

- (void) toggle;
- (void) update;
- (void) reload;
@end