#import <UIKit/UIKit.h>

// Tweak headers
typedef NS_ENUM(NSInteger, SortBy) {
    SortByLastestNotification,
    SortByBundleName,
    SortByNotificationCount
};

typedef NS_ENUM(NSInteger, CellStyle) {
    CellStyleDefault,
    CellStyleAxonGrouped,
    CellStyleFullIcon
};
//

@interface UIView (Private)
- (void) _updateSizeToMimic;
@end

// History notifications
@interface NCNotificationListSectionHeaderView : UIView
@end

// Older notifications
@interface NCNotificationListSectionRevealHintView : UIView
@end

@interface NCNotificationListCoalescingHeaderCell : UIView
@end

@interface NCNotificationListCoalescingControlsCell : UIView
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface CSPageViewController : UIViewController
@end

@interface SBBacklightController : NSObject
-(void)setBacklightFactorPending:(float)value;
@end

@interface CSAdjunctItemView : UIView
@end

@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *sectionID;
@end

@interface NCNotificationRequest : NSObject
@property (readonly, copy, nonatomic) NSString *notificationIdentifier;
@property(nonatomic,readonly) BBBulletin *bulletin; 
@end

@interface NCNotificationMasterList : NSObject
@property (nonatomic,readonly) unsigned long long notificationCount; 
-(void)setNotificationHistoryRevealed:(BOOL)arg1 ;
@end

@interface CSCombinedListViewController : UIViewController
-(void)forceNotificationHistoryRevealed:(BOOL)arg1 animated:(BOOL)arg2 ;
-(BOOL) notificationStructuredListViewControllerShouldAllowNotificationHistoryReveal:(id)arg1;
-(void)notificationStructuredListViewControllerDidScrollToRevealNotificationHistory:(id)arg1 ;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (weak, nonatomic) CSCombinedListViewController *delegate;
@property (retain, nonatomic) NCNotificationMasterList *masterList;

-(void)revealNotificationHistory:(BOOL)arg0 animated:(BOOL)arg1 ;
-(void)_resetCellWithRevealedActions;

-(void)insertNotificationRequest:(NCNotificationRequest *)arg1;
-(void)modifyNotificationRequest:(NCNotificationRequest* )arg1;
-(void)removeNotificationRequest:(NCNotificationRequest *)arg1;
-(BOOL)hasVisibleContentToReveal;
-(BOOL)hasVisibleContent;
-(BOOL)notificationMasterListShouldAllowNotificationHistoryReveal:(id)arg1 ;
@end



@interface NCNotificationDispatcher : NSObject
-(void)removeNotificationSectionWithIdentifier:(id)arg0;
-(void)destination:(id)arg0 requestsClearingNotificationRequests:(id)arg1 ;
@end

@interface SBNCNotificationDispatcher : NSObject
@property (nonatomic,retain) NCNotificationDispatcher * dispatcher; 
@end

struct SBIconImageInfo {
   CGFloat width;
   CGFloat height;
   CGFloat field1;
   CGFloat field2;
};

@interface SBIcon : NSObject
-(UIImage *)iconImageWithInfo:(struct SBIconImageInfo)arg0 ;
@end


@interface SBIconModel : NSObject
-(SBIcon *)applicationIconForBundleIdentifier:(id)arg0 ;
@end

@interface SBIconController : UIViewController
+ (SBIconController *) sharedInstance;
@property (retain, nonatomic) SBIconModel *model;
@end

typedef NS_ENUM(NSInteger, MTMaterialRecipe) {
    MTMaterialRecipeNone,
    MTMaterialRecipeNotifications,
    MTMaterialRecipeWidgetHosts,
    MTMaterialRecipeWidgets,
    MTMaterialRecipeControlCenterModules,
    MTMaterialRecipeSwitcherContinuityItem,
    MTMaterialRecipePreviewBackground,
    MTMaterialRecipeNotificationsDark,
    MTMaterialRecipeControlCenterModulesSheer
};

typedef NS_OPTIONS(NSUInteger, MTMaterialOptions) {
    MTMaterialOptionsNone             = 0,
    MTMaterialOptionsGamma            = 1 << 0,
    MTMaterialOptionsBlur             = 1 << 1,
    MTMaterialOptionsZoom             = 1 << 2,
    MTMaterialOptionsLuminanceMap     = 1 << 3,
    MTMaterialOptionsBaseOverlay      = 1 << 4,
    MTMaterialOptionsPrimaryOverlay   = 1 << 5,
    MTMaterialOptionsSecondaryOverlay = 1 << 6,
    MTMaterialOptionsAuxiliaryOverlay = 1 << 7,
    MTMaterialOptionsCaptureOnly      = 1 << 8
};

@interface MTMaterialView : UIView
+(id)materialViewWithRecipe:(long long)arg1 configuration:(unsigned long long)arg2 ;
@end

@interface SBIdleTimerGlobalCoordinator : NSObject
+ (id) sharedInstance;
-(void)resetIdleTimer;
@end