//
//  CurrencyConverter.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//


struct CurrencyConverter {
	var exchangeRates: [String: Double]
	
	init(responseData: [String: Double]) {
		exchangeRates = responseData
	}
	
	func convertAmount(_ amount: Double, fromCurrency: String, toCurrency: String) -> Double? {
		guard fromCurrency != toCurrency else {
			// If the source and destination currencies are the same, no conversion needed
			return amount
		}
		
		guard let fromRate = exchangeRates[fromCurrency], let toRate = exchangeRates[toCurrency] else {
			// Handle the case when conversion rates are not available
			return nil
		}
		
		return amount * (toRate / fromRate)
	}	
}

