#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import "CommonHeaders.h"
#import "TKOController.h"
#import "TKOView.h"

/*----------------------
 / Preferences
 -----------------------*/
HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *prefSortBy = nil;


/*----------------------
 / Class definitions
 -----------------------*/
@interface CSNotificationAdjunctListViewController : UIViewController
@property(nonatomic, retain) UIStackView *stackView;
@property(nonatomic, retain) TKOView *tkoView;

-(BOOL)isShowingMediaControls;


-(void)_insertItem:(id)arg0 animated:(BOOL)arg1 ;
-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 ;
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

@interface CSAdjunctItemView : UIView
@end