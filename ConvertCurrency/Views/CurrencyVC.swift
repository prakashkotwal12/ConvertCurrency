//
//  CurrencyVC.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 11/02/2024.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyVC: UIViewController {
		
	private let downArrow = " ↓"
	private let disposeBag = DisposeBag()
	
	var ratesViewModel: RatesViewModel?
	private let ratesVM = RatesViewModel(apiService: APIService())
	private let symbolsVM = SymbolsViewModel(apiService: APIService())
	
	@IBOutlet weak var buttonExchange: UIButton!
	@IBOutlet weak var fromCurrencyText: UITextField!
	@IBOutlet weak var toCurrencyText: UITextField!
	@IBOutlet weak var fromCurrencyButton: UIButton!
	@IBOutlet weak var toCurrencyButton: UIButton!
	@IBOutlet weak var tableViewCurrency: UITableView!
	@IBOutlet weak var toCurrencyView: UIView!
	@IBOutlet weak var fromCurrencyView: UIView!
	
	private var selectedLabel = "From Currency"
	private var currencyModels: [String: String] = [:]
	private var currencyKeys: [String] = []
	
	private var toCurrency = "USD"
	private var fromCurrency = "EUR"
	
	private let numberFormatter: NumberFormatter? = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 6
		return formatter
	}()
	
	
	
	
	
	var currencyRates: [String: Double] = [:]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
		ratesVM.delegate = self
	}
	
	private func setupBindings() {
		symbolsVM.symbols
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] data in
				self?.updateUI(with: data)
			})
			.disposed(by: disposeBag)
		
		ratesVM.exchangeRate
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] data in
				self?.currencyRates = data.rates
			})
			.disposed(by: disposeBag)
		
		fromCurrencyText.rx.text.orEmpty
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] newText in
				self?.convertAndDisplay(fromToToCurrency: true)
			})
			.disposed(by: disposeBag)
		
		toCurrencyText.rx.text.orEmpty
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] newText in
				self?.convertAndDisplay(fromToToCurrency: false)
			})
			.disposed(by: disposeBag)
		
		fromCurrencyButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.showCurrencySelector(selectedLabel: "From Currency")
			})
			.disposed(by: disposeBag)
		
		toCurrencyButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.showCurrencySelector(selectedLabel: "To Currency")
			})
			.disposed(by: disposeBag)
		
		buttonExchange.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.exchangeCurrency()
			})
			.disposed(by: disposeBag)
	}
	
	private func updateUI(with data: SymbolModel) {
		currencyModels = data.symbols
		currencyKeys = currencyModels.keys.sorted()
		tableViewCurrency.reloadData()
	}
	
	func convertAndDisplay(fromToToCurrency : Bool) {
		guard let numberFormatter = self.numberFormatter,
					let fromText = fromToToCurrency ? fromCurrencyText.text : toCurrencyText.text,
					let amount = numberFormatter.number(from: fromText)?.doubleValue
		else
		{
			return
		}
		
		let fromC = fromToToCurrency ? fromCurrency : toCurrency
		let toC = fromToToCurrency ? toCurrency : fromCurrency
		let currencyConverter = CurrencyConverter(responseData: self.currencyRates)
		let convertedAmount = currencyConverter.convertAmount(amount, fromCurrency: fromC, toCurrency: toC)
		
		if fromToToCurrency{
			toCurrencyText.text = numberFormatter.string(from: NSNumber(value: convertedAmount ?? 0))
		}
		else
		{
			fromCurrencyText.text = numberFormatter.string(from: NSNumber(value: convertedAmount ?? 0))
		}
	}
	
	func updateUIElements() {
		fromCurrencyButton.setTitle("\(fromCurrency) \(downArrow)", for: .normal)
		toCurrencyButton.setTitle("\(toCurrency) \(downArrow)", for: .normal)
		fromCurrencyText.text = "1.00"  // Update with the default conversion rate
	}
	
	private func showCurrencySelector(selectedLabel: String) {
		// Implement the logic to show currency selector
		self.selectedLabel = selectedLabel
		self.tableViewCurrency.reloadData()
	}
	
	private func exchangeCurrency() {
		// Implement the logic to show currency selector
		let fromC = fromCurrency
		let toC = toCurrency
		self.fromCurrency = toC
		self.toCurrency = fromC
		self.tableViewCurrency.reloadData()
		
		self.fromCurrencyButton.setTitle(fromCurrency + downArrow, for: .normal)
		self.toCurrencyButton.setTitle(toCurrency + downArrow, for: .normal)
		
		let toCurrencyAmount = toCurrencyText.text
		let fromCurrencyAmount = fromCurrencyText.text
		fromCurrencyText.text = toCurrencyAmount  // Update with the default conversion rate
		toCurrencyText.text = fromCurrencyAmount
		
		
		
		
		self.convertAndDisplay(fromToToCurrency: true)
		
	}
}


// ... Other extensions and classes


extension CurrencyVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Select \(selectedLabel)"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currencyKeys.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell")!
		let currencyKey = currencyKeys[indexPath.row]
		cell.textLabel?.text = currencyKey + " - " + (currencyModels[currencyKey] ?? "")
		cell.accessoryType = .none
		if selectedLabel == "From Currency"
		{
			if fromCurrency == currencyKey
			{
				cell.accessoryType = .checkmark
			}
		}
		else
		{
			if toCurrency == currencyKey
			{
				cell.accessoryType = .checkmark
			}
		}
		
		
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let currencyKey = currencyKeys[indexPath.row]
		if selectedLabel == "From Currency"
		{
			self.fromCurrency = currencyKey
			self.fromCurrencyButton.setTitle(currencyKey + downArrow, for: .normal)
		}
		else
		{
			self.toCurrency = currencyKey
			self.toCurrencyButton.setTitle(currencyKey + downArrow, for: .normal)
		}
		tableView.reloadData()
		
		self.convertAndDisplay(fromToToCurrency: true)
	}
}

extension CurrencyVC : RatesViewModelDelegate
{
	func dataFetchStatus(_ success: Bool) {
		print("Data fetch status : \(success)")
	}
	
	func exchangeRatesFetched(with data: ExchangeResponseModel) {
		fromCurrencyButton.setTitle("\(fromCurrency) \(downArrow)", for: .normal)
		toCurrencyButton.setTitle("\(toCurrency) \(downArrow)", for: .normal)
		fromCurrencyText.text = "1.00"
		
		let currencyConverter = CurrencyConverter(responseData: self.currencyRates)
		let convertedAmount = currencyConverter.convertAmount(1, fromCurrency: fromCurrency, toCurrency: toCurrency)
		
		guard let numberFormatter = self.numberFormatter else {
			return
		}
		
		toCurrencyText.text = numberFormatter.string(from: NSNumber(value: convertedAmount ?? 0))
	}
	//	func handleDataFetchError(_ error: DataFetchError) {
	//			// Handle data fetch error here
	//			switch error {
	//			case .localDataFetchError:
	//					coreDataManager.handleLocalDataFetchError(error)
	//			case .apiDataFetchError(let apiError):
	//					ratesViewModel.handleAPIError(apiError: apiError)
	//			}
	//	}
}


