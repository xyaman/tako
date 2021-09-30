#import <UIKit/UIKit.h>
#import "../Controller/TKOController.h"

@interface CSNotificationAdjunctListViewController : UIViewController
@property(nonatomic, retain) UIStackView *stackView;
@property(nonatomic, retain) TKOView *tkoView;
@property(nonatomic, retain) TKOGroupView *tkoGroupView;

-(void)_insertItem:(id)arg0 animated:(BOOL)arg1;
-(void)_removeItem:(id)arg0 animated:(BOOL)arg1;
@end
