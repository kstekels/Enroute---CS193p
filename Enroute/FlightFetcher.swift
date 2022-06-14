import SwiftUI
import Combine

class FlightFetcher: ObservableObject // struct
{
    init(flightSearch: FlightSearch) {
        self.flightSearch = flightSearch
        fetchFlights()
    }

    var flightSearch: FlightSearch {
        didSet { fetchFlights() }
    }
    
    @Published private(set) var latest = [FAFlight]()

    // MARK: - Private Implementation
    
    private func filter(_ results: Set<FAFlight>) -> [FAFlight] {
        return results
            .filter { flightSearch.airline == nil || $0.ident.hasPrefix(flightSearch.airline!) }
            .filter { flightSearch.origin == nil || $0.origin == flightSearch.origin || $0.ident.hasPrefix("K"+flightSearch.origin!) }
            .filter { !flightSearch.inTheAir || $0.departure != nil }
            .sorted() // Flight implements Comparable (sorts by arrival time)
    }

    private func fetchFlights() {
        flightAwareResultsCancellable = nil
        flightAwareRequest?.stopFetching()
        flightAwareRequest = nil
        let icao = flightSearch.destination
        flightAwareRequest = EnrouteRequest.create(airport: icao, howMany: 90)
        flightAwareRequest?.fetch(andRepeatEvery: 30)
        flightAwareResultsCancellable = flightAwareRequest?.results.sink { [weak self] results in
            Airports.all.fetch(icao) // prefetch
            results.forEach {
                Airports.all.fetch($0.origin) // prefetch
                Airlines.all.fetch($0.airlineCode) // prefetch
            }
            self?.latest = self?.filter(results) ?? []
        }
    }

    private(set) var flightAwareRequest: EnrouteRequest!
    private var flightAwareResultsCancellable: AnyCancellable?
}
