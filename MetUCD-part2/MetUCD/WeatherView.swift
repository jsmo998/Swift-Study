//
//  ContentView.swift
//  MetUCD
//
//  Created by Judith Smolenski on 17/11/2023.
//

import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D {
    static var testLocation = CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603)
}
// MARK: - Home Screen View
struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var userLocation: CLLocation?
    
    @State private var showSearchView = false
    @State public var searchedFor = false
    @State private var panelViewTapped = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map()
                .onAppear {
                    setLocation()
                }
                .onTapGesture(coordinateSpace: .local) { location in
                    print("map tapped at location: \(location)")
                }
                .onTapGesture {
                    panelViewTapped.toggle()
                    showSearchView.toggle()
                }
            if panelViewTapped {
                ContentView(viewModel: WeatherViewModel())
                    .onTapGesture {
                        panelViewTapped.toggle()
                    }
            }
            if searchedFor {
                PanelView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .onTapGesture {
                        searchedFor.toggle()
                        panelViewTapped.toggle()
                    }
            }
            if showSearchView {
                SearchView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .padding(30)
                    .onSubmit {
                        withAnimation {
                            showSearchView.toggle()
                            searchedFor.toggle()
                        }
                    }
            } else {
                HStack {
                    Button(action: { setLocation() } ) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 50))
                            .padding(25)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Button(action: { withAnimation {
                        showSearchView.toggle()}}) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 50))
                            .padding(25)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    private func setLocation() {
    }
}
// MARK: - Panel View
struct PanelView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .padding(50)
                .foregroundStyle(Color.white.opacity(0.8))
            VStack {
                Text("Location Name")
                    .font(.system(size: 20))
                HStack{
                    Image(systemName: "thermometer")
                        .foregroundStyle(Color.blue)
                        .font(.system(size: 40))
                    Text("Temp °")
                        .foregroundStyle(.blue)
                        .font(.system(size: 30))
                }
                Text("Description")
                Text("Low and High")
                    .foregroundStyle(.gray)
            }
        }
    }
}
// MARK: - Search Bar View
struct SearchView: View {
    @ObservedObject var viewModel = WeatherViewModel()
    @State private var locationInput: String = ""
    
    var body: some View {
            TextField("Enter location e.g. Dublin, IE", text: $locationInput)
                .keyboardType(.default)
                .onSubmit {
                    Task {
                        do {
                            try await viewModel.fetchData(location: locationInput)
                        } catch {
                            viewModel.alertMessage = "An Error occurred: \(error.localizedDescription)"
                            viewModel.showAlert = true
                        }
                    }
                }
                .padding(15)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
    }
}

// MARK: - Main Content View

struct ContentView: View {
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
                                        try await viewModel.fetchData(location: locationInput)
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
                } else {
                    Text("No Geo Info")
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
                } else {
                    Text("No Weather Info")
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
                } else {
                    Text("No Pollution Info")
                }
                
                if let forecastInfo = viewModel.forecastInfo {
                    ForecastInfoView(testData: "\(forecastInfo.message)")
                } else {
                    Text("No Forecast Info")
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
//                Spacer()
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
    var testData: String
    var body: some View {
        Section {
            Text("Forecast Data recieved: \(testData)")
        } header: { Text("Forecast Data:").foregroundStyle(.gray) }
    }
}

// MARK: - Preview
#Preview {
        WeatherView(viewModel: WeatherViewModel())
//    CardContent(viewModel: WeatherViewModel())
//    ContentView(viewModel: WeatherViewModel())
}
