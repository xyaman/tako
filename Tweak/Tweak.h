#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import "TKOController.h"

/*----------------------
 / Preferences
 -----------------------*/

HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *prefSortBy = nil;
NSNumber *prefDisplayBy = nil;

// Scrolling
BOOL prefUsePaging = NO;

// Cell
NSNumber *prefCellStyle = nil;

/*----------------------
 / Essential Class definitions
 -----------------------*/
@interface CSNotificationAdjunctListViewController : UIViewController
@property(nonatomic, retain) UIStackView *stackView;
@property(nonatomic, retain) TKOView *tkoView;


-(void)_insertItem:(id)arg0 animated:(BOOL)arg1 ;
-(void)_removeItem:(id)arg0 animated:(BOOL)arg1 ;
@end