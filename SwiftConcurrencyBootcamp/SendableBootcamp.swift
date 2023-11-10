//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}
// struct are already sendable by conforming it like here
// slight perfonrmance
struct MyUserInfo: Sendable {
    var name: String
}
final class MyClassUserInfo: @unchecked Sendable { // do not use @unchecked
    private var name: String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name // we must do it in specific queue
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    
    func updagteCurrentuserInfo() async {
        
        let info = MyClassUserInfo(name: "name")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await viewModel.updagteCurrentuserInfo()
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
