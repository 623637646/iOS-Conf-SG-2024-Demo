//
//  MethodSwizzlingTests.m
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 26/12/23.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;

@interface MyObject : NSObject

- (void)test;

@end

@implementation MyObject

- (void)test
{
    NSLog(@"test method is called, _cmd is %@", NSStringFromSelector(_cmd));
}

@end

@interface MyObject (Swizzling)

- (void)swizzling_test;

@end

@implementation MyObject (Swizzling)

- (void)swizzling_test
{
    NSLog(@"swizzling_test method is called, _cmd is %@", NSStringFromSelector(_cmd));
    [self swizzling_test];
}

@end

@interface MethodSwizzlingTests : XCTestCase

@end

@implementation MethodSwizzlingTests

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL testSelector = @selector(test);
        SEL swizzlingTestSelector = @selector(swizzling_test);
        Method originalMethod = class_getInstanceMethod(MyObject.self, testSelector);
        Method updatedMethod = class_getInstanceMethod(MyObject.self, swizzlingTestSelector);
        method_exchangeImplementations(originalMethod, updatedMethod);
    });
}


- (void)testWrongCMD {
    MyObject *obj = [[MyObject alloc] init];
    [obj test];
}

@end
