//
//  CurrentTime.swift
//  Pointers
//
//  Created by Matheus Garcia on 23/05/18.
//  Copyright © 2018 Matheus Garcia. All rights reserved.
//

import UIKit

class CurrentTime: NSObject {

    var hour: Int
    var minute: Int
    var second: Int

    override init() {

        let date = Date()
        let calendar = Calendar.current

        hour = calendar.component(.hour, from: date)
        hour = hour % 12
        minute = calendar.component(.minute, from: date)
        second = calendar.component(.second, from: date)
    }

    func updateHour() {
        let date = Date()
        let calendar = Calendar.current

        hour = calendar.component(.hour, from: date)
        hour = 10//hour % 12
        minute = 59//calendar.component(.minute, from: date)
        second = 45//calendar.component(.second, from: date)
    }
}
