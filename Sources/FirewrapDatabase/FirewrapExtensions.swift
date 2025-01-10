/*#if os(iOS)
import FirebaseFirestore

func replaceTimestampsWithDates(in dictionary: [String: Any]) -> [String: Any] {
    
    var updatedDictionary = dictionary

    for (key, value) in dictionary {
        if let timestamp = value as? Timestamp {
            updatedDictionary[key] = timestamp.dateValue()
        } else if let nestedDictionary = value as? [String: Any] {
            updatedDictionary[key] = replaceTimestampsWithDates(in: nestedDictionary)
        } else if let array = value as? [Any] {
            updatedDictionary[key] = replaceTimestampsInArray(array)
        }
    }

    return updatedDictionary
}

/*
 let date = Date() // Текущая дата и время
 let dateFormatter = ISO8601DateFormatter()

 let iso8601String = dateFormatter.string(from: date)

 */

fileprivate func replaceTimestampsInArray(_ array: [Any]) -> [Any] {
    return array.map { element in
        if let timestamp = element as? Timestamp {
            return timestamp.dateValue()
        } else if let nestedDictionary = element as? [String: Any] {
            return replaceTimestampsWithDates(in: nestedDictionary)
        } else if let nestedArray = element as? [Any] {
            return replaceTimestampsInArray(nestedArray)
        } else {
            return element
        }
    }
}
#endif
*/
