import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://192.168.10.35:8081/calendar"
    
    func saveCalendarStates(username: String, states: [CalendarViewState]) async throws {
        let dtos = states.map { $0.toDTO() }
        let requestBody = UserCalendarRequest(username: username, states: dtos)
        
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
    
    func fetchCalendarStates(username: String) async throws -> [CalendarViewState] {
        guard let url = URL(string: "\(baseURL)/\(username)") else { return [] }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let responseBody = try JSONDecoder().decode(UserCalendarRequest.self, from: data)
        return responseBody.states.map { CalendarViewState(from: $0) }
    }
}
