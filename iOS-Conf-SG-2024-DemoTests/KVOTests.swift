//
//  KVOTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 4/1/24.
//

import XCTest

final class KVOTests: XCTestCase {

    func testExample() throws {
        class Person: NSObject {
            @objc dynamic var age: Int = 0
        }
        
        let person = Person()
        print("The original class is: \(NSStringFromClass(object_getClass(person)!))")
        let token = person.observe(\.age, options: .new) { p, change in
            print("newValue: \(change.newValue!)")
        }
        person.age = 8
        print("The class after KVO is: \(NSStringFromClass(object_getClass(person)!))")
        _ = token
    }
}
