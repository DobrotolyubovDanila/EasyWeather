//
//  CurrentWeather.swift
//  EasyWeather
//
//  Created by Данила on 31.05.2020.
//  Copyright © 2020 Данила. All rights reserved.
//

import Foundation

struct CurrentWeather {
    let cityName: String
    
    let temperature: Double
    var temperatureString: String {
        return "\(Int(temperature))ºC"
    }
    
    let feelsLikeTemperature: Double
    var feelsLikeTemperatureString:String {
        return "Feels like \(Int(feelsLikeTemperature))ºC"
    }
    
    var conditionCode: Int
    
    var systemIconNameString: String {
        switch conditionCode {
        case 200...232:
            return "cloud.bolt.rain"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "smoke"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "exclamationmark.icloud"
        }
    }
    
    init?(currentWeatherData: CurrentWeatherData) {
        cityName = currentWeatherData.name
        temperature = currentWeatherData.main.temp
        feelsLikeTemperature = currentWeatherData.main.feelsLike
        conditionCode = currentWeatherData.weather.first!.id
    }
}
