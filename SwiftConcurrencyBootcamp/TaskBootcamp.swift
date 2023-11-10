//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 17/10/23.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil

    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("Image received")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                self.image2 = UIImage(data: data)
                
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
}

private struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me🚆") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @ObservedObject var viewModel = TaskBootcampViewModel()
//    @State private var  fetchTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear{
//            fetchTask?.cancel()
//        }
//        .onAppear {
//            fetchTask = Task {
//                await viewModel.fetchImage()
//            }
////            Task {
////                print(Thread.current)
////                print(Task.currentPriority)
////                await viewModel.fetchImage2()
////            }
//
////            Task(priority:  .high) {
////   //             try? await Task.sleep(nanoseconds:2_000_000_000) // sleep for 2 sec
////                // if udk how many seconds to wait then use yield
////                await Task.yield()
////                print("high: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority:  .userInitiated) {
////                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority:  .medium) {
////                print("medium: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority:  .low) {
////                print("low: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority:  .utility) {
////                print("utility: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority:  .background) {
////                print("background: \(Thread.current) : \(Task.currentPriority)")
////            }
//
////            Task(priority:  .userInitiated) {
////                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
////            }
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
