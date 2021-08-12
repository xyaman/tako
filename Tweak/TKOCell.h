#import <UIKit/UIKit.h>

@interface TKOCell : UICollectionViewCell
@property(nonatomic, retain) UIImageView *icon;
@property(nonatomic, retain) NSString *identifier;

- (void) setBundleIdentifier:(NSString *)identifier;
@end