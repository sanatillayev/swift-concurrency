//
//  MVVMBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI

final class MyManager {
    func getData() async throws -> String {
        "some data"
    }
}

actor MyActorManager {
    func getData() async throws -> String {
        "some data"
    }
}
@MainActor // whole viewModel is in main actor so it solves all problem while upd. UI
final class MVVMBootcampViewModel: ObservableObject {
    let manager = MyManager()
    let managerActor = MyActorManager()
    
    /*@MainActor*/@Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach { $0.cancel()}
        tasks = []
    }
    
//    @MainActor // everything inside the function is in main actor
    func onCallActionButtonPressed() {
        let task = Task { // @MainActor in /// only this task is in mainActor
            do {
//                myData = try await manager.getData()
                myData = try await managerActor.getData()
/// here we switched to mainActor before but now it automatically going to another actor and coming back to main actor
                /// we dont need to switch to main actor like before
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootcamp: View {
    @StateObject var viewModel = MVVMBootcampViewModel()
    
    
    var body: some View {
        Button("Click me") {
            viewModel.onCallActionButtonPressed()
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

struct MVVMBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        MVVMBootcamp()
    }
}
