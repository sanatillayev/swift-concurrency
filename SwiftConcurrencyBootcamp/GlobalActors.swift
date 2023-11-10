//
//  GlobalActors.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI

// struct or final class
@globalActor final class MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "four", "five"]
    }
}


/// if have bunch of variable which must be in main actor we can declare class as main actor

//@MainActor
class GlobalActorsViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    // key point when we use global actor we must not directly get MyNewDataManager
    // we must do it with  MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor func getData() {
        
         // if Heavy method then we may use global actor
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
                // when we updating UI we must to do it in main thread
            })
        }
    }
}

struct GlobalActors: View {
    @StateObject var viewModel = GlobalActorsViewModel()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActors_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActors()
    }
}
