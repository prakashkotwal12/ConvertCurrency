//
//  CoreDataManager.swift
//  ConvertCurrency
//
//  Created by Prakash Kotwal on 12/02/2024.
//

import CoreData
class CoreDataManager {
	static let shared = CoreDataManager()
	
	private init() {}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "CurrencyConverter") // Replace with your actual Core Data model name
		container.loadPersistentStores(completionHandler: { (_, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	// MARK: - ExchangeRateEntity
	
	func saveExchangeRate(entity: ExchangeRateEntity) {
		let context = persistentContainer.viewContext
		if let existingEntity = fetchLastExchangeRate() {
			context.delete(existingEntity)
		}
		context.insert(entity)
		saveContext()
	}
	
	func saveSymbols(entity: SymbolEntity) {
		let context = persistentContainer.viewContext
		if let existingEntity = fetchLastSymbol() {
			context.delete(existingEntity)
		}
		context.insert(entity)
		saveContext()
	}
	func fetchLastSymbol() -> SymbolEntity? {
		let context = persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<SymbolEntity> = SymbolEntity.fetchRequest()
		fetchRequest.fetchLimit = 1
		let sortDescriptor = NSSortDescriptor(key: "storedDate", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			let result = try context.fetch(fetchRequest)
			return result.first
		} catch {
			print("Error fetching last exchange rate: \(error)")
			return nil
		}
	}
	func fetchLastExchangeRate() -> ExchangeRateEntity? {
		let context = persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<ExchangeRateEntity> = ExchangeRateEntity.fetchRequest()
		fetchRequest.fetchLimit = 1
		let sortDescriptor = NSSortDescriptor(key: "storedDate", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			let result = try context.fetch(fetchRequest)
			return result.first
		} catch {
			print("Error fetching last exchange rate: \(error)")
			return nil
		}
	}
	
	func isLastStoredDataFromYesterday() -> Bool {
		if let lastStoredEntity = fetchLastExchangeRate() {
			// Assuming 'timestamp' is a date attribute in your ExchangeRateEntity
			let calendar = Calendar.current
			let lastStoredDate = calendar.startOfDay(for: lastStoredEntity.storedDate ?? Date())
			let currentDate = calendar.startOfDay(for: Date())
			
			return calendar.isDate(lastStoredDate, inSameDayAs: currentDate.addingTimeInterval(-24 * 60 * 60))
		}
		return false
	}
	
	// MARK: - Additional Methods for Binary Data
	
	func convertToBinaryData(dictionary: [String: Any]) -> Data? {
		return try? NSKeyedArchiver.archivedData(withRootObject: dictionary, requiringSecureCoding: false)
	}
	
	func convertToDictionary(binaryData: Data) -> [String: Double]? {
		do {
			return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: binaryData) as? [String: Double]
		} catch {
			print("Error converting binary data to dictionary: \(error.localizedDescription)")
			return nil
		}
	}
	
	func convertToStringString(binaryData: Data) -> [String: String]? {
		do {
			return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: binaryData) as? [String: String]
		} catch {
			print("Error converting binary data to dictionary: \(error.localizedDescription)")
			return nil
		}
	}
	
	func handleLocalDataFetchError(_ error: Error) {
		print("Error fetching data from local database: \(error.localizedDescription)")
	}
	
	func convertToSymbolModel(from symbolEntity: SymbolEntity) -> SymbolModel? {
		guard let symbolsData = symbolEntity.symbolsData,
					let symbolsDictionary = convertToStringString(binaryData: symbolsData) else {
			return nil
		}
		
		// Assuming SymbolModel has an initializer that takes [String: Double]
		return SymbolModel(symbols: symbolsDictionary)
	}
	
	func convertToExchangeModel(from rateEntity: ExchangeRateEntity) -> ExchangeResponseModel? {
		guard let ratesData = rateEntity.ratesData,
					let ratesDictionary = convertToDictionary(binaryData: ratesData) else {
			return nil
		}
		let timestamp = rateEntity.timestamp
		//  "date" : "2024-02-11"
		let dateF = DateFormatter()
		dateF.dateFormat = "yyyy-MM-dd"
		let date = dateF.string(from: rateEntity.date ?? Date())
		
		// Assuming SymbolModel has an initializer that takes [String: Double]
		return ExchangeResponseModel(timestamp: timestamp, base: rateEntity.baseCurrency ?? "EUR", date: date, rates: ratesDictionary)
	}	
}

