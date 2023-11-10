//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Bilol Sanatillayev on 17/10/23.
//

import SwiftUI
import Foundation

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ( "New Text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New TEXT!!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "New Text!"
//        }else {
            throw URLError(.badServerResponse )
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text!"
        }else {
            throw URLError(.badServerResponse )
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    @Published var text: String = "Starting text"
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle() {
        
//        let returnedVaue = manager.getTitle()
//        if let newTitle = returnedVaue.title {
//            self.text = newTitle
//        }else if let error = returnedVaue.error{
//            self.text = error.localizedDescription
//        }
        
//        let result = manager.getTitle2()
//
//        switch result {
//        case .success(let newText):
//            self.text = newText
//        case .failure(let error):
//            self.text = error.localizedDescription
//         }
        
        do {
            
            // if try? is OPTIONAL then finalText will RUN even newTitle -> error
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
/// let _ = try manager.getTitle3()      if try fails in newTitle the finalText will NOT RUN, -> error
            
            let finalText = try manager.getTitle4()
            self.text = finalText
            
        } catch let error {
            self.text = error.localizedDescription
        }
        
        
    }
}

struct DoCatchTryThrowsBootcamp: View {
    @StateObject var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Text(viewModel.text)
                .frame(width: 300, height: 300)
                .background(Color.blue)
                .onTapGesture {
                    viewModel.fetchTitle()
                }
            
            ScrollView {
                
                VStack {
                    Spacer()
                    ForEach(1..<10) { _ in
//                        Shape()
                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .background(Material.ultraThinMaterial)
                            .opacity(0.5)
                    }
                    Spacer()
                }
                
            }

            
        }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
