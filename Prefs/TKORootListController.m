#import "TKORootListController.h"

@implementation TKORootListController

- (instancetype) init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:(214.0/255.0) green:(54.0/255.0) blue:(54.0/255.0) alpha:1.0];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.0];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

     // Add respring at right
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(respring:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:(214.0/255.0) green:(54.0/255.0) blue:(54.0/255.0) alpha:1.0];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)testNotifications:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.xyaman.takopreferences/TestNotifications", nil, nil, true);
}

- (void)respring:(id)sender {
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/shuffle.dylib"]) {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Tweaks&path=Tako"]];
    } else {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Tako"]];   
    }	
}
@end