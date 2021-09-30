#import "TKOBundle.h"
#import <objc/runtime.h>
#import "TKOController.h"

#import "GcUniversal/GcImageUtils.h"

@interface TKOBundle ()
@end

@implementation TKOBundle
+ (instancetype) initWithNCNotificationRequest:(NCNotificationRequest *)req {
    TKOBundle *bundle = [TKOBundle alloc];

    bundle.ID = [req.bulletin.sectionID copy];
    bundle.notifications = [@[[req copy]] mutableCopy];
    bundle.lastUpdate = [req.timestamp copy];
    
    SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance]; 
    SBIcon *sbIcon = [iconController.model applicationIconForBundleIdentifier:bundle.ID];

    

    bundle.icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];

    // Fallback icon is preferences
    if(!bundle.icon) {
        sbIcon = [iconController.model applicationIconForBundleIdentifier:@"com.apple.Preferences"];
        bundle.icon = [sbIcon iconImageWithInfo:(struct SBIconImageInfo){60,60,2,0}];
    }

    if([TKOController sharedInstance].prefUseStockColoring) bundle.primaryColor = [Kuro getPrimaryColor:[UIImage stockImgForBundleID:bundle.ID]];
    else bundle.primaryColor = [Kuro getPrimaryColor:bundle.icon];

    bundle.foregroundColor = [Kuro isDarkColor:bundle.primaryColor] ? [UIColor whiteColor] : [UIColor blackColor];

    return bundle;
}

- (UIImage *) resizedIconWithSize:(CGSize)newSize {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext){[self.icon drawInRect:(CGRect) {.origin = CGPointZero, .size = newSize}];}];
    return [image imageWithRenderingMode:self.icon.renderingMode];
}

- (void) newNotification:(NCNotificationRequest *) req{
    self.lastUpdate = [req.timestamp copy];
    [self.notifications addObject:req];
}

- (void) updateNotification:(NCNotificationRequest *) req{
    for(int i = self.notifications.count - 1; i >= 0; i--) {
        NCNotificationRequest *oldReq = self.notifications[i];
        if([oldReq.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
            [self.notifications removeObjectAtIndex:i];
            [self.notifications insertObject:[req copy] atIndex:i];
            break;
        }
    }
}

- (void) removeNotification:(NCNotificationRequest *)req {
    for (NSInteger i = self.notifications.count - 1; i >= 0; i--) {
        NCNotificationRequest *oldReq = self.notifications[i];
        if([oldReq.notificationIdentifier isEqualToString:req.notificationIdentifier]) {
            [self.notifications removeObjectAtIndex:i];
            break;
        }
    }
}
@end
