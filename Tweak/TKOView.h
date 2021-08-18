#import <UIKit/UIKit.h>

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
// Views
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;

@property(nonatomic) int displayBy;
@property(nonatomic) int sortBy;

// Cells info related
@property(nonatomic, retain) NSMutableArray *cellsInfo;
@property(nonatomic, retain) NSString *lastBundleUpdated;
@property(nonatomic) NSString *selectedBundleID;

// Other
@property(nonatomic, retain) UISelectionFeedbackGenerator *selectionFeedback;

// Update methods
- (void) updateAllCells; // Called when there is a new cell
- (void) updateCellWithBundle:(NSString *)bundleID; // Called when only ONE cell was updated
- (void) prepareForDisplay;
- (void) prepareToHide;
- (void) deselectCurrentCell;

// Utils
- (NSInteger) getCellIndexByBundle:(NSString *)bundleID;
- (void) sortCells;
@end