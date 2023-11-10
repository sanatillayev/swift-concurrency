//
//  StrongSelfBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI

final class StrongSelfBootcampDataManager {
    
    func getData() async -> String {
        "new title"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data = "Some title"
    let manager = StrongSelfBootcampDataManager()
    
    private var  someTask: Task<Void, Never>? = nil
    private var  myTasks: [Task<Void, Never>] = []

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { $0.cancel() }
        myTasks = []
    }
    
    // this implies strong reference...
    func updateData() {
        Task {
            data = await self.manager.getData()
        }
    }
    
    // this is strong reference...
    func updateData2() {
        Task {
            self.data = await self.manager.getData()
        }
    }
    
    // this is strong reference...
    func updateData3() {
        Task { [self] in
            self.data = await self.manager.getData()
        }
    }
    
    // this is weak reference...
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.manager.getData() {
                self?.data = data
            }
        }
    }
    
    // We dont need to manage strong/weak...
    // We can manage the Task!
    func updateData5() {
        someTask = Task {
            self.data = await self.manager.getData()
        }
    }
    
    func updateData6() {
        let task1 = Task {
            self.data = await self.manager.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.manager.getData()
        }
        myTasks.append(task2)
    }
    
    // we purposely do not cancel task to keep strong reference
    func updateData7() {
        Task {
            self.data = await self.manager.getData()
        }
        Task.detached {
            self.data = await self.manager.getData()
        }
    }
    
    func updateData8() async {
        self.data = await self.manager.getData()
    }
}

struct StrongSelfBootcamp: View {
    @StateObject var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .font(.title)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task { // this task automatically cancelled when ui is closed
                await viewModel.updateData8()
            }
    }
}

struct StrongSelfBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StrongSelfBootcamp()
    }
}
