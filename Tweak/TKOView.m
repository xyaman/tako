#import "TKOView.h"
#import "TKOController.h"

@interface TKOView ()
@end

@implementation TKOView
- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;

    // UICollection layout
    self.colLayout = [UICollectionViewFlowLayout new];
    self.colLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.colLayout.itemSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
    
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
    self.list = [NSMutableArray new];

    // NSMutableArray *bla = @{};

    return self;
}

- (void) update {
    [self.list removeAllObjects];

    for(NSString *key in [TKOController sharedInstance].notifications) {
        [self.list addObject:key];
    }

    [self.colView reloadData];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TKOCell *cell = [self.colView dequeueReusableCellWithReuseIdentifier:@"TKOCell" forIndexPath:indexPath];
    [cell setBundleIdentifier:self.list[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [TKOController sharedInstance].isTkoCall = YES;
    // show all
    NSMutableArray *reqList = [TKOController sharedInstance].notifications[self.list[indexPath.item]];

    for (NSInteger i = reqList.count - 1; i >= 0; i--) {
        [[TKOController sharedInstance].nlc insertNotificationRequest:reqList[i]];
    }

    [TKOController sharedInstance].isTkoCall = NO;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [TKOController sharedInstance].isTkoCall = YES;
    //
    NSMutableArray *reqList = [TKOController sharedInstance].notifications[self.list[indexPath.item]];

    for (NSInteger i = reqList.count - 1; i >= 0; i--) {
        [[TKOController sharedInstance].nlc removeNotificationRequest:reqList[i]];
    }
    [TKOController sharedInstance].isTkoCall = NO;
}


@end