//
//  ExchangeResponseModel.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

struct ExchangeResponseModel: Decodable {
	var timestamp: Double
	var base: String
	var date: String
	var rates: [String: Double]
}
