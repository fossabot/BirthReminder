//
//  BirthComputing.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 23/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

class BirthComputer {
    // Reorder people based on their birthday.
    static func peopleOrderedByBirthday(peopleToReorder people: [PeopleToSave]) -> [PeopleToSave] {
        return people.sorted { p1, p2 in p1.birth.toDate()! < p2.birth.toDate()! }
    }
    
    fileprivate static func putIntoDate(with monthAndDay: String, year: YearType = .this) -> Date? {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd"
        let date = formmater.date(from: "\(getYear(year))-\(monthAndDay)")
        return date
    }
    
    static func getYear(_ year: YearType) -> Int {
        switch year {
        case .this:
            return Calendar.current.component(.year, from: Date.now)
        case .next:
            return getYear(.this) + 1
        }
    }
    
    enum YearType {
        case this
        case next
    }
}

extension String {
    func toLocalizedDate() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = NSLocalizedString("dateStyle", comment: "Date Style")
        guard let date = toDate() else { return nil }
        return formatter.string(from: date)
    }
    
    func toLeftDays() -> String? {
        guard let date = toDate(),
            let leftDays = date.daysSince(Date.now)
            else { return nil }
        print(NSLocalizedString("%d day(s) left", comment: "There are %d days left till a certain date."))
        switch leftDays {
        case -1, 0:
            return NSLocalizedString("today", comment: "today")
        case 1:
            return NSLocalizedString("tomorrow", comment: "tomorrow")
        case 2:
            return NSLocalizedString("dayAfterTomorrow", comment: "dayAfterTomorrow")
        default:
            return String.localizedStringWithFormat(
                NSLocalizedString("%d day(s) left", comment: "There are %d days left till a certain date."),
                leftDays)
        }
    }

    func toDate() -> Date? {
        func toDate(withYear year: BirthComputer.YearType) -> Date? {
            return BirthComputer.putIntoDate(with: self, year: year)
        }

        guard let date = toDate(withYear: .this) else {
            return nil
        }

        if date < Date.now.yesterday {
            return toDate(withYear: .next)
        } else {
            return date
        }
    }
}

extension Date {
    static var now: Date {
        return Date()
    }

    var tomorrow: Date! {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }

    var yesterday: Date! {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }

    func daysSince(_ start: Date) -> Int! {
        return Calendar.current.dateComponents([.day], from: start, to: self).day
    }
}

extension Array where Element: PeopleToSave {
    mutating func sort() {
        self = BirthComputer.peopleOrderedByBirthday(peopleToReorder: (self as [PeopleToSave])) as! Array
    }
}
