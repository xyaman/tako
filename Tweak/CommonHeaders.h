@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *sectionID;
@end

@interface NCNotificationRequest : NSObject
@property (readonly, copy, nonatomic) NSString *notificationIdentifier;
@property(nonatomic,readonly) BBBulletin *bulletin; 
@end

@interface NCNotificationStructuredListViewController : UIViewController
-(void)revealNotificationHistory:(BOOL)arg0 animated:(BOOL)arg1 ;
-(void)_resetCellWithRevealedActions;

-(void)insertNotificationRequest:(NCNotificationRequest *)arg1;
-(void)modifyNotificationRequest:(NCNotificationRequest* )arg1;
-(void)removeNotificationRequest:(NCNotificationRequest *)arg1;
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
