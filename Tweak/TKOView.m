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
    self.colLayout.itemSize = CGSizeMake(self.frame.size.height - 20, self.frame.size.height - 10);
    
    // UICollection
    self.colView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:self.colLayout];
    self.colView.clipsToBounds = YES;
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.colView.backgroundColor = [UIColor clearColor];
    self.colView.showsHorizontalScrollIndicator = NO;

    // Register TKOCell
    [self.colView registerClass:[TKOCell class] forCellWithReuseIdentifier:@"TKOCell"];
    [self addSubview:self.colView];

    // Current cell list info
    self.cellsInfo = [NSMutableArray new];
    self.selectedBundle = nil;

    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void) update {
    [self.cellsInfo removeAllObjects];

    for(NSString *key in [TKOController sharedInstance].notifications) {
        NSArray *bundleNotifs = [TKOController sharedInstance].notifications[key];
        [self.cellsInfo addObject:[@{@"bundleID": key, @"count":[NSNumber numberWithInteger:bundleNotifs.count]} mutableCopy]];
    }

    // Do ordering
    [self sortCells];
    [self.colView reloadData];
}

- (void) updateCellWithIdentifier:(NSString *)identifier {
    
    int index = 0;

    @synchronized(self.cellsInfo) {
        for(NSMutableDictionary *cellInfo in self.cellsInfo) {
            if([cellInfo[@"bundleID"] isEqualToString:identifier]) {
                NSArray *bundleNotifs = [TKOController sharedInstance].notifications[identifier];
                cellInfo[@"count"] = [NSNumber numberWithInteger:bundleNotifs.count];
                break;
            }
            index += 1;
        }
    }

    // [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:YES], nil]];
    // NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
    // NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    // self.cellsInfo = [[self.cellsInfo sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    // [self.colView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    if(self.sortBy == 0) {
        [self sortCells];
        [self.colView reloadData];
    
    } else {
        [self.colView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }
}

- (void) sortCells {
    // Count
    if(self.sortBy == 0) [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO], nil]];

    // Bundle name
    else if(self.sortBy == 1) [self.cellsInfo sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"bundleID" ascending:YES], nil]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // if(section != 0) return 0;
    return self.cellsInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TKOCell *cell = [self.colView dequeueReusableCellWithReuseIdentifier:@"TKOCell" forIndexPath:indexPath];
    NSDictionary *info = self.cellsInfo[indexPath.item]; 

    BOOL isSelected = [info[@"bundleID"] isEqualToString:self.selectedBundle];

    [cell setBundleIdentifier:info[@"bundleID"]];
    [cell setCount:[info[@"count"] intValue]];

    if(isSelected) [self.colView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TKOCell *cell = (TKOCell *)[self.colView cellForItemAtIndexPath:indexPath];

    NSDictionary *info = self.cellsInfo[indexPath.item]; 
    BOOL isSelected = [info[@"bundleID"] isEqualToString:self.selectedBundle];
    
    if(isSelected) {
        self.selectedBundle = nil;
        [self.colView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:self.colView didDeselectItemAtIndexPath:indexPath];
        return NO;
    }

    [[TKOController sharedInstance] hideAllNotifications];
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TKOCell *cell = (TKOCell *)[self.colView cellForItemAtIndexPath:indexPath];

    // When cell is selected, we reset the global timer
    [[objc_getClass("SBIdleTimerGlobalCoordinator") sharedInstance] resetIdleTimer];
    
    NSDictionary *info = self.cellsInfo[indexPath.item];
    self.selectedBundle = [info[@"bundleID"] copy];
    [[TKOController sharedInstance] showNotificationAllWithIdentifier:info[@"bundleID"]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TKOCell *cell = (TKOCell *)[self.colView cellForItemAtIndexPath:indexPath];

    NSDictionary *info = self.cellsInfo[indexPath.item];
    [[TKOController sharedInstance] hideNotificationAllWithIdentifier:info[@"bundleID"]];
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
    CGFloat padding = ((contentWidth - totalCellWidth) / 2.0) - itemSpacing/2;
    insets.left = padding;
    insets.right = padding;
    return insets;
}


@end