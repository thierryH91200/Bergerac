import CoreData
import Foundation


public class EntityTransactions: NSManagedObject {

    override public class func keyPathsForValuesAffectingValue( forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        if key == "sectionIdentifier" {
            keyPaths.insert("dateOperation")
        }
        return keyPaths as Set<String>
    }

}
