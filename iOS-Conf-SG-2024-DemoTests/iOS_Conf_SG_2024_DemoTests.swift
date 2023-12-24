//
//  iOS_Conf_SG_2024_DemoTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 22/12/23.
//

import XCTest
import EasySwiftHook
import libffi_iOS
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
    
    static let targetFuntion = {
        print("Target function is called")
    } as @convention(c) () -> Void
    
    func testFFICall() {
        
        var cif: ffi_cif = ffi_cif()
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            guard (ffi_prep_cif(
                cifPointer,
                FFI_DEFAULT_ABI,
                UInt32(0),
                UnsafeMutablePointer(&ffi_type_void),
                nil)) == FFI_OK else {
                assertionFailure()
                return
            }
            ffi_call(cifPointer, iOS_Conf_SG_2024_DemoTests.targetFuntion, nil, nil)
        }
    }
    
    static let targetFunctionBinding = { cif, ret, arges, userdata in
        ffi_call(cif, iOS_Conf_SG_2024_DemoTests.targetFuntion, ret, arges)
    } as @convention(c) (_ cif: UnsafeMutablePointer<ffi_cif>?, _ ret: UnsafeMutableRawPointer?, _ args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, _ userdata: UnsafeMutableRawPointer?) -> Void
   
    func testFFIClosure() {

        var cif: ffi_cif = ffi_cif()
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            guard (ffi_prep_cif(
                cifPointer,
                FFI_DEFAULT_ABI,
                UInt32(0),
                UnsafeMutablePointer(&ffi_type_void),
                nil)) == FFI_OK else {
                assertionFailure()
                return
            }
            
            var boundTargetFunctionPointer: UnsafeMutableRawPointer?
            let closurePointer = withUnsafeMutablePointer(to: &boundTargetFunctionPointer) { boundTargetFunctionPointerPointer in
                ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, boundTargetFunctionPointerPointer).assumingMemoryBound(to: ffi_closure.self)
            }
            guard let boundTargetFunctionPointer else {
                assertionFailure()
                return
            }
            guard (ffi_prep_closure_loc(
                closurePointer,
                cifPointer,
                iOS_Conf_SG_2024_DemoTests.targetFunctionBinding,
                nil,
                boundTargetFunctionPointer)) == FFI_OK else {
                assertionFailure()
                return
            }
            let closure: @convention(c) () -> Void = unsafeBitCast(boundTargetFunctionPointer, to: (@convention(c) () -> Void).self)
            closure()
            /* Deallocate both closure, and bound_puts */
            ffi_closure_free(closurePointer);
        }
    }
}
