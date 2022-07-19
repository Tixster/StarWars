//
//  Int.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

extension Int {
    var localStatusCode: String {
        return HTTPURLResponse.localizedString(forStatusCode: self)
    }
}
