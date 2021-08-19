#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <dlfcn.h>

#import "TKOController.h"

/*----------------------
 / Preferences
 -----------------------*/

HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *prefSortBy = nil;
NSNumber *prefDisplayBy = nil;

// Options
BOOL prefForceCentering = NO;

// Scrolling
BOOL prefUsePaging = NO;

// Cell
NSNumber *prefCellStyle = nil;
NSNumber *prefCellSpacing = nil;

// Grouped
BOOL prefGroupAuthentication = NO;
BOOL prefGroupRoundedIcons = NO;
BOOL prefLSGroupedIsEnabled = NO;
BOOL prefNCGroupedIsEnabled = NO;
BOOL prefGroupWhenMusic = NO;
NSNumber *prefGroupIconsCount = nil;
NSNumber *prefGroupIconSpacing = nil;
NSNumber *prefGroupIconSize = nil;

/*----------------------
 / Essential Class definitions
 -----------------------*/
@interface CSNotificationAdjunctListViewController : UIViewController
@property(nonatomic, retain) UIStackView *stackView;
@property(nonatomic, retain) TKOView *tkoView;
@property(nonatomic, retain) TKOGroupView *tkoGroupView;

-(void)_insertItem:(id)arg0 animated:(BOOL)arg1;
-(void)_removeItem:(id)arg0 animated:(BOOL)arg1;
@end