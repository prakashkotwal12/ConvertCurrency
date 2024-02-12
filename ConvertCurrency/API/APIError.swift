//
//  APIError.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

//Error Code	Description
//404	The requested resource does not exist.
//101	No API Key was specified or an invalid API Key was specified.
//103	The requested API endpoint does not exist.
//104	The maximum allowed API amount of monthly API requests has been reached.
//105	The current subscription plan does not support this API endpoint.
//106	The current request did not return any results.
//102	The account this API request is coming from is inactive.
//201	An invalid base currency has been entered.
//202	One or more invalid symbols have been specified.
//301	No date has been specified. [historical]
//302	An invalid date has been specified. [historical, convert]
//403	No or an invalid amount has been specified. [convert]
//501	No or an invalid timeframe has been specified. [timeseries]
//502	No or an invalid "start_date" has been specified. [timeseries, fluctuation]
//503	No or an invalid "end_date" has been specified. [timeseries, fluctuation]
//504	An invalid timeframe has been specified. [timeseries, fluctuation]
//505	The specified timeframe is too long, exceeding 365 days. [timeseries, fluctuation]

// MARK: - Error Types
enum APIError: Int, Error {
	case notFound = 404
	case invalidAPIKey = 101
	case inActive = 102
	case invalidEndPoint = 103
	case maxReached = 104
	case subscriptionFailed = 105
	case noResult = 106
	case inavlidBaseCurrency = 201
	case inavlidSymbol = 202
	case noDateSpecified = 301
	case invalidDateSpecified = 302
	case invalidAmount = 403
	case noTimeFrame = 501
	case invalidStartDate = 502
	case invalidEndDate = 503
	case invalidTimeFrame = 504
	case longTimeFrame = 505
	case unknown
}
