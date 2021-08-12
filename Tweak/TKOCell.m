#import "TKOCell.h"
#import "TKOController.h"
#import "objc/runtime.h"

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

    UIView *blur = [objc_getClass("MTMaterialView") materialViewWithRecipe:MTMaterialRecipeNotifications configuration:1];
    blur.frame = self.bounds;
    [self addSubview:blur];

    // self.icon = [[UIImageView alloc] initWithFrame:self.bounds];
    self.icon = [UIImageView new];
    self.icon.userInteractionEnabled = NO;
    [self addSubview:self.icon];

    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.icon.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.icon.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.icon.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.icon.widthAnchor constraintEqualToConstant:30].active = YES;


    self.countLabel = [UILabel new];
    self.countLabel.userInteractionEnabled = NO;
    [self addSubview:self.countLabel];

    self.countLabel.textAlignment = NSTextAlignmentCenter;

    self.countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.countLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10].active = YES;
    [self.countLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.countLabel.heightAnchor constraintEqualToConstant:15].active = YES;
    [self.countLabel.widthAnchor constraintEqualToConstant:15].active = YES;
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.icon.image = nil;
    self.backgroundColor = [UIColor clearColor];
}

- (void) setBundleIdentifier:(NSString *)identifier {
    UIImage *appIcon = [[[TKOController sharedInstance] getIconForIdentifier:identifier] copy];
    self.icon.image = appIcon ?: [UIImage new];
}

- (void) setCount:(NSInteger) count {
    self.countLabel.text = [NSString stringWithFormat:@"%ld", count];
}

- (void) select {
    
}
- (void) unselect {
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if(selected) {
        self.backgroundColor = [Kuro getPrimaryColor:self.icon.image];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
