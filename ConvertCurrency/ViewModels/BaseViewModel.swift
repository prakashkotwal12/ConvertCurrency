//
//  BaseViewModel.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

class BaseViewModel {
	func handleDataFetchError(_ error: DataFetchError) {
		switch error {
			case .localDataFetchError:
				print("Error fetching data from local database.")
			case .apiDataFetchError(let apiError):
				handleAPIError(apiError: apiError)
		}
	}
	
	func handleError(error: Error) {
		print("Generic Error: \(error.localizedDescription)")
	}
	
	func handleAPIError(apiError: APIError) {
		// Handle API-specific errors here
		switch apiError {
			case .notFound:
				print("API Error 404: The requested resource does not exist.")
			case .invalidAPIKey:
				print("API Error 101: No API Key was specified or an invalid API Key was specified.")
			case .inActive:
				print("API Error 102: The account this API request is coming from is inactive.")
			case .invalidEndPoint:
				print("API Error 103: The requested API endpoint does not exist.")
			case .maxReached:
				print("API Error 104: The maximum allowed API amount of monthly API requests has been reached.")
			case .subscriptionFailed:
				print("API Error 105: The current subscription plan does not support this API endpoint.")
			case .noResult:
				print("API Error 106: The current request did not return any results.")
			case .inavlidBaseCurrency:
				print("API Error 201: An invalid base currency has been entered.")
			case .inavlidSymbol:
				print("API Error 202: One or more invalid symbols have been specified.")
			case .noDateSpecified:
				print("API Error 301: No date has been specified. [historical]")
			case .invalidDateSpecified:
				print("API Error 302: An invalid date has been specified. [historical, convert]")
			case .invalidAmount:
				print("API Error 403: No or an invalid amount has been specified. [convert]")
			case .noTimeFrame:
				print("API Error 501: No or an invalid timeframe has been specified. [timeseries]")
			case .invalidStartDate:
				print("API Error 502: No or an invalid 'start_date' has been specified. [timeseries, fluctuation]")
			case .invalidEndDate:
				print("API Error 503: No or an invalid 'end_date' has been specified. [timeseries, fluctuation]")
			case .invalidTimeFrame:
				print("API Error 504: An invalid timeframe has been specified. [timeseries, fluctuation]")
			case .longTimeFrame:
				print("API Error 505: The specified timeframe is too long, exceeding 365 days. [timeseries, fluctuation]")
			case .unknown:
				print("API Error: Unknown error.")
		}
	}	
}

