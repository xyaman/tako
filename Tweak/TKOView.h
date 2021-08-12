#import <UIKit/UIKit.h>

#import "TKOCell.h"

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;

@property(nonatomic) NSMutableArray *cellsInfo;
@property(nonatomic) NSString *selectedBundle;

- (void) update;
- (void) updateCellWithIdentifier:(NSString *) identifier;
@end