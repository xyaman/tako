#import "TKOView.h"
#import "TKOController.h"
#import "objc/runtime.h"
#import "TKOCell.h"

@interface TKOView ()
@end

@implementation TKOView
- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;

    // UICollection layout
    self.colLayout = [UICollectionViewFlowLayout new];
    self.colLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.colLayout.itemSize = [TKOCell cellSize];
    
    // UICollection
    self.colView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.colLayout];
    self.colView.clipsToBounds = YES;
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.colView.backgroundColor = [UIColor clearColor];
    self.colView.showsHorizontalScrollIndicator = NO;
    self.colView.automaticallyAdjustsScrollIndicatorInsets = NO;
    // self.colView.pagingEnabled = YES;

    // Register TKOCell
    [self.colView registerClass:[TKOCell class] forCellWithReuseIdentifier:@"TKOCell"];
    [self addSubview:self.colView];

    self.colView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.colView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.colView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.colView.heightAnchor constraintEqualToConstant:self.frame.size.height].active = YES;

    // [self setNeedsLayout];
    // [self layoutIfNeeded];

    // Current cell list info
    self.cellsInfo = [NSMutableArray new];
    self.selectedBundleID = nil;

    // Other
    self.selectionFeedback = [[UISelectionFeedbackGenerator alloc] init];

    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

// iPad issue
-(void)setSizeToMimic:(CGSize)arg1 {}
-(CGSize)sizeToMimic {return self.frame.size;}

- (void) updateAllCells {
    self.cellsInfo = [[TKOController sharedInstance].bundles mutableCopy];
    if(self.cellsInfo.count == 0) self.selectedBundleID = nil;

    [self sortCells];
    [self.colView reloadData];
}

- (void) updateCellWithBundle:(NSString *)bundleID {

    // If we are sorting by notification count, we need to update all cells again
    if(self.sortBy == SortByLastestNotification || self.sortBy == SortByNotificationCount) {
        [self updateAllCells];
    
    // Otherwise we only update this cell
    } else {
        self.cellsInfo = [[TKOController sharedInstance].bundles mutableCopy];
        NSInteger cellIndex = [self getCellIndexByBundle:bundleID];
        if(cellIndex != NSNotFound) [self.colView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
    }
}

- (void) prepareForDisplay {
    if(self.cellsInfo.count == 0) return;

    if(self.displayBy == DisplayByLastAppNotification && self.lastBundleUpdated) {

        self.selectedBundleID = [self.lastBundleUpdated copy];
        NSInteger cellIndex = [self getCellIndexByBundle:self.selectedBundleID];
        if(cellIndex != NSNotFound) [self collectionView:self.colView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];

    } else if(self.displayBy == DisplayByAllClosed) {
        self.selectedBundleID = nil;
        [self.colView reloadData];
    
    } else if(self.selectedBundleID && self.displayBy != DisplayByItWasBefore) {
        NSInteger cellIndex = [self getCellIndexByBundle:self.selectedBundleID];
        if(cellIndex != NSNotFound) [self collectionView:self.colView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
    }

    [[TKOController sharedInstance].nlc revealNotificationHistory:YES animated:YES];
    [[TKOController sharedInstance].nlc _resetCellWithRevealedActions];
}

- (void) prepareToHide {
    // We dont want to do anything
    if(self.cellsInfo.count == 0 || self.displayBy == DisplayByItWasBefore) return;

    [[TKOController sharedInstance] hideAllNotifications];

    if(self.displayBy == DisplayByLastAppNotification && self.lastBundleUpdated) {
        NSInteger cellIndex = [self getCellIndexByBundle:self.lastBundleUpdated];
        if(cellIndex != NSNotFound) [self collectionView:self.colView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];

    } else if(self.selectedBundleID) {
        NSInteger cellIndex = [self getCellIndexByBundle:self.selectedBundleID];
        if(cellIndex != NSNotFound) [self collectionView:self.colView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
    }
}

- (void) sortCells {
    // Count
    if(self.sortBy == SortByLastestNotification && self.cellsInfo.count > 1) {
        [self.cellsInfo sortUsingComparator:^NSComparisonResult(TKOBundle *a, TKOBundle *b) {
            return [b.lastUpdate compare:a.lastUpdate];
        }];
    
    } else if(self.sortBy == SortByNotificationCount && self.cellsInfo.count > 1) {
        [self.cellsInfo sortUsingComparator:^NSComparisonResult(TKOBundle *a, TKOBundle *b) {
            return [b.ID compare:a.ID];
        }];
    }

    
    // // Bundle name
    // else if(self.sortBy == 1 && self.cellsInfo.count > 1) [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"bundleID" ascending:YES], nil]];
}


- (NSInteger) getCellIndexByBundle:(NSString *)bundleID {

    for(NSInteger i = self.cellsInfo.count - 1; i >= 0; i--) {
       TKOBundle *bundle = self.cellsInfo[i];
       if([bundle.ID isEqualToString:bundleID]) return i;
    }

    return NSNotFound;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section != 0) return 0;
    return self.cellsInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TKOCell *cell = [self.colView dequeueReusableCellWithReuseIdentifier:@"TKOCell" forIndexPath:indexPath];
    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 

    BOOL isSelected = [bundle.ID isEqualToString:self.selectedBundleID];

    cell.bundle = bundle;
    [cell setSelected:NO];
    [cell updateColors];

    if(isSelected) {
        [cell setSelected:YES];
        [self.colView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.colView didSelectItemAtIndexPath:indexPath];
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TKOCell *cell = (TKOCell *)[self.colView cellForItemAtIndexPath:indexPath];
    [self.selectionFeedback selectionChanged];

    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 
    BOOL isSelected = [bundle.ID isEqualToString:self.selectedBundleID];

    self.lastBundleUpdated = nil;
    
    // We unselect and prevent from being selected
    if(isSelected) {
        self.selectedBundleID = nil;
        [self.colView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:self.colView didDeselectItemAtIndexPath:indexPath];
        return NO;
    }

    // Otherwise we clean all and show
    [[TKOController sharedInstance] hideAllNotifications];
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // When cell is selected, we reset the global timer, so the screen is not turned off
    [[objc_getClass("SBIdleTimerGlobalCoordinator") sharedInstance] resetIdleTimer];

    // We get cell bundleID and show all notifications for that bundle
    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 
    self.selectedBundleID = [bundle.ID copy];
    [[TKOController sharedInstance] insertAllNotificationsWithBundleID:bundle.ID];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Hide all notifications from the cell that was just deselected
    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 
    [[TKOController sharedInstance] hideAllNotificationsWithBundleID:bundle.ID];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    CGFloat itemSpacing = self.colLayout.minimumInteritemSpacing;
    CGFloat cellWidth = self.colLayout.itemSize.width + itemSpacing;
    UIEdgeInsets insets = self.colLayout.sectionInset;

    // Make sure to remove the last item spacing or it will
    // miscalculate the actual total width.
    CGFloat totalCellWidth = (cellWidth * self.cellsInfo.count) - itemSpacing;
    CGFloat contentWidth = self.colView.frame.size.width - self.colView.contentInset.left - self.colView.contentInset.right;


    // If the number of cells that exist take up less room than the
    // collection view width, then center the content with the appropriate insets.
    // Otherwise return the default layout inset.
    if (totalCellWidth > contentWidth) return insets;


    // Calculate the right amount of padding to center the cells.
    CGFloat padding = ((contentWidth - totalCellWidth) / 2.0);
    insets.left = padding;
    insets.right = padding;
    return insets;
}


@end