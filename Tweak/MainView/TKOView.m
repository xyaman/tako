#import "objc/runtime.h"
#import "TKOView.h"
#import "TKOCell.h"

#import "../Controller/TKOController.h"

@interface TKOView ()
@property(nonatomic) CGRect initialFrame;
@property(nonatomic) BOOL willBeRemoved;
@property(nonatomic, retain) NSLayoutConstraint* rightConstraint;
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
    self.colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.colLayout];
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.colView.backgroundColor = [UIColor clearColor];
    self.colView.showsHorizontalScrollIndicator = NO;
    self.colView.automaticallyAdjustsScrollIndicatorInsets = NO;

    // Register TKOCell
    [self.colView registerClass:[TKOCell class] forCellWithReuseIdentifier:@"TKOCell"];
    [self addSubview:self.colView];

    self.colView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.colView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.colView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.colView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;

    // Current cell list info
    self.cellsInfo = [NSMutableArray new];
    self.selectedBundleID = nil;

    // Other
    self.selectionFeedback = [UISelectionFeedbackGenerator new];
    self.notificationFeedback = [UINotificationFeedbackGenerator new];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.delegate = self;
    [self.colView addGestureRecognizer:self.panGesture];

    // Close view
    self.removeAllView = [TKOCloseView new];
    self.removeAllView.hidden = YES;
    [self addSubview:self.removeAllView];

    self.removeAllView.translatesAutoresizingMaskIntoConstraints = NO;
    self.removeAllView.rightConstraint = [self.removeAllView.rightAnchor constraintEqualToAnchor:self.leftAnchor constant:-4];
    self.removeAllView.rightConstraint.active = YES;
    [self.removeAllView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.removeAllView.heightAnchor constraintEqualToConstant:25].active = YES;
    [self.removeAllView.widthAnchor constraintEqualToConstant:25].active = YES;
    [self layoutIfNeeded];

    self.removeAllView.shapeLayer.strokeColor = [UIColor redColor].CGColor;

    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void) reload {
    self.colLayout.itemSize = [TKOCell cellSize];
    [self.colLayout invalidateLayout];
    [self invalidateIntrinsicContentSize];
    [self.colView reloadData];
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

    SortBy sortBy = [TKOController sharedInstance].prefSortBy;
    
    // If we are sorting by notification count, we need to update all cells again
    if(sortBy == SortByLastestNotification || sortBy == SortByNotificationCount) {
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

    DisplayBy displayBy = [TKOController sharedInstance].prefDisplayBy;

    if(displayBy == DisplayByLastAppNotification && self.lastBundleUpdated) {

        if(![self.selectedBundleID isEqualToString:self.lastBundleUpdated]) [self deselectCurrentCell];

        self.selectedBundleID = [NSString stringWithString:self.lastBundleUpdated];
        [self.colView reloadData];
        [[TKOController sharedInstance].nlc revealNotificationHistory:YES animated:YES];
        self.lastBundleUpdated = nil;

    } else if(displayBy == DisplayByAllClosed) {
        [[TKOController sharedInstance] hideAllNotifications];
        self.selectedBundleID = nil;
        [self.colView reloadData];
    
    } else if(self.selectedBundleID) {
    }
}

- (void) prepareToHide {
    if([TKOController sharedInstance].prefDisplayBy == DisplayByAllClosed) {
        [[TKOController sharedInstance] hideAllNotifications];
        self.selectedBundleID = nil;
        [self.colView reloadData];
    }
}

- (void) deselectCurrentCell {
    NSInteger cellIndex = [self getCellIndexByBundle:self.selectedBundleID];
    if(cellIndex != NSNotFound) [self collectionView:self.colView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
}

- (void) sortCells {
    
    SortBy sortBy = [TKOController sharedInstance].prefSortBy;

    // By date
    if(sortBy == SortByLastestNotification && self.cellsInfo.count > 1) {
        [self.cellsInfo sortUsingComparator:^NSComparisonResult(TKOBundle *a, TKOBundle *b) {
            return [b.lastUpdate compare:a.lastUpdate];
        }];
    
    // By count
    } else if(sortBy == SortByNotificationCount && self.cellsInfo.count > 1) {
        [self.cellsInfo sortUsingComparator:^NSComparisonResult(TKOBundle *a, TKOBundle *b) {
            return [b.ID compare:a.ID];
        }];
    }
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
    [cell update];

    if(isSelected) {
        [cell setSelected:YES];
        [self.colView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.colView didSelectItemAtIndexPath:indexPath];
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TKOCell *cell = (TKOCell *)[self.colView cellForItemAtIndexPath:indexPath];
    if([TKOController sharedInstance].prefUseHaptic) [self.selectionFeedback selectionChanged];

    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 
    BOOL isSelected = [bundle.ID isEqualToString:self.selectedBundleID];

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
    [[TKOController sharedInstance].nlc revealNotificationHistory:YES animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Hide all notifications from the cell that was just deselected
    TKOBundle *bundle = self.cellsInfo[indexPath.item]; 
    [[TKOController sharedInstance] hideAllNotificationsWithBundleID:bundle.ID];
    [[TKOController sharedInstance].nlc revealNotificationHistory:NO animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    CGFloat itemSpacing = self.colLayout.minimumLineSpacing;
    CGFloat cellWidth = self.colLayout.itemSize.width + itemSpacing;
    UIEdgeInsets insets = self.colLayout.sectionInset;

    // Make sure to remove the last item spacing or it will
    // miscalculate the actual total width.
    CGFloat totalCellWidth = (cellWidth * self.cellsInfo.count) - itemSpacing;
    CGFloat contentWidth = self.colView.frame.size.width - self.colView.contentInset.left - self.colView.contentInset.right;


    // If the number of cells that exist take up less room than the
    // collection view width, then center the content with the appropriate insets.
    // Otherwise return the default layout inset.
    if (totalCellWidth > contentWidth) {
        self.removeAllView.rightConstraint.constant = -4;
        return insets;
    }


    // Calculate the right amount of padding to center the cells.
    CGFloat padding = ((contentWidth - totalCellWidth) / 2.0);
    insets.left = padding;
    insets.right = padding;

    // Remove all constraint
    self.removeAllView.rightConstraint.constant = -4 + padding;
    [self layoutIfNeeded];
    return insets;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [[objc_getClass("SBIdleTimerGlobalCoordinator") sharedInstance] resetIdleTimer];

    // Yes if its not our gesture
    if(gestureRecognizer != self.panGesture) return YES;

    // Gesture condition
    CGPoint velocity = [self.panGesture velocityInView:self];
    return fabs(velocity.x) > fabs(velocity.y) && velocity.x > 0 && self.colView.contentOffset.x <= 0;
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGFloat movement = translation.x > 0 ? pow(translation.x, 0.7) : -pow(-translation.x, 0.7);

    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.initialFrame = self.frame;
            self.willBeRemoved = NO;
            self.removeAllView.hidden = NO;
            break;
            
        case UIGestureRecognizerStateChanged:
            self.frame = CGRectMake(self.initialFrame.origin.x + movement, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            self.removeAllView.shapeLayer.strokeEnd = movement >= 35 ? 1 : movement / 35;

            self.willBeRemoved = movement >= 35;
            break;
            
        case UIGestureRecognizerStateEnded:
            if(self.willBeRemoved) {
                if([TKOController sharedInstance].prefUseHaptic) [self.notificationFeedback notificationOccurred:UINotificationFeedbackTypeSuccess];
                [[TKOController sharedInstance] removeAllNotifications];
            } else {
                if([TKOController sharedInstance].prefUseHaptic) [self.notificationFeedback notificationOccurred:UINotificationFeedbackTypeError];
            } 

            self.frame = CGRectMake(self.initialFrame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            self.removeAllView.hidden = YES;
            self.removeAllView.shapeLayer.strokeEnd = 0;
            break;
            
        default:
            self.removeAllView.hidden = YES;
            self.removeAllView.shapeLayer.strokeEnd = 0;
            self.frame = CGRectMake(self.initialFrame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
    }
}

@end
