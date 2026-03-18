import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "https://87-106-60-114.nip.io/geton/calendar"
    
    func saveCalendarStates(userID: String, states: [CalendarViewState]) async throws {
        let dtos = states.map { $0.toDTO() }
        let requestBody = UserCalendarRequest(userID: userID, states: dtos)
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchCalendarStates(userID: String) async throws -> [CalendarViewState] {
        guard let url = URL(string: "\(baseURL)/\(userID)") else { return [] }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let responseBody = try JSONDecoder().decode(UserCalendarRequest.self, from: data)
        return responseBody.states.map { CalendarViewState(from: $0) }
    }
}
