//
//  APIServices.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

import RxSwift
import RxAlamofire

class APIService {
	
	func makeAPICall() -> Observable<SymbolModel> {
		let parameters = ["access_key": APIConstants.accessKey]
		return RxAlamofire.requestData(.get, APIConstants.symbolsAPIEndpoint, parameters: parameters)
			.map { response, data in
				if 200..<300 ~= response.statusCode {
					let symbolModel = try JSONDecoder().decode(SymbolModel.self, from: data)
					return symbolModel
				} else {
					let apiError = try? JSONDecoder().decode(APIErrorModel.self, from: data)
					let customError = apiError ?? APIError.unknown.toErrorModel()
					throw customError
				}
			}
			.catch { error in
				if let apiError = error as? APIErrorModel {
					throw apiError
				} else {
					let apiError = APIError.unknown.toErrorModel()
					throw apiError
				}
			}
	}
	
	func getExchangeRates() -> Observable<ExchangeResponseModel> {
		let parameters = ["access_key": APIConstants.accessKey]
		return RxAlamofire.requestData(.get, APIConstants.exchangeRatesAPIEndpoint, parameters: parameters)
			.map { response, data in
				if 200..<300 ~= response.statusCode {
					let exchangeResponseModel = try JSONDecoder().decode(ExchangeResponseModel.self, from: data)
					return exchangeResponseModel
				} else {
					let apiError = try? JSONDecoder().decode(APIErrorModel.self, from: data)
					let customError = apiError ?? APIError.unknown.toErrorModel()
					throw customError
				}
			}
			.catch { error in
				if let apiError = error as? APIErrorModel {
					throw apiError
				} else {
					let apiError = APIError.unknown.toErrorModel()
					throw apiError
				}
			}
	}
	
}

extension APIError {
	func toErrorModel() -> APIErrorModel {
		return APIErrorModel(info: self.localizedDescription, code: self.rawValue)
	}
	
}

