//
//  AsyncStream.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 29/02/24.
//

import SwiftUI

class AsyncStreamDataManager {
    
    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream(Int.self) { continuation in
            self.getFakeData { value in
                continuation.yield(value)
            } onFinish: { error in
                continuation.finish(throwing: error)
                print("finished")
            }

        }
    }
    
    func getFakeData(
        newValue: @escaping (_ value: Int) -> Void,
        onFinish: @escaping (_ error: Error?) -> Void
    ) {
        let items = [1,2,3,4,5,6,7,8,9,10]
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now()+Double(item), execute: {
                newValue(item)
                
                if item == items.last {
                    onFinish(nil)
                }
            })
        }
    }
}
@MainActor
final class AsyncStreamViewModel: ObservableObject {
    let manager = AsyncStreamDataManager()
    @Published private(set) var currentNumber = 0
    
    func onViewAppear(){
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
        
        Task {
            do {
                for try await value in manager.getAsyncStream() {
                    currentNumber = value
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}
struct AsyncStreamBootcamp: View {
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear { viewModel.onViewAppear() }
    }
}

#Preview {
    AsyncStreamBootcamp()
}
