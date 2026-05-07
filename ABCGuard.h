#import <UIKit/UIKit.h>

@interface ABCGuardManager : NSObject
+ (instancetype)shared;
- (void)showGate;
- (void)dismissGate;
@end
