//
//  CheckedContinuation.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 01/11/23.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedContinuation { continuation in
            // this function will pause the task inside of closure
            // and it must resume the task only ONCE , if not app will crash

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error as! Never)
                } else {
//                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
            // end of closure
        }
    }
    
    private func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation({ continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        })
    }
}

class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let worker = CheckedContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300" ) else { return }
        
        do {
            let data = try await worker.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch  {
            print(error)
        }
    }
    
    func getHeartImage() async {
         self.image = await worker.getHeartImageFromDatabase()
    }
}

struct CheckedContinuation: View {
    @StateObject var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
           await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}
