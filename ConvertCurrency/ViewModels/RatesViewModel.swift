//
//  RatesViewModel.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//


import RxSwift
import RxRelay

protocol RatesViewModelDelegate: AnyObject {
	func exchangeRatesFetched(with data: ExchangeResponseModel)
	func dataFetchStatus(_ success: Bool)
}


class RatesViewModel: BaseViewModel {
	
	weak var delegate: RatesViewModelDelegate?
	
	private let apiService: APIService
	private let disposeBag = DisposeBag()
	
	let exchangeRate = PublishSubject<ExchangeResponseModel>()
	let errorSubject = PublishSubject<Error>()
	
	let fromCurrency = BehaviorSubject<String>(value: "EUR")
	let toCurrency = BehaviorSubject<String>(value: "USD")
	
	init(apiService: APIService) {
		self.apiService = apiService
		super.init()
		setupBindings()
	}
	
	private func setupBindings() {
		getExchangeRates()
	}
	
	// Function to save symbols in the local database
	private func saveRatesLocally(_ data: ExchangeResponseModel) {
		if let binaryData = CoreDataManager.shared.convertToBinaryData(dictionary: data.rates) {
			let context = CoreDataManager.shared.persistentContainer.viewContext
			let rateEntity = ExchangeRateEntity(context: context)
			rateEntity.storedDate = Date()
			rateEntity.timestamp = data.timestamp
			//  "date" : "2024-02-11"
			let dateF = DateFormatter()
			dateF.dateFormat = "yyyy-MM-dd"
			rateEntity.date = dateF.date(from: data.date)
			rateEntity.ratesData = binaryData
			CoreDataManager.shared.saveExchangeRate(entity: rateEntity)
		}
	}
	
	
	private func isLastStoredDataFromYesterday() -> Bool {
		return CoreDataManager.shared.isLastStoredDataFromYesterday()
	}
	
	
	private func getExchangeRates() {
		if isLastStoredDataFromYesterday() {
			if let localData: ExchangeRateEntity = CoreDataManager.shared.fetchLastExchangeRate() {
				if let rateModel = CoreDataManager.shared.convertToExchangeModel(from: localData) {
					self.exchangeRate.onNext(rateModel)
				}
				return
			}
		}
		
		Observable.combineLatest(fromCurrency, toCurrency)
			.flatMapLatest { [unowned self] from, to -> Observable<ExchangeResponseModel> in
				return apiService.getExchangeRates()
			}
			.subscribe(onNext: { [weak self] data in
				self?.exchangeRate.onNext(data)
				self?.saveRatesLocally(data)
				self?.delegate?.exchangeRatesFetched(with: data)
				self?.delegate?.dataFetchStatus(true)
			}, onError: { [weak self] error in
				self?.errorSubject.onNext(error)
				if let apiError = error as? APIError {
					self?.handleAPIError(apiError: apiError)
				} else {
					self?.handleError(error: error)
				}
				self?.delegate?.dataFetchStatus(false)
			})
			.disposed(by: disposeBag)
	}	
}
