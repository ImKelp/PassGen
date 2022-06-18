//
//  QoutesController.swift
//  PassGen-SwiftUI
//
//  Created by ColdBio on 18/06/2022.
//

import Foundation

class CallQoutesAPI {
    func getAPI(completion: @escaping (QoutesModel) -> ()) {
        guard let url = URL(string: "https://api.quotable.io/random" ) else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, _, _) in

            do {
                let returnedData = try JSONDecoder().decode(QoutesModel.self, from: data!)
                print(returnedData)
                
                DispatchQueue.main.async {
                    completion(returnedData)
                }
            } catch {
                print(String(describing: error))
            }
        }
            .resume()
    }
}
