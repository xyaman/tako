#import "TKOCell.h"
#import "TKOController.h"

@interface TKOCell ()
@end

@implementation TKOCell

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // Settings
    self.layer.cornerRadius = 13;
    self.clipsToBounds = YES;
    
    // Blur
    self.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurEffectView];

    self.icon = [[UIImageView alloc] initWithFrame:self.bounds];
    self.icon.userInteractionEnabled = NO;
    [self addSubview:self.icon];
    
    return self;
}

- (void) setBundleIdentifier:(NSString *)identifier {
    UIImage *appIcon = [[[TKOController sharedInstance] getIconForIdentifier:identifier] copy];
    self.icon.image = appIcon ?: [UIImage new];
}

@end
