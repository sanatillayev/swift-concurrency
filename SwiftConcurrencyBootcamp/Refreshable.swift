//
//  Refreshable.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 02/11/23.
//

import SwiftUI

final class RefreshableDatamanager {
    
    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return ["Apple", "Orange", "Banana"].shuffled()
    }
}

@MainActor final class RefreshableViewModel:ObservableObject {
    @Published private(set) var items: [String] = []
    let manager = RefreshableDatamanager()
    
    func loadData() async {
        do {
            items = try await manager.getData()
        } catch {
            print(error)
        }
    }
}

struct Refreshable: View {
    
    @StateObject var viewModel = RefreshableViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items,id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Refreshables")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}

struct Refreshable_Previews: PreviewProvider {
    static var previews: some View {
        Refreshable()
    }
}
