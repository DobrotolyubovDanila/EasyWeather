//
//  PastWeather+CoreDataProperties.swift
//  EasyWeather
//
//  Created by Данила on 02.06.2020.
//  Copyright © 2020 Данила. All rights reserved.
//
//

import Foundation
import CoreData


extension PastWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PastWeather> {
        return NSFetchRequest<PastWeather>(entityName: "PastWeather")
    }

    @NSManaged public var temperature: Int16
    @NSManaged public var feelsLike: Int16
    @NSManaged public var date: Date?
    @NSManaged public var city: String?
    @NSManaged public var conditionCode: Int16

}
