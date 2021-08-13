#import <UIKit/UIKit.h>

#import "TKOCell.h"

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;
@property(nonatomic) int sortBy;
@property(nonatomic) int displayBy;

@property(nonatomic, retain) NSMutableArray *cellsInfo;
@property(nonatomic, retain) NSString *lastBundleUpdated;
@property(nonatomic) NSString *selectedBundleID;

// Update methods
- (void) updateAllCells; // Called when there is a new cell
- (void) updateCellWithBundle:(NSString *)bundleID; // Called when only ONE cell was updated
- (void) prepareForDisplay;

// Utils
- (NSInteger) getCellIndexByBundle:(NSString *)bundleID;
- (void) sortCells;
@end