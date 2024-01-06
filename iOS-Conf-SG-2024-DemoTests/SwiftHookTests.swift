//
//  SwiftHookTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 25/12/23.
//

import XCTest
import SwiftHook

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
        
        class Math {
            @objc dynamic func double(_ number: Int) -> Int {
                let result = number * 2
                print("Executing `double` with \(number), result is \(result)")
                return result
            }
        }
        
        let math = Math()
        
        try hookInstead(object: math, selector: #selector(Math.double(_:)), closure: { original, obj, sel, number in
            print("Before executing `double`")
            let originalResult = original(obj, sel, number)
            print("After executing `double`, got result \(originalResult)")
            print("Triple the number!")
            return number * 3
        } as @convention(block) (
            (AnyObject, Selector, Int) -> Int,  // original method block
            AnyObject, // `math` Instance
            Selector, // `sum` Selector
            Int // number
        ) -> Int // return value
        )
        
        let number = 3
        let result = math.double(number)
        print("Double \(number), got \(result)")
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
