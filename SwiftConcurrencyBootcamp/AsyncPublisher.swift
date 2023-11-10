//
//  AsyncPublisher.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI
import Combine

class AsyncPublisherDatamanager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Limon")
    }
}

class AsyncPublisherViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDatamanager()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscriber()
    }
    
    func addSubscriber() {
        Task {
//            await MainActor.run(body: {
//                self.dataArray.append("two")
//            })
            
            for await value in manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
            
               // this code will never execute coz previous await will wait forever
               // to avoid this kind of issues make separate task for each awaits
//            await MainActor.run(body: {
//                self.dataArray.append("five")
//            })
        }
        
        
        /// this is combine method but now we will learn asyncPublisher above
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellable)
    }
    
    func start() async {
        await manager.addData()
    }
    
    
}

struct AsyncPublisher: View {
    
    @StateObject private var viewModel = AsyncPublisherViewModel()
    
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
            await viewModel.start()
        }
    }
}

struct AsyncPublisher_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisher()
    }
}
