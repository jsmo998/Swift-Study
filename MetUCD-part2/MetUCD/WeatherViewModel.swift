//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Judith Smolenski on 19/11/2023.
//

import Foundation
import CoreLocation

class WeatherViewModel: ObservableObject, NSObject, CLLocationManagerDelegate {
    // Data Model Connection
    private var dataModel = WeatherDataModel()
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) async {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let coordinates = "\(latitude), \(longitude)"
            try? await fetchData(location: coordinates)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            showAlert(message: "Location access denied. Please enable location services in settings.")
        }
    }
    @Published var geoInfo: GeoInfo?
    @Published var weatherInfo: WeatherInfo?
    @Published var pollutionInfo: PollutionInfo?
    @Published var forecastInfo: ForecastInfo?
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    // MARK: - fetchData Function
    func fetchData(location: String) async throws {
        do {
            try await dataModel.fetch(for: location)
            
            DispatchQueue.main.async {
                if let geoData = self.dataModel.geoLocationData?.first {
                        self.geoInfo = GeoInfo(name: geoData.name,
                                               lat: geoData.lat,
                                               lon: geoData.lon,
                                               country: geoData.country)
                    }
                
                if let weatherData = self.dataModel.weatherData {
                    self.weatherInfo = WeatherInfo(weatherText: weatherData.weather[0].weatherText,
                                                   
                        temp: "\(weatherData.main.temp)",
                                                   feelsLike: weatherData.main.feels_like.map { "\($0)"},
                                                   clouds: weatherData.clouds?.all.map { "\($0)"},
                                              windSpeed: weatherData.wind.speed,
                                                   windDirection: weatherData.wind.deg,
                                              humidity: "\(weatherData.main.humidity)",
                                              pressure: "\(weatherData.main.pressure)",
                                                   sunrise: weatherData.sys.sunrise,
                                                   sunset: weatherData.sys.sunset
                    )
                }
                
                if let pollutionData = self.dataModel.pollutionData {
                    self.pollutionInfo = PollutionInfo(
                        co: pollutionData.list.first?.components.co.map { "\($0)"},
                        no: pollutionData.list.first?.components.no.map { "\($0)"},
                        no2: pollutionData.list.first?.components.no2.map { "\($0)"},
                        o3: pollutionData.list.first?.components.o3.map { "\($0)"},
                        so2: pollutionData.list.first?.components.so2.map { "\($0)"},
                        pm2_5: pollutionData.list.first?.components.pm2_5.map { "\($0)"},
                        pm10: pollutionData.list.first?.components.pm10.map { "\($0)"},
                        nh3: pollutionData.list.first?.components.nh3.map { "\($0)"},
                        aqi: "\(String(describing: pollutionData.list.first!.main.aqi))"
                    )
                }
                if let forecastData = self.dataModel.forecastData {
                    self.forecastInfo = ForecastInfo(temp: forecastData.list.first?.main.temp,
                                                     message: forecastData.message,
                                                     icon: forecastData.list.first?.weather.first?.icon)
                }
            }
        } catch {
            guard let fetchError = error as? WeatherDataModel.FetchError else
            { showAlert(message: "Unknown error.")
                return
            }
            handleFetchError(fetchError)
        }
    }
    
    // MARK: Private Functions
    private func handleFetchError(_ error: WeatherDataModel.FetchError) {
        switch error {
        case .invalidURL: showAlert(message: "Invalid Input")
        case .networkError(let error): showAlert(message: "Network Error: \(error.localizedDescription)")
        case .decodingError(let error): showAlert(message: "Decoding Error: \(error.localizedDescription)")
        }
    }
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // MARK: Public Properties
    struct GeoInfo {
        var name: String
        var lat, lon: Double
        var country: String
    }

    struct WeatherInfo {
        var weatherText: String
        var temp: String
        var feelsLike: String?
        var clouds: String?
        var windSpeed: Double
        var windDirection: Double
        var humidity: String
        var pressure: String
        
        var sunrise: Int
        var sunset: Int
    }

    struct PollutionInfo {
        var co: String?
        var no: String?
        var no2: String?
        var o3: String?
        var so2: String?
        var pm2_5: String?
        var pm10: String?
        var nh3: String?
        var aqi: String?
    }

    struct ForecastInfo {
        var temp: Double?
        var message: Int
        var icon: String?
    }
}


