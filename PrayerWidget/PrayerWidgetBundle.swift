//
//  PrayerWidgetBundle.swift
//  PrayerWidget
//
//  Created by bear on 7/4/25.
//

import WidgetKit
import SwiftUI

@main
struct PrayerWidgetBundle: WidgetBundle {
    var body: some Widget {
        ConfigurablePrayerWidget()
        PrayerWidget()
        WaitPrayerWidget()
        YesPrayerWidget()
        NoPrayerWidget()
    }
}
