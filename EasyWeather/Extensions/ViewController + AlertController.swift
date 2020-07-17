//
//  ViewController + AlertController.swift
//  EasyWather
//
//  Created by Данила on 29.05.2020.
//  Copyright © 2020 Данила. All rights reserved.
//
/*
 http://api.openweathermap.org/data/2.5/weather?q=Moscow&apikey=358389cc2e7b7f987ac85f1075b911c6
*/
import CoreLocation
import UIKit

extension ViewController {
    
    func presentSearchAlertController (withTitle title:String?,
                                       message: String?,
                                       style: UIAlertController.Style,
                                       completionHandler: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        alert.addTextField { (field) in
            field.placeholder = "Name"
            field.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Find", style: .default, handler: { (UIAlertAction) in
                    let cityName = alert.textFields?.first?.text ?? "Krasnodar"
                    
                    if cityName != "" {
        //            self.networkWatherManager.fetchCurrentWeather(forCity: cityName)
                        let city = cityName.split(separator: " ").joined(separator: "%20")
                        completionHandler(city)
                    }
                    
                }))
        
        present(alert, animated: true, completion:nil)
    }
}
