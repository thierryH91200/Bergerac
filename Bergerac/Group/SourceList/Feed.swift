import AppKit


struct Datas : Codable {
    var name: String
    var icon: String
    var children: [Children]
}

struct Children : Codable {
    var nameView: String
    var name: String
    var icon: String
}

extension Encodable {
    func encoded() throws -> Data {
        return try PropertyListEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try PropertyListDecoder().decode(T.self, from: self)
    }
}

//extension Data {
//    func decoded<T: Decodable>() throws -> T {
//        return try JSONDecoder().decode(T.self, from: self)
//    }
//}



protocol AnyDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: AnyDecoder {}
extension PropertyListDecoder: AnyDecoder {}
