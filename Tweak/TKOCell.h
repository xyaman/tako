#import <UIKit/UIKit.h>

#import <Kuro/libKuro.h>

@interface TKOCell : UICollectionViewCell <UIGestureRecognizerDelegate>
@property(nonatomic, retain) UIView *closeView;
@property(nonatomic, retain) UIImageView *icon;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) UIView *blur;
@property(nonatomic, retain) NSString *bundleID;

- (void) setBundleIdentifier:(NSString *)identifier;
- (void) setCount:(NSInteger) count;
@end