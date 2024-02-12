//
//  DataFetchError.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

import Foundation

// MARK: - Protocols
protocol DataFetchDelegate: AnyObject {
		func dataFetchStatus(_ success: Bool)
}

// MARK: - Enums
enum DataFetchError: Error {
		case localDataFetchError
		case apiDataFetchError(APIError)
}
