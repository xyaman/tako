@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *sectionID;
@end

@interface NCNotificationRequest : NSObject
@property (readonly, copy, nonatomic) NSString *notificationIdentifier;
@property(nonatomic,readonly) BBBulletin *bulletin; 
@end

@interface NCNotificationStructuredListViewController : UIViewController
-(void)insertNotificationRequest:(NCNotificationRequest *)arg1;
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