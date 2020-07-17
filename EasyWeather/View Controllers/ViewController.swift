//
//  ViewController.swift
//  EasyWather
//
//  Created by Данила on 29.05.2020.
//  Copyright © 2020 Данила. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var cityLabel:UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var context: NSManagedObjectContext!
    var pastWeathers: [PastWeather] = []
    
    var networkWeatherManager = NetworkWeatherManager()
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    
    @IBAction func changeButtonPressed() {
        
        self.presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) { [unowned self] (city) in
            self.networkWeatherManager.fetchCurrentWeather(forRequestTyp: .cityName(city: city))
        }
    }
    
    @IBAction func locationButtonPressed() {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestLocation()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkWeatherManager.onCompletion = { [weak self] currentWeather in
            guard let self = self else { return }
            self.updateInterfaceWith(weather: currentWeather)
        }
        
        fetchLastWeathersAndUpdateInterface()
        
        /* if CLLocationManager.locationServicesEnabled() {
         locationManager.requestLocation()
         }*/
    }
    
    
    
    func updateInterfaceWith(weather: CurrentWeather) {
        
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.feelsLikeLabel.text = weather.feelsLikeTemperatureString
            self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            self.dateLabel.text = dateFormatter.string(from: date)
        }
        
        clearHistoryFromContext()
        
        saveCurrentWeather(cityName: weather.cityName, temperature: Int(weather.temperature), feelsLike: Int(weather.feelsLikeTemperature), date: Date(), conditionCode: weather.conditionCode)
        
    }
    
}


// MARK: CLLocatoinManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        networkWeatherManager.fetchCurrentWeather(forRequestTyp: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: CoreData
extension ViewController {
    
    private func fetchLastWeathersAndUpdateInterface() {
        
        let fetchRequest: NSFetchRequest<PastWeather> = PastWeather.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            pastWeathers = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        if pastWeathers.count == 0 { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        guard let date = pastWeathers[0].date else { return }
        
        self.cityLabel.text = pastWeathers[0].city
        self.dateLabel.text = dateFormatter.string(from: date)
        self.feelsLikeLabel.text = "Feels like \(pastWeathers[0].feelsLike)ºC"
        self.temperatureLabel.text = "\(pastWeathers[0].temperature)ºC"
        let cCode = Int(pastWeathers[0].conditionCode)
        self.weatherIconImageView.image = UIImage(systemName: getImageName(fromConditionCode: cCode))
    }
    
    private func saveCurrentWeather(cityName: String,
                                    temperature: Int,
                                    feelsLike: Int,
                                    date: Date,
                                    conditionCode: Int) {
        
        let pastWeather = PastWeather(context: context)
        
        pastWeather.city = cityName
        pastWeather.date = date
        pastWeather.feelsLike = Int16(feelsLike)
        pastWeather.temperature = Int16(temperature)
        pastWeather.conditionCode = Int16(conditionCode)
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func clearHistoryFromContext() {
        for object in pastWeathers {
            context.delete(object)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getImageName(fromConditionCode conditionCode: Int) -> String {
        
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
    
}
