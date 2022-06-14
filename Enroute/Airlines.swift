
import Combine


class Airlines: ObservableObject
{
    static let all: Airlines = Airlines()
        
    var codes: [String] { AirlineInfoRequest.all.compactMap { $0.code }.sorted() }

    subscript (airline: String?) -> AirlineInfo? {
        airline == nil ? nil : fetch(airline!)
    }
    
    @discardableResult
    func fetch(_ airline: String!) -> AirlineInfo? {
        let info = AirlineInfoRequest.fetch(airline)
        if info == nil {
            AirlineInfoRequest.fetch(airline) { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
        return info
    }
    
    private init() { }
}
