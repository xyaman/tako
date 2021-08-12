#import <UIKit/UIKit.h>

#import "TKOCell.h"

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;

@property(nonatomic) NSMutableArray *list;

- (void) update;
@end