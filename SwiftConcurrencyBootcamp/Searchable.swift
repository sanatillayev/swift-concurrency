//
//  Searchable.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 09/11/23.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, uzbek, japanese
}

final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger", cuisine: .american),
            Restaurant(id: "2", title: "Osh", cuisine: .uzbek),
            Restaurant(id: "3", title: "Kabob", cuisine: .uzbek),
            Restaurant(id: "4", title: "Sushi", cuisine: .japanese),
            Restaurant(id: "5", title: "Pizza", cuisine: .italian),
            Restaurant(id: "6", title: "Lagmon", cuisine: .uzbek)
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    let manager = RestaurantManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestion: Bool {
        searchText.count < 3
    }
    
    init() {
        addSubscriber()
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    private func addSubscriber() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.03, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // filter on scope
        var restaunrantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaunrantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        // filter on search text
        let search = searchText.lowercased()
        filteredRestaurants = restaunrantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        })
    }
    
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisine = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisine.map({ SearchScopeOption.cuisine(option: $0) })
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestion() -> [String] {
        guard showSearchSuggestion else {
            return []
        }
        
        var suggestion: [String] = []

        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestion.append("Pasta")
        }
        if search.contains("bu") {
            suggestion.append("Burger")
        }
        if search.contains("os") {
            suggestion.append("Osh")
        }
        if search.contains("ka") {
            suggestion.append("Kabob")
        }
        suggestion.append("Market")
//        suggestion.append("Grocery")
        
        suggestion.append(CuisineOption.uzbek.rawValue.capitalized)
        suggestion.append(CuisineOption.italian.rawValue.capitalized)
        
        return suggestion
    }
    
    func getRestaurantSuggestion() -> [Restaurant] {
        guard showSearchSuggestion else {
            return []
        }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("uz") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .uzbek }))
        }
        if search.contains("it") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian }))
        }
        return suggestions
    }
}

struct Searchable: View {
    
    @StateObject var viewModel = SearchableViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink {
                            Text(restaurant.title)
                        } label: {
                            restaurantRow(restaurant: restaurant)
                        }
                    }
                }
                .padding()
                //                Text("ViewModel isSearching \(viewModel.isSearching.description)")
                //                SearchableChildView()
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurants ...")
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                    Text(scope.title)
                        .tag(scope)
                }
            })
            .searchSuggestions({
                ForEach(viewModel.getSearchSuggestion(), id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }
                
                ForEach(viewModel.getRestaurantSuggestion(), id: \.self) { suggestion in
                    NavigationLink {
                        Text(suggestion.title.uppercased())
                    } label: {
                        Text(suggestion.title)
                    }

                }
            })
            .navigationTitle("Restaurants")
            .task {
                await viewModel.loadRestaurants()
            }
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(Color.black)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(Color.black)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.033))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SearchableChildView: View{
    @Environment(\.isSearching) private var isSearching
    /// this isSearching in the environment will be true when the user will tap on search bar
    var body: some View {
        Text("Child View isSearching \(isSearching.description)")
    }
}

#Preview {
    Searchable()
}
