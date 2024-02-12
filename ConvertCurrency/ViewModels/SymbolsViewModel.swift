//
//  SymbolsViewModel.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

import RxSwift

class SymbolsViewModel: BaseViewModel {
	
	private let apiService: APIService
	private let disposeBag = DisposeBag()
	
	let symbols = PublishSubject<SymbolModel>()
	let errorSubject = PublishSubject<Error>() // Add this line
	
	let fromCurrency = BehaviorSubject<String>(value: "EUR")
	let toCurrency = BehaviorSubject<String>(value: "USD")
	
	weak var delegate: DataFetchDelegate?
	
	init(apiService: APIService) {
		self.apiService = apiService
		super.init()
		setupBindings()
	}
	
	private func setupBindings() {
		getSymbols()
	}
	
	private func saveSymbolsLocally(_ data: SymbolModel) {
		if let binaryData = CoreDataManager.shared.convertToBinaryData(dictionary: data.symbols)
		{
			let context = CoreDataManager.shared.persistentContainer.viewContext
			let symbolEntity = SymbolEntity(context: context)
			symbolEntity.storedDate = Date()
			symbolEntity.symbolsData = binaryData
			CoreDataManager.shared.saveSymbols(entity: symbolEntity)
		}
	}

	// Function to save symbols in the local database
//	private func saveSymbolsLocally(_ data: SymbolModel) {
//		if let binaryData = CoreDataManager.shared.convertToBinaryData(dictionary: data.symbols) {
//			let symbolEntity = SymbolEntity()
//			symbolEntity.timestamp = Date()
//			symbolEntity.symbolsData = binaryData
//			CoreDataManager.shared.saveSymbols(entity: symbolEntity)
//		}
//	}
	
	
	private func isLastStoredDataFromYesterday() -> Bool {
		return CoreDataManager.shared.isLastStoredDataFromYesterday()//for: SymbolEntity.self)
	}
	
	
	private func getSymbols() {
		if isLastStoredDataFromYesterday() {
			if let localData: SymbolEntity = CoreDataManager.shared.fetchLastSymbol() {
				if let symbolModel = CoreDataManager.shared.convertToSymbolModel(from: localData) {
					self.symbols.onNext(symbolModel)
				}
				return
			}
		}
		
		Observable.combineLatest(fromCurrency, toCurrency)
			.flatMapLatest { [unowned self] from, to -> Observable<SymbolModel> in
				return apiService.makeAPICall()
			}
			.subscribe(onNext: { [weak self] data in
				self?.symbols.onNext(data)
				self?.saveSymbolsLocally(data)
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

