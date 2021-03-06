//
//  Util.swift
//  AWSInspectorDemo
//
//  Created by Nikola Lukic on 6/14/17.
//  Copyright © 2017 Nikola Lukic. All rights reserved.
//

import Foundation

typealias DateTuple = (amazonTimestamp: String, clientDate: String)

class DateFormat {

    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "YMMdd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        timeFormatter.dateFormat = "HHmmss"
        timeFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }

    func formattedTime() -> (amazonTimestamp: String, clientDate: String) {
        let date = Date()

        let clientDate = dateFormatter.string(from: date)
        let amazonTime = timeFormatter.string(from: date)
        let amazonTimestamp = "\(clientDate)T\(amazonTime)Z"

        return (amazonTimestamp: amazonTimestamp, clientDate: clientDate)
    }

}

func nillableDate(for timestamp: Double?) -> Date? {
    guard let date = timestamp else {
        return nil
    }

    return Date(timeIntervalSince1970: date)
}

class MediumDateFormatter {
    private static let formatter = { () -> DateFormatter in 
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    } ()

    static func format(_ date: Date) -> String {
        return formatter.string(from: date)
    }
}
