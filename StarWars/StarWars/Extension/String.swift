//
//  String.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import Foundation

extension String {
    func matches(for regex: Self) -> [Self] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
