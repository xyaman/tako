#import "../IOSHeaders.h"
#import "objc/runtime.h"
#import <dlfcn.h>

static BBServer* bbServer = nil;

static dispatch_queue_t getBBServerQueue() {

    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak* pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;
}

%hook BBServer
- (id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc {
    if (bbServer == self) bbServer = nil;
    %orig;
}
%end

static void fakeNotification(NSString* sectionID, NSDate* date, NSString* message, bool banner) {
    
    BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];

    bulletin.title = @"Tako";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
        });
    } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:4];
        });
    }

}

void TKOTestNotifications() {

   // This will open Notification Center
   [[objc_getClass("SBCoverSheetPresentationManager") sharedInstance] setCoverSheetPresented:true animated:true withCompletion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.Preferences", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.facetime", [NSDate date], @"Hello, I'm Tako", false);
        fakeNotification(@"com.apple.mobilephone", [NSDate date], @"Hello, I'm Tako", false);
    });
}


// We want to always hook notifications (even if the tweak is not enabled)
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TKOTestNotifications, (CFStringRef)@"com.xyaman.takopreferences/TestNotifications", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
