#import <UIKit/UIKit.h>

#import "TKOCell.h"

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;
@property(nonatomic) int sortBy;
@property(nonatomic) int displayBy;

@property(nonatomic) NSMutableArray *cellsInfo;
@property(nonatomic) NSString *selectedBundle;
@property(nonatomic, retain) NSString *lastBundleUpdated;

- (void) update;
- (void) updateWithNewBundle:(NSString *)bundle;
- (void) updateCellWithIdentifier:(NSString *) identifier;
- (void) prepareForDisplay; // Did move to window??

// Sort
- (void) sortCells;
@end