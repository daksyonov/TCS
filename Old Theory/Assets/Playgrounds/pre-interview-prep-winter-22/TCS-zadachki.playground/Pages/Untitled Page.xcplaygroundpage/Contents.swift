import Foundation

// MARK: - Swift

class DynamicClass {

	@objc func method() {}
	@objc dynamic func dynamicMethod() {}
}

// MARK: - SIL

/*

sil_stage raw

import Builtin
import Swift
import SwiftShims

import Foundation

class DynamicClass {
	@objc func method()
	@objc dynamic func dynamicMethod()
	@objc deinit
	init()
}

// main
sil [ossa] @main : $@convention(c) (Int32, UnsafeMutablePointer<Optional<UnsafeMutablePointer<Int8>>>) -> Int32 {
	bb0(%0 : $Int32, %1 : $UnsafeMutablePointer<Optional<UnsafeMutablePointer<Int8>>>):
	%2 = integer_literal $Builtin.Int32, 0          // user: %3
	%3 = struct $Int32 (%2 : $Builtin.Int32)        // user: %4
	return %3 : $Int32                              // id: %4
} // end sil function 'main'

// DynamicClass.method()
sil hidden [ossa] @$s12dynamicClass07DynamicB0C6methodyyF : $@convention(method) (@guaranteed DynamicClass) -> () {
	// %0 "self"                                      // user: %1
	bb0(%0 : @guaranteed $DynamicClass):
	debug_value %0 : $DynamicClass, let, name "self", argno 1 // id: %1
	%2 = tuple ()                                   // user: %3
	return %2 : $()                                 // id: %3
} // end sil function '$s12dynamicClass07DynamicB0C6methodyyF'

// @objc DynamicClass.method()
sil hidden [thunk] [ossa] @$s12dynamicClass07DynamicB0C6methodyyFTo : $@convention(objc_method) (DynamicClass) -> () {
	// %0                                             // user: %1
	bb0(%0 : @unowned $DynamicClass):
	%1 = copy_value %0 : $DynamicClass              // users: %6, %2
	%2 = begin_borrow %1 : $DynamicClass            // users: %5, %4
	// function_ref DynamicClass.method()
	%3 = function_ref @$s12dynamicClass07DynamicB0C6methodyyF : $@convention(method) (@guaranteed DynamicClass) -> () // user: %4
	%4 = apply %3(%2) : $@convention(method) (@guaranteed DynamicClass) -> () // user: %7
	end_borrow %2 : $DynamicClass                   // id: %5
	destroy_value %1 : $DynamicClass                // id: %6
	return %4 : $()                                 // id: %7
} // end sil function '$s12dynamicClass07DynamicB0C6methodyyFTo'

// DynamicClass.dynamicMethod()
sil hidden [ossa] @$s12dynamicClass07DynamicB0C0A6MethodyyF : $@convention(method) (@guaranteed DynamicClass) -> () {
	// %0 "self"                                      // user: %1
	bb0(%0 : @guaranteed $DynamicClass):
	debug_value %0 : $DynamicClass, let, name "self", argno 1 // id: %1
	%2 = tuple ()                                   // user: %3
	return %2 : $()                                 // id: %3
} // end sil function '$s12dynamicClass07DynamicB0C0A6MethodyyF'

// @objc DynamicClass.dynamicMethod()
sil hidden [thunk] [ossa] @$s12dynamicClass07DynamicB0C0A6MethodyyFTo : $@convention(objc_method) (DynamicClass) -> () {
	// %0                                             // user: %1
	bb0(%0 : @unowned $DynamicClass):
	%1 = copy_value %0 : $DynamicClass              // users: %6, %2
	%2 = begin_borrow %1 : $DynamicClass            // users: %5, %4
	// function_ref DynamicClass.dynamicMethod()
	%3 = function_ref @$s12dynamicClass07DynamicB0C0A6MethodyyF : $@convention(method) (@guaranteed DynamicClass) -> () // user: %4
	%4 = apply %3(%2) : $@convention(method) (@guaranteed DynamicClass) -> () // user: %7
	end_borrow %2 : $DynamicClass                   // id: %5
	destroy_value %1 : $DynamicClass                // id: %6
	return %4 : $()                                 // id: %7
} // end sil function '$s12dynamicClass07DynamicB0C0A6MethodyyFTo'

// DynamicClass.deinit
sil hidden [ossa] @$s12dynamicClass07DynamicB0Cfd : $@convention(method) (@guaranteed DynamicClass) -> @owned Builtin.NativeObject {
	// %0 "self"                                      // users: %2, %1
	bb0(%0 : @guaranteed $DynamicClass):
	debug_value %0 : $DynamicClass, let, name "self", argno 1 // id: %1
	%2 = unchecked_ref_cast %0 : $DynamicClass to $Builtin.NativeObject // user: %3
	%3 = unchecked_ownership_conversion %2 : $Builtin.NativeObject, @guaranteed to @owned // user: %4
	return %3 : $Builtin.NativeObject               // id: %4
} // end sil function '$s12dynamicClass07DynamicB0Cfd'

// DynamicClass.__deallocating_deinit
sil hidden [ossa] @$s12dynamicClass07DynamicB0CfD : $@convention(method) (@owned DynamicClass) -> () {
	// %0 "self"                                      // users: %6, %3, %1
	bb0(%0 : @owned $DynamicClass):
	debug_value %0 : $DynamicClass, let, name "self", argno 1 // id: %1
	// function_ref DynamicClass.deinit
	%2 = function_ref @$s12dynamicClass07DynamicB0Cfd : $@convention(method) (@guaranteed DynamicClass) -> @owned Builtin.NativeObject // user: %4
	%3 = begin_borrow %0 : $DynamicClass            // users: %5, %4
	%4 = apply %2(%3) : $@convention(method) (@guaranteed DynamicClass) -> @owned Builtin.NativeObject // user: %7
	end_borrow %3 : $DynamicClass                   // id: %5
	end_lifetime %0 : $DynamicClass                 // id: %6
	%7 = unchecked_ref_cast %4 : $Builtin.NativeObject to $DynamicClass // user: %8
	dealloc_ref %7 : $DynamicClass                  // id: %8
	%9 = tuple ()                                   // user: %10
	return %9 : $()                                 // id: %10
} // end sil function '$s12dynamicClass07DynamicB0CfD'

// DynamicClass.__allocating_init()
sil hidden [exact_self_class] [ossa] @$s12dynamicClass07DynamicB0CACycfC : $@convention(method) (@thick DynamicClass.Type) -> @owned DynamicClass {
	// %0 "$metatype"
	bb0(%0 : $@thick DynamicClass.Type):
	%1 = alloc_ref $DynamicClass                    // user: %3
	// function_ref DynamicClass.init()
	%2 = function_ref @$s12dynamicClass07DynamicB0CACycfc : $@convention(method) (@owned DynamicClass) -> @owned DynamicClass // user: %3
	%3 = apply %2(%1) : $@convention(method) (@owned DynamicClass) -> @owned DynamicClass // user: %4
	return %3 : $DynamicClass                       // id: %4
} // end sil function '$s12dynamicClass07DynamicB0CACycfC'

// DynamicClass.init()
sil hidden [ossa] @$s12dynamicClass07DynamicB0CACycfc : $@convention(method) (@owned DynamicClass) -> @owned DynamicClass {
	// %0 "self"                                      // users: %2, %1
	bb0(%0 : @owned $DynamicClass):
	debug_value %0 : $DynamicClass, let, name "self", argno 1 // id: %1
	%2 = mark_uninitialized [rootself] %0 : $DynamicClass // users: %4, %3
	%3 = copy_value %2 : $DynamicClass              // user: %5
	destroy_value %2 : $DynamicClass                // id: %4
	return %3 : $DynamicClass                       // id: %5
} // end sil function '$s12dynamicClass07DynamicB0CACycfc'

sil_vtable DynamicClass {
	#DynamicClass.method: (DynamicClass) -> () -> () : @$s12dynamicClass07DynamicB0C6methodyyF	// DynamicClass.method()
	#DynamicClass.init!allocator: (DynamicClass.Type) -> () -> DynamicClass : @$s12dynamicClass07DynamicB0CACycfC	// DynamicClass.__allocating_init()
	#DynamicClass.deinit!deallocator: @$s12dynamicClass07DynamicB0CfD	// DynamicClass.__deallocating_deinit
}



// Mappings from '#fileID' to '#filePath':
//   'dynamicClass/dynamicClass.swift' => 'dynamicClass.swift'

*/
