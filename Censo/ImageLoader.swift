//
//  ImageLoader.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import Foundation
import SwiftUI

struct ImageLoader: Loadable {
    enum ImageError: Error {
        case badData
    }

    var url: URL

    func load(_ completion: @escaping (Result<Image, Error>) -> ()) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let uiImage = UIImage(data: data) {
                completion(.success(Image(uiImage: uiImage)))
            } else {
                completion(.failure(error ?? ImageError.badData))
            }
        }.resume()
    }
}
