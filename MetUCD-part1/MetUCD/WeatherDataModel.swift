//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Judith Smolenski on 20/11/2023.
//

import Foundation

// MARK: - Weather Data Model
struct WeatherDataModel {
    private(set) var geoLocationData: GeoLocationData?
    private(set) var weatherData: WeatherData?
    private(set) var pollutionData: PollutionData?
    private(set) var forecastData: ForecastData?
    
    private mutating func clear() {
        geoLocationData = nil
        weatherData = nil
        pollutionData = nil
        forecastData = nil
    }
    
    enum FetchError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
    }
    
    mutating func fetch(for location: String) async throws {
        clear()
        guard let geoLocationData = try await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1),
        let firstLocation = geoLocationData.first else {
            throw FetchError.invalidURL
        }
       do {
           let lat = "\(firstLocation.lat)"
           let lon = "\(firstLocation.lon)"
           
           self.geoLocationData = try await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1)
           self.weatherData = try await OpenWeatherMapAPI.weatherData(lat: lat, lon: lon)
           self.pollutionData = try await OpenWeatherMapAPI.pollutionData(lat: lat, lon: lon)
           self.forecastData = try await OpenWeatherMapAPI.forecastData(lat: lat, lon: lon)
        } catch {
            throw FetchError.networkError(error)
        }

    }
}
// MARK: - Open Weather Map API
struct OpenWeatherMapAPI {
    private static let apiKey = "efe2d2572edff0be2ef6baeffd2642c8"
    private static let base = "https://api.openweathermap.org/"
    
    private static func fetch<T: Decodable>(from apiString: String, asType type: T.Type ) async throws -> T {
        guard let url = URL(string: "\(Self.base)\(apiString)&appid=\(Self.apiKey)&units=metric") else {
            throw WeatherDataModel.FetchError.invalidURL
        }
        
        do {
            print(url)
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON String: \(jsonString)")
            } else {
                print("Failed to convert data to JSON string.")
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            print("Network or Decoding error:", error)
            throw WeatherDataModel.FetchError.networkError(error)
        }
    }
    
    static func geoLocation(for location: String, countLimit count: Int) async throws -> GeoLocationData? {
        let apiString = "geo/1.0/direct?q=\(location)&limit=\(count)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: GeoLocationData.self)
    }
    
    static func weatherData(lat: String, lon: String) async throws -> WeatherData? {
        let apiString = "data/2.5/weather?lat=\(lat)&lon=\(lon)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
    }

    static func pollutionData(lat: String, lon: String) async throws -> PollutionData? {
        // MARK: add proper API string
        let apiString = "data/2.5/air_pollution?lat=\(lat)&lon=\(lon)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: PollutionData.self)
    }
    
    static func forecastData(lat: String, lon: String) async throws -> ForecastData? {
        // MARK: add proper API string
        let apiString = "data/2.5/forecast?lat=\(lat)&lon=\(lon)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: ForecastData.self)
    }
}

// MARK: - Geo Location
typealias GeoLocationData = [GeoLocation]

struct GeoLocation: Codable {
    let name: String
    let local_names: [String: String]?
    let lat, lon: Double
    let country: String
    let state: String?
}

// MARK: - Weather Data
struct WeatherData: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Double
    let wind: Wind
    let clouds: Clouds?
    let rain: Rain?
    let snow: Snow?
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coord: Codable {
    let lon: Double  // longitude of location
    let lat: Double  // latitude
}
struct Weather: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case weatherMain = "main"
        case weatherText = "description"
        case icon
    }
    let id: Int  // weather condition id
    let weatherMain: String  // group of parameters eg. Rain, Snow, Clouds, etc.
    let weatherText: String  // condintion within the group above
    let icon: String  // icon id
}
struct Main: Codable {
    let temp: Double  // temp default unit Kelvin
    let feels_like: Double? // default kelvin
    let pressure: Int // hPa
    let humidity: Int // % humidity
    let temp_min: Double?
    let temp_max: Double?
    let sea_level: Double? // pressure at sea level
    let grnd_level: Double? // pressure at ground level
    
}
struct Wind: Codable {
    let speed: Double // default meter/sec
    let deg: Double // direction of wind in degrees
    let gust: Double? // meter/sec
}
struct Clouds: Codable {
    let all: Int? // % cloudiness
}
struct Rain: Codable {
    enum CodingKeys: String, CodingKey {
        case rain_1h = "1h"
        case rain_3h = "3h"
    }
    let rain_1h: Double?  // rain volume last 1 hr in mm
    let rain_3h: Double?  // last 3 hr
}
struct Snow: Codable {
    enum CodingKeys: String, CodingKey {
        case snow_1h = "1h"
        case snow_3h = "3h"
    }
    
    let snow_1h: Double?  // snow volume last 1 hr in mm
    let snow_3h: Double?  // last 3 hr
}
struct Sys: Codable {
    let type: Int
    let id: Int
    let country: String // country code
    let sunrise: Int // UTC
    let sunset: Int // UTC
}

// MARK: - Pollution Data
struct PollutionData: Codable {
    let coord: Coord
    let list: [PollutionListItems]
}
struct PollutionListItems: Codable {
    let main: PollutionMain
    let components: Components
    let dt:Int // UTC
}
struct PollutionMain: Codable {
    let aqi: Int
}
struct Components: Codable {
    // results returned in µg/m3
    let co: Double?  // carbom monoxide
    let no: Double? // nitrogen monixide
    let no2: Double?  // nitrogen dioxide
    let o3: Double?  // ozone
    let so2: Double?  // sulphur dioxide
    let pm2_5: Double?  // fine particles matter
    let pm10: Double?  // coarse particulate matter
    let nh3: Double?  // ammonia
}

// MARK: Forecast Data
struct ForecastData: Codable {
    let cod: String  // internal parameter
    let message: Int  // internal parameter
    let cnt: Int  // number of timestamps returned in response
    let list: [ForecastList] // Array of forecast weather items
    let city: City
}
struct ForecastList: Codable {
    let dt: Int  // unix, UTC
    let main: ForecastMain
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let rain: Rain?
    let snow: Snow?
    let sys: ForecastSys
    let dt_text: String?
}

struct ForecastMain: Codable {
    let temp: Double
    let feels_like: Int?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Int
    let sea_level: Int?
    let grnd_level: Int?
    let humidity: Int
    let tmp_kf: Int? // internal parameter
}
struct ForecastSys: Codable {
    let pod: String
}
struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord
    let country: String?
    let population: Int
    let timezone: Double
    let sunrise: Double
    let sunset: Double
}


