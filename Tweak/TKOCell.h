#import <UIKit/UIKit.h>

#import <Kuro/libKuro.h>

@interface TKOCell : UICollectionViewCell
@property(nonatomic, retain) UIImageView *icon;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) UIView *blur;

- (void) setBundleIdentifier:(NSString *)identifier;
- (void) setCount:(NSInteger) count;

- (void) select;
- (void) unselect;
@end