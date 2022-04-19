import Cocoa


// https://stackoverflow.com/questions/2730832/how-can-i-duplicate-or-copy-a-core-data-managed-object
extension NSManagedObject {
    
    func copyEntireObjectGraph(context: NSManagedObjectContext) -> NSManagedObject {
        
        var cache = Dictionary<NSManagedObjectID, NSManagedObject>()
        return cloneObject(context: context, cache: &cache)
    }
    
    func cloneObject(context: NSManagedObjectContext, cache alreadyCopied: inout Dictionary<NSManagedObjectID, NSManagedObject>) -> NSManagedObject {
        
        guard let entityName = self.entity.name else {
            fatalError("source.entity.name == nil")
        }
        
        if let storedCopy = alreadyCopied[self.objectID] {
            return storedCopy
        }
        
        let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        alreadyCopied[self.objectID] = cloned
        
        if let attributes = NSEntityDescription.entity(forEntityName: entityName, in: context)?.attributesByName {
            for key in attributes.keys {
                cloned.setValue(self.value(forKey: key), forKey: key)
            }
        }
        
        if let relationships = NSEntityDescription.entity(forEntityName: entityName, in: context)?.relationshipsByName {
            
            for (key, value) in relationships {
                
                if value.isToMany {
                    if let sourceSet = self.value(forKey: key) as? NSMutableOrderedSet {
                        
                        guard let clonedSet = cloned.value(forKey: key) as? NSMutableOrderedSet else {
                            fatalError("Could not cast relationship \(key) to an NSMutableOrderedSet")
                        }
                        
                        let enumerator = sourceSet.objectEnumerator()
                        var nextObject = enumerator.nextObject() as? NSManagedObject
                        
                        while let relatedObject = nextObject {
                            
                            let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                            clonedSet.add(clonedRelatedObject)
                            nextObject = enumerator.nextObject() as? NSManagedObject
                            
                        }
                        
                    } else if let sourceSet = self.value(forKey: key) as? NSMutableSet {
                        
                        guard let clonedSet = cloned.value(forKey: key) as? NSMutableSet else {
                            fatalError("Could not cast relationship \(key) to an NSMutableSet")
                        }
                        
                        let enumerator = sourceSet.objectEnumerator()
                        var nextObject = enumerator.nextObject() as? NSManagedObject
                        while let relatedObject = nextObject {
                            
                            let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                            clonedSet.add(clonedRelatedObject)
                            nextObject = enumerator.nextObject() as? NSManagedObject
                        }
                    }
                    
                } else {
                    
                    if let relatedObject = self.value(forKey: key) as? NSManagedObject {
                        
                        let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                        cloned.setValue(clonedRelatedObject, forKey: key)
                    }
                }
            }
        }
        return cloned
    }
}


extension NSManagedObject {
        
    func duplicateTransactions(context: NSManagedObjectContext, entityTrans: EntityTransactions) -> EntityTransactions
    {
        let entityTransaction = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context) as? EntityTransactions
        
        entityTransaction?.dateCree = Date()
        entityTransaction?.uuid = UUID()
        
        entityTransaction?.dateModifie = Date()
        
        entityTransaction?.datePointage  = entityTrans.datePointage
        
        // DateOperation
        entityTransaction?.dateOperation  = entityTrans.dateOperation
        
        // Relevé bancaire
        entityTransaction?.bankStatement = entityTrans.bankStatement
        
        // ModePaiement
        entityTransaction?.paymentMode = entityTrans.paymentMode
        
        // Statut
        entityTransaction?.statut = entityTrans.statut
        
        // Operation Link
        entityTransaction?.operationLiee = nil
        
        entityTransaction?.account = entityTrans.account
        
        let entitySousOperations = entityTrans.sousOperations?.allObjects as! [EntitySousOperations]
        
        for entitySousOperation in entitySousOperations {
            let ent = saveSubTransactions(context: context, entityTrans: entitySousOperation)
            entityTransaction?.addToSousOperations(ent)
        }
//        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
        return entityTransaction!
    }
    
    func saveSubTransactions(context: NSManagedObjectContext, entityTrans: EntitySousOperations) -> EntitySousOperations
    {
        let entitySousOperations = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context) as? EntitySousOperations
        entitySousOperations?.category = entityTrans.category
        entitySousOperations?.libelle = entityTrans.libelle
        entitySousOperations?.amount = entityTrans.amount
        return entitySousOperations!
    }
}

extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }

        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }

        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { /*dealing with errors up to the usage*/ }
        }
    }
}





