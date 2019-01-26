//
//  DateRangeTests.swift
//  EmonCMSiOSTests
//
//  Created by Matt Galloway on 23/01/2019.
//  Copyright © 2019 Matt Galloway. All rights reserved.
//

import Quick
import Nimble
@testable import EmonCMSiOS

class DateRangeTests: QuickSpec {

  override func spec() {

    beforeEach {
    }

    describe("calculateDates") {
      it("should calculate -1 hour") {
        let relativeTimestamp = 475372800.0
        let range = DateRange.relative(.hour1)
        let calculatedRange = range.calculateDates(relativeTo: Date(timeIntervalSince1970: relativeTimestamp))
        expect(calculatedRange.0.timeIntervalSince1970).to(equal(475369200.0))
        expect(calculatedRange.1.timeIntervalSince1970).to(equal(relativeTimestamp))
      }

      it("should calculate -8 hour") {
        let relativeTimestamp = 475372800.0
        let range = DateRange.relative(.hour8)
        let calculatedRange = range.calculateDates(relativeTo: Date(timeIntervalSince1970: relativeTimestamp))
        expect(calculatedRange.0.timeIntervalSince1970).to(equal(475344000.0))
        expect(calculatedRange.1.timeIntervalSince1970).to(equal(relativeTimestamp))
      }

      it("should calculate -1 day") {
        let relativeTimestamp = 475372800.0
        let range = DateRange.relative(.day)
        let calculatedRange = range.calculateDates(relativeTo: Date(timeIntervalSince1970: relativeTimestamp))
        expect(calculatedRange.0.timeIntervalSince1970).to(equal(475286400.0))
        expect(calculatedRange.1.timeIntervalSince1970).to(equal(relativeTimestamp))
      }

      it("should calculate -1 month") {
        let relativeTimestamp = 475372800.0
        let range = DateRange.relative(.month)
        let calculatedRange = range.calculateDates(relativeTo: Date(timeIntervalSince1970: relativeTimestamp))
        expect(calculatedRange.0.timeIntervalSince1970).to(equal(472694400.0))
        expect(calculatedRange.1.timeIntervalSince1970).to(equal(relativeTimestamp))
      }

      it("should calculate -1 year") {
        let relativeTimestamp = 475372800.0
        let range = DateRange.relative(.year)
        let calculatedRange = range.calculateDates(relativeTo: Date(timeIntervalSince1970: relativeTimestamp))
        expect(calculatedRange.0.timeIntervalSince1970).to(equal(443750400.0))
        expect(calculatedRange.1.timeIntervalSince1970).to(equal(relativeTimestamp))
      }

      it("should calculate absolute dates") {
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 2000)
        let range = DateRange.absolute(date1, date2)
        let calculatedRange = range.calculateDates()
        expect(calculatedRange.0).to(equal(date1))
        expect(calculatedRange.1).to(equal(date2))
      }
    }

  }

}