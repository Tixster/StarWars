//
//  HTTPRequestError.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation
/// Виды ошибок HTTP-запросов
public enum HTTPRequestError: Error {
    /// Ошибка декодирования модели
    case decode
    /// Ошибка проверки URL
    case invalidURL
    /// Ошибка получения ответа от сервера
    case noResponse
    /// Ошибка получения данных
    case request(localizedDiscription: String)
    /// Ошибка окончания текущей сессии
    case unauthorizate
    /// Ошибка для непредвиденных статус кодов
    case unexpectedStatusCode(code: Int, localized: String?)
    /// Ошибка валидации отправленных данных
    case validator(detail: ValidatorDetail)
    /// Ошибка обработки запроса сервером
    case defaultServerError(error: String)
}

extension HTTPRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decode:
            return "Ошибка декдоирования"
        case .invalidURL:
            return "Неверный URL"
        case .noResponse:
            return "Нет ответа"
        case .request(let localizedDiscription):
            return localizedDiscription
        case .unauthorizate:
            return "Сессия окончена"
        case .unexpectedStatusCode(let code, let local):
            return "unexpectedStatusCode: \(code) - " + (local ?? "")
        case .validator(let detail):
            return "Ошибка валидатора: \(detail.msg)\nType: \(detail.type)\nLoc: \(detail.loc[0])"
        case .defaultServerError(error: let error):
            return "Ошибка сервера: " + error
        }
    }
}
