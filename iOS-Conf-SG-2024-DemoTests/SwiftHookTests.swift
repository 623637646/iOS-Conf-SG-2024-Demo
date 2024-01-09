//
//  SwiftHookTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 25/12/23.
//

import XCTest
import EasySwiftHook

final class SwiftHookTests: XCTestCase {
    
    // Call a hook closure before executing specified instance’s method.
    func testHookBeforeForSpecifiedInstance() throws {
        
        class TestObject { // No need to inherit from NSObject.
            // Use `@objc` to make this method accessible from Objective-C
            // Using `dynamic` tells Swift to always refer to Objective-C dynamic dispatch
            @objc dynamic func testMethod() {
                print("Executing `testMethod`")
            }
        }
        
        let obj = TestObject()
        
        let token = try hookBefore(object: obj, selector: #selector(TestObject.testMethod)) {
            print("Before executing `testMethod`")
        }
        
        obj.testMethod()
        token.cancelHook() // cancel the hook
    }
    
    // Call a hook closure after executing specified instance's method and get the parameters.
    func testHookAfterForSpecifiedInstance() throws {
        
        class TestObject {
            @objc dynamic func testMethod(_ parameter: String) {
                print("Executing `testMethod` with parameter: \(parameter)")
            }
        }
        
        let obj = TestObject()
        
        let token = try hookAfter(object: obj, selector: #selector(TestObject.testMethod(_:)), closure: { obj, sel, parameter in
            print("After executing `testMethod` with parameter: \(parameter)")
        } as @convention(block) ( // Using `@convention(block)` to declares a Swift closure as an Objective-C block
            AnyObject, // `obj` Instance
            Selector, // `testMethod` Selector
            String // first parameter
        ) -> Void // return value
        )
        
        obj.testMethod("ABC")
        token.cancelHook() // cancel the hook
    }
    
    // Totally override a mehtod for specified instance.
    func testHookInsteadForSpecifiedInstance() throws {
        
        class TestObject {
            @objc dynamic func testMethod() -> String {
                return "ABC"
            }
        }
        
        let obj = TestObject()
        
        try hookInstead(object: obj, selector: #selector(TestObject.testMethod), closure: { original, obj, sel in
            let originalResult = original(obj, sel)
            print("Original result is \(originalResult)")
            return "123"
        } as @convention(block) (
            (AnyObject, Selector) -> String,  // original method block
            AnyObject, // `obj` Instance
            Selector // `testMethod` Selector
        ) -> String // return value
        )
        
        let result = obj.testMethod()
        print("Hooked result is \(result)")
    }
    
    // Call a hook closure before executing a method for all instances of a class.
    func testHookBeforeForAllInstancesOfClass() throws {
        
        class TestObject {
            @objc dynamic func testMethod() {
                print("Executing `testMethod`")
            }
        }
        
        let token = try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.testMethod)) {
            print("Before executing `testMethod`")
        }
        
        let obj = TestObject()
        obj.testMethod()
        token.cancelHook() // cancel the hook
    }
    
    // Call a hook closure before executing a class method.
    func testHookBeforeForClassMethod() throws {
        
        class TestObject {
            @objc dynamic class func testClassMethod() {
                print("Executing `testClassMethod`")
            }
            @objc dynamic static func testStaticMethod() {
                print("Executing `testStaticMethod`")
            }
        }
        
        try hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.testClassMethod)) {
            print("Before executing `testClassMethod`")
        }
        TestObject.testClassMethod()
        
        try hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.testStaticMethod)) {
            print("Before executing `testStaticMethod`")
        }
        TestObject.testStaticMethod()
    }
}
