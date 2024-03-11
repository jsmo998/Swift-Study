//
//  ContentView.swift
//  MetUCD
//
//  Created by Judith Smolenski on 17/11/2023.
//

import SwiftUI

// MARK: - Main View

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel

    @State private var locationInput: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        TextField("Enter location e.g. Dublin, IE", text: $locationInput)
                            .keyboardType(.default)
                            .onSubmit() {
                                Task {
                                    do {
                                        try await viewModel.fetchData(for: locationInput)
                                    } catch {
                                        viewModel.alertMessage = "An Error occurred: \(error.localizedDescription)"
                                        viewModel.showAlert = true
                                    }
                                }
                            }
                        Button(action: { clearSearch() }) {
                            Image(systemName: "xmark.circle").foregroundColor(.gray)
                        }
                    }
                } header: { Text("Search").foregroundColor(Color.blue) }
                
                if let geoInfo = viewModel.geoInfo {
                    GeoInfoView(name: geoInfo.name,
                                country: geoInfo.country,
                                lat: geoInfo.lat,
                                lon: geoInfo.lon,
                                sunrise: 23,
                                sunset: 24)
                }
                
                if let weatherInfo = viewModel.weatherInfo {
                    WeatherInfoView(weatherText: weatherInfo.weatherText,
                        temp: weatherInfo.temp,
                                    feelsLike: weatherInfo.feelsLike,
                                    clouds: weatherInfo.clouds,
                                    windSpeed: weatherInfo.windSpeed,
                                    windDirection: weatherInfo.windDirection,
                                    humidity: weatherInfo.humidity,
                                    pressure: weatherInfo.pressure,
                                    sunrise: weatherInfo.sunrise,
                                    sunset: weatherInfo.sunset)
                }
                
                if let pollutionInfo = viewModel.pollutionInfo {
                    PollutionInfoView(co: pollutionInfo.co,
                                      no: pollutionInfo.no,
                                      no2: pollutionInfo.no2,
                                      o3: pollutionInfo.o3,
                                      nh3: pollutionInfo.nh3,
                                      pm10: pollutionInfo.pm10,
                                      pm2_5: pollutionInfo.pm2_5,
                                      so2: pollutionInfo.so2,
                                      aqi: pollutionInfo.aqi!)
                }
                
                if let forecastInfo = viewModel.forecastInfo {
                    ForecastInfoView(temp: forecastInfo.temp, pod: forecastInfo.message, icon: forecastInfo.icon)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    private func clearSearch() {
        locationInput = ""
    }
}
// MARK: - attach SFSymbols to data
struct SymbolStackView: View {
    // create image stacks for text
    var imageName: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.blue)
            Text(text)
        }
    }
}
// MARK: - GeoInfoView
struct GeoInfoView: View {
    var name: String
    var country: String
    var lat, lon: Double
    var sunrise: Int
    var sunset: Int
    
    var body: some View {
        Section {
            SymbolStackView(imageName: "globe", text: country)
            SymbolStackView(imageName: "location", text: "\(lat)°N, \(lon)°W")
            
            HStack {
                SymbolStackView(imageName: "sunrise", text: "\(sunrise)")
                SymbolStackView(imageName: "sunset", text: "\(sunset)")
            }
        } header: { Text("Geo Info").foregroundStyle(.gray) }
    }
}
// MARK: - WeatherInfoView
struct WeatherInfoView: View {
    var weatherText: String
    var temp: String
    var feelsLike: String?
    var clouds: String?
    var windSpeed: Double
    var windDirection: Double
    var snow: String?
    var humidity: String
    var pressure: String
    
    public var sunrise: Int
    public var sunset: Int
    
    var body: some View {
        Section {
            HStack {
                SymbolStackView(imageName: "thermometer.medium", text: temp+"°C")
                SymbolStackView(imageName: "thermometer.variable.and.figure", text: feelsLike ?? "N/A")
            }
            if let clouds = clouds {
                SymbolStackView(imageName: "cloud", text: clouds + "% coverage")
            } else {
                SymbolStackView(imageName: "cloud", text: "N/A")
            }
            SymbolStackView(imageName: "wind", text: "\(windSpeed) km/h, dir: \(windDirection)°")
            HStack {
                SymbolStackView(imageName: "humidity", text: humidity+" %")
                SymbolStackView(imageName: "gauge.with.dots.needle.bottom.50percent", text: pressure+" hPa")
            }
        } header: {
            Text("Weather: \(self.weatherText)").foregroundStyle(.gray)
        }
    }
}
// MARK: - PollutionInfoView
struct PollutionInfoView: View {
    var co: String?
    var no: String?
    var no2: String?
    var o3: String?
    var nh3: String?
    var pm10: String?
    var pm2_5: String?
    var so2: String?
    var aqi: String
    
    enum QualityIndex: String {
        case good = "Good"
        case fair = "Fair"
        case moderate = "Moderate"
        case poor = "Poor"
        case veryPoor = "Very Poor"
    }
    private func airQuality(_ aqiValue: String) -> QualityIndex? {
        switch aqiValue {
        case "1": return .good
        case "2": return .fair
        case "3": return .moderate
        case "4": return .poor
        case "5": return .veryPoor
        default: return nil
        }
    }
    private var aqiQuality: QualityIndex? {
        if let qualityIndex = airQuality(aqi) {
            return qualityIndex
        } else { return nil }
    }
    
    struct TableRow: View {
        var label: String
        var value: String?

        var body: some View {
            HStack {
                Text(label)
                    .foregroundColor(.blue)
                Text(value ?? "N/A")
                    .foregroundColor(.black)
            }
        }
    }
    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    TableRow(label: "CO", value: co)
                    TableRow(label: "NO", value: no)
                    TableRow(label: "NO2", value: no2)
                    TableRow(label: "O3", value: o3)
                    Text("").font(.footnote)
                }
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    TableRow(label: "NH3", value: nh3)
                    TableRow(label: "PM10", value: pm10)
                    TableRow(label: "PM2.5", value: pm2_5)
                    TableRow(label: "SO2", value: so2)
                    Text("(units: µg/m3)")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                Spacer()
                
            }
            
        } header: {
            Text("Air Quality: \(self.aqiQuality?.rawValue ?? "")").foregroundStyle(.gray)
        }
        
    }
}
// MARK: - ForecastInfoView
struct ForecastInfoView: View {
    var temp: Double?
    var pod: Int?
    var icon: String?
    
    var body: some View {
        Section {
            SymbolStackView(imageName: "thermometer", text: "\(temp)")
//            SymbolStackView(imageName: <#T##String#>, text: <#T##String#>)
        } header: { Text("Forecast Data:").foregroundStyle(.gray) }
    }
}

// MARK: - Preview
#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
