//
//  iOS_Conf_SG_2024_DemoTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 22/12/23.
//

import XCTest
import SwiftHook
@testable import iOS_Conf_SG_2024_Demo

final class iOS_Conf_SG_2024_DemoTests: XCTestCase {
    
    func testHookBeforeAfter() throws {
        
        class Developer {
            @objc dynamic func coding(featureName: String) { // The key words of methods `@objc` and `dynamic` are necessary.
                print("codding for feature \"\(featureName)\"")
            }
        }
        
        let dev = Developer()
        
        try hookBefore(object: dev, selector: #selector(Developer.coding)) {
            print("open Xcode.")
        }
        try hookAfter(object: dev, selector: #selector(Developer.coding), closure: { obj, sel, featureName in
            print("git commit -m \"\(featureName)\"")
            print("close Xcode.")
        } as @convention(block) (AnyObject, Selector, String) -> Void)
        
        dev.coding(featureName: "Use of ImpressionKit")
        
    }
    
    func testHookInstead() throws {
        class Computer {
            @objc dynamic func sum(leftNumber: Int, rightNumber: Int) -> Int {
                print("calculating")
                return leftNumber + rightNumber
            }
        }
        
        let computer = Computer()
        
        try hookInstead(object: computer, selector: #selector(Computer.sum(leftNumber:rightNumber:)), closure: { original, obj, sel, leftNumber, rightNumber in
            print("before calculating, leftNumber = \(leftNumber), rightNumber = \(rightNumber)")
            let originalResult = original(obj, sel, leftNumber, rightNumber)
            print("after calculating, got result = \(originalResult)")
            print("hook and return 99")
            return 99
        } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int)
        
        let leftNumber = 3
        let rightNumber = 4
        let result = computer.sum(leftNumber: leftNumber, rightNumber: rightNumber)
        print("\(leftNumber) + \(rightNumber) = \(result)")
    }
    
}
