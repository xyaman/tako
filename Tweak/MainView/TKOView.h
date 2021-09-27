#import <UIKit/UIKit.h>
#import "../UI/TKOCloseView.h"

@interface TKOView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
// Views
@property(nonatomic, retain) UICollectionView *colView;
@property(nonatomic, retain) UICollectionViewFlowLayout *colLayout;

// Remove all view
@property(nonatomic, retain) TKOCloseView *removeAllView;

// Cells info related
@property(nonatomic, retain) NSMutableArray *cellsInfo;
@property(nonatomic, retain) NSString *lastBundleUpdated;
@property(nonatomic) NSString *selectedBundleID;

// Other
@property(nonatomic, retain) UISelectionFeedbackGenerator *selectionFeedback;
@property(nonatomic, retain) UINotificationFeedbackGenerator *notificationFeedback;
@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;

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
