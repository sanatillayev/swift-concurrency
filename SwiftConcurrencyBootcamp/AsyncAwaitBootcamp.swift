//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 17/10/23.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
     
    
    // MARK: when you changing the data in ui you must do it in main thread!!!
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("title1 \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title 2 \(Thread.current)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dataArray.append(title)
                
                let title3 = "Title 3 \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author = "Author1 : \(Thread.current)"
        await MainActor.run{
            self.dataArray.append(author)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)

            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
    
    func addSomething() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something = "Something1 \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(something)
            
            let something2 = "Something2 \(Thread.current)"
            self.dataArray.append(something2)
        })
    }
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject var viewModel = AsyncAwaitBootcampViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()
            }
            
//            viewModel.addTitle1()
//            viewModel.addTitle2()

        }
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
