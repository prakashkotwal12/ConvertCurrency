//
//  BaseModel.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 12/02/2024.
//

struct APIErrorModel: Decodable, Error {
	var info: String
	var code: Int
}


struct APIResponseModel<T: Decodable>: Decodable {
	var success: Bool
	var error: APIErrorModel?
	var data: T?
	
	enum CodingKeys: String, CodingKey {
		case success
		case error
		case data
	}
}

