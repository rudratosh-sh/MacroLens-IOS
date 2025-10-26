//
//  CoreDataStack.swift
//  MacroLens
//
//  Path: MacroLens/Core/Storage/CoreDataStack.swift
//
//  DEPENDENCIES:
//  - MacroLens.xcdatamodeld (Core Data model file)
//  - Config.swift (for logging)
//
//  USED BY:
//  - CacheManager (for offline caching)
//  - FoodService (for food logs persistence)
//  - RecipeService (for favorite recipes)
//  - ProgressService (for weight/measurements tracking)
//  - OfflineQueueManager (for pending sync operations)
//
//  PURPOSE:
//  - Comprehensive Core Data management
//  - Background context for sync operations
//  - CRUD operations with type safety
//  - Migration and error handling
//  - Batch operations for performance
//

import Foundation
import CoreData

// MARK: - Core Data Stack

/// Production-grade Core Data stack with background processing and migration support
final class CoreDataStack {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    /// Main persistent container
    private(set) var persistentContainer: NSPersistentContainer
    
    /// Main context for UI operations (main thread)
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Background context for heavy operations (background thread)
    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    /// Coordinator for managing persistent stores
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return persistentContainer.persistentStoreCoordinator
    }
    
    // MARK: - Initialization
    
    private init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "MacroLens")
        
        if inMemory {
            // For testing: use in-memory store
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Production: configure persistent store
            configurePersistentStore()
        }
        
        loadPersistentStores()
        configureContexts()
    }
    
    // MARK: - Configuration
    
    /// Configure persistent store description
    private func configurePersistentStore() {
        guard let description = persistentContainer.persistentStoreDescriptions.first else {
            Config.Logging.log("No persistent store description found", level: .error)
            return
        }
        
        // Enable lightweight migration
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        // Enable persistent history tracking for CloudKit sync (future)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        Config.Logging.log("Persistent store configured", level: .info)
    }
    
    /// Load persistent stores
    private func loadPersistentStores() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Handle different error types
                self.handleLoadError(error, for: storeDescription)
            } else {
                Config.Logging.log("Persistent store loaded: \(storeDescription.url?.lastPathComponent ?? "Unknown")", level: .info)
            }
        }
    }
    
    /// Configure contexts
    private func configureContexts() {
        // Main context configuration
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Observe context saves for debugging
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    // MARK: - Error Handling
    
    /// Handle persistent store loading errors
    private func handleLoadError(_ error: NSError, for description: NSPersistentStoreDescription) {
        Config.Logging.log("Failed to load persistent store: \(error), \(error.userInfo)", level: .error)
        
        // Check error type
        switch error.code {
        case NSPersistentStoreIncompatibleVersionHashError, NSMigrationMissingSourceModelError:
            // Migration failed - delete and recreate store
            Config.Logging.log("Migration failed, attempting to recreate store", level: .warning)
            recreatePersistentStore(at: description.url)
            
        case NSPersistentStoreIncompatibleSchemaError:
            // Schema incompatible - delete store
            Config.Logging.log("Schema incompatible, deleting store", level: .warning)
            recreatePersistentStore(at: description.url)
            
        default:
            // Fatal error for production - should handle more gracefully
            fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
        }
    }
    
    /// Recreate persistent store (destructive - use with caution)
    private func recreatePersistentStore(at url: URL?) {
        guard let url = url else { return }
        
        do {
            // Delete existing store
            try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            
            // Reload
            loadPersistentStores()
            
            Config.Logging.log("Persistent store recreated successfully", level: .info)
        } catch {
            Config.Logging.log("Failed to recreate persistent store: \(error)", level: .error)
            fatalError("Could not recreate persistent store: \(error)")
        }
    }
    
    // MARK: - Context Management
    
    /// Create a new background context for isolated operations
    /// - Returns: Configured background context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Perform work on background context
    /// - Parameter block: Work to perform
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Save Operations
    
    /// Save main context (UI thread)
    /// - Throws: CoreDataError on failure
    func saveMainContext() throws {
        try saveContext(mainContext)
    }
    
    /// Save background context
    /// - Throws: CoreDataError on failure
    func saveBackgroundContext() throws {
        try saveContext(backgroundContext)
    }
    
    /// Save a specific context
    /// - Parameter context: Context to save
    /// - Throws: CoreDataError on failure
    func saveContext(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else {
            Config.Logging.log("Context has no changes, skipping save", level: .debug)
            return
        }
        
        do {
            try context.save()
            Config.Logging.log("Context saved successfully", level: .debug)
        } catch {
            Config.Logging.log("Failed to save context: \(error)", level: .error)
            throw CoreDataError.saveFailed(error)
        }
    }
    
    /// Save context with completion handler
    /// - Parameters:
    ///   - context: Context to save
    ///   - completion: Called after save (on main thread)
    func saveContext(_ context: NSManagedObjectContext, completion: @escaping (Result<Void, CoreDataError>) -> Void) {
        context.perform {
            do {
                try self.saveContext(context)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch let error as CoreDataError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new object
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - context: Context to insert into (defaults to mainContext)
    /// - Returns: New object instance
    func create<T: NSManagedObject>(_ entityType: T.Type, in context: NSManagedObjectContext? = nil) -> T {
        let context = context ?? mainContext
        let entityName = String(describing: entityType)
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Entity \(entityName) not found in Core Data model")
        }
        
        let object = T(entity: entity, insertInto: context)
        Config.Logging.log("Created new \(entityName)", level: .debug)
        return object
    }
    
    /// Fetch objects matching predicate
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - sortDescriptors: Sort order
    ///   - fetchLimit: Maximum results (nil for all)
    ///   - context: Context to fetch from
    /// - Returns: Array of matching objects
    /// - Throws: CoreDataError on failure
    func fetch<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil,
        in context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let context = context ?? mainContext
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            Config.Logging.log("Fetched \(results.count) \(String(describing: entityType)) objects", level: .debug)
            return results
        } catch {
            Config.Logging.log("Fetch failed: \(error)", level: .error)
            throw CoreDataError.fetchFailed(error)
        }
    }
    
    /// Fetch first object matching predicate
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - context: Context to fetch from
    /// - Returns: First matching object or nil
    /// - Throws: CoreDataError on failure
    func fetchFirst<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil
    ) throws -> T? {
        let results = try fetch(entityType, predicate: predicate, fetchLimit: 1, in: context)
        return results.first
    }
    
    /// Count objects matching predicate
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - context: Context to count in
    /// - Returns: Count of matching objects
    /// - Throws: CoreDataError on failure
    func count<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil
    ) throws -> Int {
        let context = context ?? mainContext
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        
        do {
            let count = try context.count(for: fetchRequest)
            Config.Logging.log("Count for \(String(describing: entityType)): \(count)", level: .debug)
            return count
        } catch {
            Config.Logging.log("Count failed: \(error)", level: .error)
            throw CoreDataError.fetchFailed(error)
        }
    }
    
    /// Delete object
    /// - Parameters:
    ///   - object: Object to delete
    ///   - context: Context (inferred from object)
    func delete(_ object: NSManagedObject) {
        let context = object.managedObjectContext ?? mainContext
        context.delete(object)
        Config.Logging.log("Deleted \(String(describing: type(of: object)))", level: .debug)
    }
    
    /// Delete objects matching predicate
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - context: Context to delete from
    /// - Throws: CoreDataError on failure
    func deleteAll<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? mainContext
        let objects = try fetch(entityType, predicate: predicate, in: context)
        
        objects.forEach { context.delete($0) }
        
        Config.Logging.log("Deleted \(objects.count) \(String(describing: entityType)) objects", level: .debug)
    }
    
    // MARK: - Batch Operations
    
    /// Batch delete objects matching predicate (efficient for large datasets)
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - context: Context to delete from
    /// - Throws: CoreDataError on failure
    func batchDelete<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? mainContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            // Merge changes into context
            if let objectIDArray = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
                
                Config.Logging.log("Batch deleted \(objectIDArray.count) \(String(describing: entityType)) objects", level: .debug)
            }
        } catch {
            Config.Logging.log("Batch delete failed: \(error)", level: .error)
            throw CoreDataError.deleteFailed(error)
        }
    }
    
    /// Batch update objects (efficient for large datasets)
    /// - Parameters:
    ///   - entityType: Entity class type
    ///   - predicate: Filter predicate
    ///   - propertiesToUpdate: Dictionary of properties to update
    ///   - context: Context to update in
    /// - Throws: CoreDataError on failure
    func batchUpdate<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        propertiesToUpdate: [String: Any],
        in context: NSManagedObjectContext? = nil
    ) throws {
        let context = context ?? mainContext
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: String(describing: entityType))
        batchUpdateRequest.predicate = predicate
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
            
            // Merge changes into context
            if let objectIDArray = result?.result as? [NSManagedObjectID] {
                let changes = [NSUpdatedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
                
                Config.Logging.log("Batch updated \(objectIDArray.count) \(String(describing: entityType)) objects", level: .debug)
            }
        } catch {
            Config.Logging.log("Batch update failed: \(error)", level: .error)
            throw CoreDataError.updateFailed(error)
        }
    }
    
    // MARK: - Notifications
    
    @objc private func contextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        
        // Log saves (useful for debugging)
        let inserted = context.insertedObjects.count
        let updated = context.updatedObjects.count
        let deleted = context.deletedObjects.count
        
        if inserted > 0 || updated > 0 || deleted > 0 {
            Config.Logging.log("Context saved - Inserted: \(inserted), Updated: \(updated), Deleted: \(deleted)", level: .debug)
        }
    }
    
    // MARK: - Utilities
    
    /// Reset all data (destructive - use with caution)
    /// - Throws: CoreDataError on failure
    func resetAllData() throws {
        Config.Logging.log("Resetting all Core Data", level: .warning)
        
        guard let storeURL = persistentStoreCoordinator.persistentStores.first?.url else {
            throw CoreDataError.resetFailed(NSError(domain: "CoreDataStack", code: -1, userInfo: [NSLocalizedDescriptionKey: "No store URL found"]))
        }
        
        do {
            // Remove all stores
            for store in persistentStoreCoordinator.persistentStores {
                try persistentStoreCoordinator.remove(store)
            }
            
            // Delete store file
            try FileManager.default.removeItem(at: storeURL)
            
            // Reload stores
            loadPersistentStores()
            
            Config.Logging.log("Core Data reset successfully", level: .info)
        } catch {
            Config.Logging.log("Failed to reset Core Data: \(error)", level: .error)
            throw CoreDataError.resetFailed(error)
        }
    }
    
    // MARK: - Preview Support
    
    /// Create in-memory stack for SwiftUI previews
    /// - Returns: CoreDataStack instance with in-memory store
    static func preview() -> CoreDataStack {
        return CoreDataStack(inMemory: true)
    }
}

// MARK: - Core Data Errors

enum CoreDataError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case updateFailed(Error)
    case resetFailed(Error)
    case entityNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update data: \(error.localizedDescription)"
        case .resetFailed(let error):
            return "Failed to reset data: \(error.localizedDescription)"
        case .entityNotFound(let entityName):
            return "Entity '\(entityName)' not found in Core Data model"
        }
    }
}

// MARK: - Usage Examples

/*
 
 // MARK: - Basic CRUD Operations
 
 // 1. Create
 let foodLog = CoreDataStack.shared.create(FoodLogEntity.self)
 foodLog.id = UUID().uuidString
 foodLog.mealType = "breakfast"
 try CoreDataStack.shared.saveMainContext()
 
 // 2. Fetch All
 let allLogs = try CoreDataStack.shared.fetch(FoodLogEntity.self)
 
 // 3. Fetch with Predicate
 let breakfastLogs = try CoreDataStack.shared.fetch(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "mealType == %@", "breakfast")
 )
 
 // 4. Fetch First
 let firstLog = try CoreDataStack.shared.fetchFirst(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "id == %@", "some-id")
 )
 
 // 5. Count
 let count = try CoreDataStack.shared.count(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "mealType == %@", "lunch")
 )
 
 // 6. Update
 if let log = firstLog {
     log.mealType = "lunch"
     try CoreDataStack.shared.saveMainContext()
 }
 
 // 7. Delete
 if let log = firstLog {
     CoreDataStack.shared.delete(log)
     try CoreDataStack.shared.saveMainContext()
 }
 
 // 8. Delete All
 try CoreDataStack.shared.deleteAll(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "mealType == %@", "dinner")
 )
 
 
 // MARK: - Background Operations
 
 // Perform heavy sync in background
 CoreDataStack.shared.performBackgroundTask { context in
     // Fetch and process data
     let fetchRequest = NSFetchRequest<FoodLogEntity>(entityName: "FoodLogEntity")
     
     do {
         let logs = try context.fetch(fetchRequest)
         
         // Process logs
         for log in logs {
             log.syncStatus = "synced"
         }
         
         // Save background context
         try context.save()
         
     } catch {
         Config.Logging.log("Background sync failed: \(error)", level: .error)
     }
 }
 
 
 // MARK: - Batch Operations
 
 // Batch delete (efficient for large datasets)
 try CoreDataStack.shared.batchDelete(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "loggedAt < %@", oldDate as NSDate)
 )
 
 // Batch update
 try CoreDataStack.shared.batchUpdate(
     FoodLogEntity.self,
     predicate: NSPredicate(format: "syncStatus == %@", "pending"),
     propertiesToUpdate: ["syncStatus": "synced"]
 )
 
 
 // MARK: - Advanced Fetch
 
 // Fetch with sorting and limit
 let recentLogs = try CoreDataStack.shared.fetch(
     FoodLogEntity.self,
     sortDescriptors: [NSSortDescriptor(key: "loggedAt", ascending: false)],
     fetchLimit: 10
 )
 
 // Complex predicate
 let complexPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
     NSPredicate(format: "mealType == %@", "breakfast"),
     NSPredicate(format: "loggedAt >= %@", todayStart as NSDate),
     NSPredicate(format: "calories > %d", 200)
 ])
 
 let filteredLogs = try CoreDataStack.shared.fetch(
     FoodLogEntity.self,
     predicate: complexPredicate,
     sortDescriptors: [NSSortDescriptor(key: "loggedAt", ascending: true)]
 )
 
 */
