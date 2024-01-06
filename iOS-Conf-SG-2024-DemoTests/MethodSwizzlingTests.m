//
//  MethodSwizzlingTests.m
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 26/12/23.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;

@interface MyObject : NSObject
@end

@implementation MyObject
- (void)test
{
    NSLog(@"Executing `test`, _cmd is %@", NSStringFromSelector(_cmd));
}
@end

@implementation MyObject (Swizzling)
- (void)swizzling_test
{
    NSLog(@"Executing `swizzling_test`, _cmd is %@", NSStringFromSelector(_cmd));
    [self swizzling_test];
}
@end

@interface MethodSwizzlingTests : XCTestCase

@end

@implementation MethodSwizzlingTests

- (void)testNormal {
    MyObject *obj = [[MyObject alloc] init];
    [obj test];
}

- (void)testWrongCMD {
    [MethodSwizzlingTests swizzle];
    MyObject *obj = [[MyObject alloc] init];
    [obj test];
}

+ (void)swizzle {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL testSelector = @selector(test);
        SEL swizzlingTestSelector = @selector(swizzling_test);
        Method originalMethod = class_getInstanceMethod(MyObject.self, testSelector);
        Method updatedMethod = class_getInstanceMethod(MyObject.self, swizzlingTestSelector);
        method_exchangeImplementations(originalMethod, updatedMethod);
    });
}

@end


@interface MyObject (AssociatedObjects)
@property (nonatomic, copy) NSString *bad;
@property (nonatomic, copy) NSString *good;
@end

@implementation MyObject (AssociatedObjects)

// MARK: Bad code

- (void)setBad:(NSString *)bad
{
    objc_setAssociatedObject(self, @selector(bad), bad, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)bad
{
    // `_cmd` may be wrong after method swizzling.
    return objc_getAssociatedObject(self, _cmd);
}

// MARK: Good code

static char kAssociatedObjectKey;

- (void)setGood:(NSString *)good
{
    objc_setAssociatedObject(self, &kAssociatedObjectKey, good, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)good
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}

@end
