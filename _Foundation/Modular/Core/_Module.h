#import "_Precompile.h"
#import "_Foundation.h"
#import "_LoadableProtocol.h"

#pragma mark -

@interface _Module : NSObject <_LoadableProtocol>

@prop_strong( NSString *,		name ) // Name is set to be class name, by default.
@prop_strong( NSBundle *,		bundle ) // Bundle 's name is set to be class name, by default.
@prop_assign( BOOL,				running )  // Set if u need, or'll be changed by super class.
@prop_assign( BOOL,				installed ) // Set if u need, or'll be changed by super class.

/**
 *  安装、卸载
 *
 *  建议重载时调用父类方法，调用时机任意，否则需要自行管理installed状态
 */
- (BOOL)autoinstall; // 返回 YES，在Component中，会被自动加载
- (void)install;
- (void)uninstall;

/**
 *  运行时 功能开关
 *
 *  建议重载时调用父类方法，调用时机任意，否则需要自行管理installed状态
 */
- (void)powerOn;
- (void)powerOff;
    
- (NSString *)moduleDescription;

@end
