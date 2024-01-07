//
//  LibffiTests.swift
//  iOS-Conf-SG-2024-DemoTests
//
//  Created by Wang Ya on 25/12/23.
//

import XCTest
import libffi_apple

final class LibffiTests: XCTestCase {
    
    static let targetFuntion = {
        print("Target function is called")
    } as @convention(c) () -> Void  // Using `@convention(c)` to declare a C function
    
    func testFFICall() {
        
        var cif: ffi_cif = ffi_cif() // "description" of target function
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            // Prepare the "description" of target function.
            guard (ffi_prep_cif(
                cifPointer,
                FFI_DEFAULT_ABI,
                UInt32(0), // Number of parameters
                UnsafeMutablePointer(&ffi_type_void), // Return type
                nil // Description of all parameters
            )) == FFI_OK else {
                assertionFailure()
                return
            }
            ffi_call(
                cifPointer, // "description" of the target function
                LibffiTests.targetFuntion, // Pointer to the target function
                nil, // Pointer to the return value
                nil) // Pointers to the arguments.
        }
    }
    
    static let bindingFunction = { cif, ret, arges, userdata in
        // cif: "description" of target function
        // ret: the return value pointer
        // arges: the arguments pointers
        // userdata: custom data
        ffi_call(cif, LibffiTests.targetFuntion, ret, arges)
    } as @convention(c) (_ cif: UnsafeMutablePointer<ffi_cif>?, _ ret: UnsafeMutableRawPointer?, _ args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, _ userdata: UnsafeMutableRawPointer?) -> Void
   
    func testFFIClosure() {

        var cif: ffi_cif = ffi_cif()  // "description" of target function
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            guard (ffi_prep_cif( // Prepare the "description" of target function
                cifPointer,
                FFI_DEFAULT_ABI,
                UInt32(0),
                UnsafeMutablePointer(&ffi_type_void),
                nil)) == FFI_OK else {
                assertionFailure()
                return
            }
            
            var boundTargetFunctionPointer: UnsafeMutableRawPointer? // Pointer to a trampoline function (the entry of the created closure)
            let closureContext = withUnsafeMutablePointer(to: &boundTargetFunctionPointer) { boundTargetFunctionPointerPointer in
                // Allocate the closureContext in heap.
                ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, boundTargetFunctionPointerPointer).assumingMemoryBound(to: ffi_closure.self)
            }
            guard let boundTargetFunctionPointer else {
                assertionFailure()
                return
            }
            // Prepare the closure
            guard (ffi_prep_closure_loc(
                closureContext, // Closure context
                cifPointer, // "description" of target function
                LibffiTests.bindingFunction, // binding function
                nil, // Custome data
                boundTargetFunctionPointer) // Trampoline function
            ) == FFI_OK else {
                assertionFailure()
                return
            }
            let closure: @convention(c) () -> Void = unsafeBitCast(boundTargetFunctionPointer, to: (@convention(c) () -> Void).self)
            closure() // Call the closure (trampoline function)
            ffi_closure_free(closureContext); // free the closure
        }
    }
    
}
