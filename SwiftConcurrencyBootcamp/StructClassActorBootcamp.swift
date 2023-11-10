//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 01/11/23.
//

/*
 
 Links:
 https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct/
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99
 
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe (by default)
 - When you assign or pass reference type a new reference to original instance will be created (pointer)
 
 - - - - - - - - - - - - - -
 
 STACK:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack!
 
 HEAP:
 - Stores Reference types
 - Shared across threads!
 
 - - - - - - - - - - - - - -
 
STRUCT:
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack!
 
CLASS:
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap!
 - Inherit from other classes
 
ACTOR:
 - Same as Class, but thread safe!
 
 - - - - - - - - - - - - - -
 
Structs: Data Models, Views
Classes: ViewModels
Actors: Shared 'Manager' and 'Data Stores'

 */


import SwiftUI

class StructClassActorBootcampViewModel: ObservableObject {
    @Published var title: String = ""
    
    init() {
        print("ViewModel init")
    }
}

struct StructClassActorBootcamp: View {
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View init")
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
    }
}

struct StructClassActorBootcampHomeView: View {
    @State var isActive: Bool = false
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp(isActive: false)
    }
}


extension StructClassActorBootcamp {
    
    private func runTest() {
        print("test started")
        structTest1()
        divider()
        classTest1()
        divider()
        actorTest1()
        
//        structTest2()
//        classTest2()
    }
    
    private func divider() {
        print("""
              
        - - - - - - - - - - - - - - - - - -
        
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "starting title")
        print("Object A: ", objectA.title)
        
        print("Pass VALUES of ObjectA to ObjectB")
        var objectB = objectA
        print("Object B: ", objectB.title)
        
        objectB.title = "new title"
        
        print("b is changed")
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)

    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "starting title")
        print("Object A: ", objectA.title)
        
        print("Pass REFERENCE of ObjectA to ObjectB")
        let objectB = objectA
        print("Object B: ", objectB.title)

        objectB.title = "new title"
        
        print("b is changed")
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)
    }
    
    private func actorTest1()  {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "starting title")
            await print("Object A: ", objectA.title)
            
            print("Pass REFERENCE of ObjectA to ObjectB")
            let objectB = objectA
            await print("Object B: ", objectB.title)

//            objectB.title = "new title" // error
            // we cant change property from outside of actor for changing we must create function like below
            await objectB.updateTitle(newTitle: "new title")
            print("b is changed")
            
            await print("Object A: ", objectA.title)
            await print("Object B: ", objectB.title)
        }
    }
}

struct MyStruct {
    var title: String
}

// immutable struct

struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    // setting is(private) only inside the struct,  but we can get anywhere
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    private func structTest2() {
        print("structTest2")
        
        var  struct1 = MyStruct(title: "title1")
        print("struct1:", struct1.title)
        struct1.title = "title2"
        print("struct1:", struct1.title)

        var  struct2 = CustomStruct(title: "title1")
        print("struct2:", struct2.title)
        struct2 = CustomStruct(title: "title2")
        print("struct2:", struct2.title)
        
        var  struct3 = CustomStruct(title: "title1")
        print("struct3:", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "title2")
        print("struct3:", struct3.title)
        
        var  struct4 = MutatingStruct(title: "title1")
        print("struct4:", struct4.title)
        struct4.updateTitle(newTitle: "title2")
        print("struct4:", struct4.title)

    }
}


class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func classTest2() {
        print("classTest2")
        let class1 = MyClass(title: "title1")
        print("class1:", class1.title)
        class1.title = "title2"
        print("class1:", class1.title)

        
        let class2 = MyClass(title: "title1")
        print("class2:", class2.title)
        class2.updateTitle(newTitle: "title2")
        print("class2:", class2.title)
    }
}
