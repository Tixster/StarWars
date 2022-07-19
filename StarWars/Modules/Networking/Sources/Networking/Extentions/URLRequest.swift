//
//  URLRequest.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

extension URLRequest {
    func debug() {
        print("========START REQUEST========")
        print("URL:", self.url ?? "-")
        print("METHOD:", self.httpMethod ?? "-")
        print("HEADER:", self.allHTTPHeaderFields ?? "-")
        print("BODY:", String(data: self.httpBody ?? Data(), encoding: .utf8) ?? "-")
        print("========END REQUEST========")
    }
}
