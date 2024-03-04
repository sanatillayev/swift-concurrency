//
//  ObservableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 04/03/24.
//

import SwiftUI

actor TitleDatabase {
    
    // when we use `@Published` with viewModel `ObservableObject` we can see thread errors
    // but @Observable doesnt show the thread errors
    func getNewTitle() -> String {
        "Some new title"
    }
}

@Observable class ObservableViewModel {
    @ObservationIgnored let database = TitleDatabase()
    @MainActor var title: String = "Starting title!"

    func updateTitle() {
        Task { @MainActor in
            title = await database.getNewTitle()
            print(Thread.current)
        }
    }
}
struct ObservableBootcamp: View {
    
    @State private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .onAppear {
                viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp()
}
