#import <UIKit/UIKit.h>

// Tweak headers
typedef NS_ENUM(NSInteger, DisplayBy) {
    DisplayByItWasBefore,
    DisplayByLastAppNotification,
    DisplayByAllClosed
};

typedef NS_ENUM(NSInteger, SortBy) {
    SortByLastestNotification,
    SortByBundleName,
    SortByNotificationCount
};

typedef NS_ENUM(NSInteger, CellStyle) {
    CellStyleDefault,
    CellStyleAxonGrouped,
    CellStyleFullIcon,
    CellStyleFullIconWOBottomBar
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
-(BOOL) isInScreenOffMode;
@end

@interface CSPageViewController : UIViewController
@end

@interface SBBacklightController : NSObject
-(void)setBacklightFactorPending:(float)value;
- (void)turnOnScreenFullyWithBacklightSource:(long long)arg1;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *sectionID;
@property(nonatomic, copy)NSString* recordID;
@property(nonatomic, copy)NSString* publisherBulletinID;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, retain)NSDate* date;
@property(assign, nonatomic)BOOL clearable;
@property(nonatomic)BOOL showsMessagePreview;
@property(nonatomic, copy)BBAction* defaultAction;
@property(nonatomic, copy)NSString* bulletinID;
@property(nonatomic, retain)NSDate* lastInterruptDate;
@property(nonatomic, retain)NSDate* publicationDate;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(BBBulletin *)arg1 destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface SpringBoard : UIApplication
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end

@interface NCNotificationRequest : NSObject
@property (readonly, copy, nonatomic) NSString *notificationIdentifier;
@property(nonatomic,readonly) BBBulletin *bulletin; 
@property (readonly, nonatomic) NSDate *timestamp;
@end

@interface NCNotificationMasterList : NSObject
@property (nonatomic,readonly) unsigned long long notificationCount; 
@property (retain, nonatomic) NSMutableArray *notificationSections;
@end

@interface NCNotificationStructuredSectionList
@property (readonly, nonatomic) NSArray *allNotificationRequests;
@end

@interface NCNotificationListView : NSObject
@property (nonatomic) BOOL revealed;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property(nonatomic, retain) NCNotificationMasterList *masterList;

-(void)insertNotificationRequest:(NCNotificationRequest *)arg1;
-(void)modifyNotificationRequest:(NCNotificationRequest* )arg1;
-(void)removeNotificationRequest:(NCNotificationRequest *)arg1;

-(void)revealNotificationHistory:(BOOL)arg0 animated:(BOOL)arg1 ;
-(void)_resetCellWithRevealedActions;

- (NSArray *) allRequests;
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

@interface SBLockScreenManager : NSObject
+ (id) sharedInstance;
- (BOOL) isUILocked;
- (void) lockUIFromSource:(int)arg1 withOptions:(id)arg2;
@end