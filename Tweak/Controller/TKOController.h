#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "../MainView/TKOView.h"
#import "../GroupView/TKOGroupView.h"
#import "TKOBundle.h"

@interface TKOController : NSObject
// Preferences related
@property(nonatomic) BOOL isEnabled;
// Main View
@property(nonatomic) SortBy prefSortBy; // How to sort app cell
@property(nonatomic) DisplayBy prefDisplayBy; // What to do when user opens NC/LS
@property(nonatomic) BOOL prefUseStockColoring; // Use stock color icons (in case user uses a theme)
@property(nonatomic) BOOL prefUseAdaptiveBackground; // Use adaptive color in cells (otherwise default MTMaterialView)
@property(nonatomic) BOOL prefForceCentering; // More useful for Group view
@property(nonatomic) BOOL prefUseHaptic; // Use haptic feedback
@property(nonatomic) CellStyle prefCellStyle; // Cell style
@property(nonatomic) CGFloat prefCellSpacing; // Spacing between cells
// Group View
@property(nonatomic) BOOL prefLSGroupIsEnabled;
@property(nonatomic) BOOL prefNCGroupIsEnabled;
@property(nonatomic) BOOL prefGroupAuthentication; // Automatically hide group when user authenticates
@property(nonatomic) BOOL prefGroupRoundedIcons; // Use round icons, instead of stock ones
@property(nonatomic) BOOL prefGroupWhenMusic; // Don't disable group when playing music (TODO: can lead to bugs)
@property(nonatomic) NSInteger prefGroupIconsCount; // Max number of icons
@property(nonatomic) CGFloat prefGroupIconSize;
@property(nonatomic) CGFloat prefGroupIconSpacing; // Space between icons


@property(nonatomic, retain) NSMutableArray *bundles;
@property(nonatomic, retain) TKOView *view;
@property(nonatomic, retain) TKOGroupView *groupView;

// Notification list controller
@property(nonatomic, retain) NCNotificationStructuredListViewController *nlc;
@property(nonatomic, retain) NCNotificationDispatcher *dispatcher;
@property(nonatomic) BOOL isTkoCall;

+ (TKOController *) sharedInstance;
- (void) insertNotificationToNlc:(NCNotificationRequest *)req;
- (void) insertAllNotificationsWithBundleID:(NSString *)bundleID;

- (void) removeNotificationFromNlc:(NCNotificationRequest *)req;
- (void) hideAllNotificationsWithBundleID:(NSString *)bundleID;
- (void) removeAllNotificationsWithBundleID:(NSString *)bundleID;
- (void) removeAllNotifications;
- (void) hideAllNotifications;

// NLC
- (void) insertNotificationRequest:(NCNotificationRequest *)req;
- (void) modifyNotificationRequest:(NCNotificationRequest* )req;
- (void) removeNotificationRequest:(NCNotificationRequest *)req;
@end
