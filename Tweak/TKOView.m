#import "TKOView.h"
#import "TKOController.h"
#import "objc/runtime.h"

@interface TKOView ()
@end

@implementation TKOView
- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;

    // UICollection layout
    self.colLayout = [UICollectionViewFlowLayout new];
    self.colLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    if([[TKOController sharedInstance].cellStyle intValue] == 0) self.colLayout.itemSize = CGSizeMake(60, 80);
    else if([[TKOController sharedInstance].cellStyle intValue] == 1) self.colLayout.itemSize = CGSizeMake(58, 33);
    
    // UICollection
    self.colView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:self.colLayout];
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
    [self.cellsInfo removeAllObjects];

    for(NSString* bundleID in [TKOController sharedInstance].notifications) {
        __weak NSArray *bundle = [TKOController sharedInstance].notifications[bundleID];
        [self.cellsInfo addObject:[@{@"bundleID": bundleID, @"count":[NSNumber numberWithInteger:bundle.count]} mutableCopy]];
    } 

    [self sortCells];
    [self.colView reloadData];
}

- (void) updateCellWithBundle:(NSString *)bundleID {

    NSInteger cellIndex = [self getCellIndexByBundle:bundleID];
    __weak NSArray *bundle = [TKOController sharedInstance].notifications[bundleID];
    self.cellsInfo[cellIndex][@"count"] = [NSNumber numberWithInteger:bundle.count];

    // If we are sorting by notification count, we need to update all cells again
    if(self.sortBy == 0) {
        [self sortCells];
        [self.colView reloadData];
    
    // Otherwise we only update this cell
    } else {
        [self.colView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
    }
}

- (void) prepareForDisplay {
    if(self.cellsInfo.count == 0) return;

    if(self.displayBy == 0) {
        // Do nothing
    
    } else if(self.displayBy == 1) {

        if(!self.lastBundleUpdated) {
            // self.selectedBundleID = nil;
            // [[TKOController sharedInstance] removeAllNotifications];
            [self.colView reloadData];
            return;
        }
        
        [[TKOController sharedInstance] hideAllNotifications];
        self.selectedBundleID = [self.lastBundleUpdated copy];
        [self.colView reloadData];


    } else if(self.displayBy == 2) {
        self.selectedBundleID = nil;
        [[TKOController sharedInstance] hideAllNotifications];
        [self.colView reloadData];
    }
}

- (void) sortCells {
    // Count
    if(self.sortBy == 0) [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO], nil]];

    // Bundle name
    else if(self.sortBy == 1) [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"bundleID" ascending:YES], nil]];
}


- (NSInteger) getCellIndexByBundle:(NSString *)bundleID {

    for(NSInteger i = self.cellsInfo.count - 1; i >= 0; i--) {
        if([self.cellsInfo[i][@"bundleID"] isEqualToString:bundleID]) return i;
    }

    return -1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section != 0) return 0;
    return self.cellsInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TKOCell *cell = [self.colView dequeueReusableCellWithReuseIdentifier:@"TKOCell" forIndexPath:indexPath];
    NSDictionary *info = self.cellsInfo[indexPath.item]; 

    BOOL isSelected = [info[@"bundleID"] isEqualToString:self.selectedBundleID];

    [cell setBundleIdentifier:info[@"bundleID"]];
    [cell setCount:[info[@"count"] intValue]];
    [cell setSelected:NO];

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

    NSDictionary *info = self.cellsInfo[indexPath.item]; 
    BOOL isSelected = [info[@"bundleID"] isEqualToString:self.selectedBundleID];
    
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
    self.lastBundleUpdated = nil;

    // We get cell bundleID and show all notifications for that bundle
    NSDictionary *info = self.cellsInfo[indexPath.item];
    self.selectedBundleID = [info[@"bundleID"] copy];
    [[TKOController sharedInstance] insertAllNotificationsWithBundleID:info[@"bundleID"]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Hide all notifications from the cell that was just deselected
    NSDictionary *info = self.cellsInfo[indexPath.item];
    [[TKOController sharedInstance] hideAllNotificationsWithBundleID:info[@"bundleID"]];
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