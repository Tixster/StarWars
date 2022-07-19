//
//  Validator.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public struct ValidatorErrorResponse: Decodable {
    public let detail: [ValidatorDetail]
}

public struct ValidatorDetail: Decodable {
    public init(loc: [String], msg: String, type: String) {
        self.loc = loc
        self.msg = msg
        self.type = type
    }
    public let loc: [String]
    public let msg, type: String
}
