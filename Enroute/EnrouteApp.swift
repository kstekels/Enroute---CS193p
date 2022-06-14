
import SwiftUI

@main
struct EnrouteApp: App {
    var body: some Scene {
        WindowGroup {
            FlightsEnrouteView(flightSearch: FlightSearch(destination: "KSFO"))
        }
    }
}
