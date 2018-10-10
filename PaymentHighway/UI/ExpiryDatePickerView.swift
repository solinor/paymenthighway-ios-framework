//
//  DateExpiryPicker.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 25/09/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import UIKit

private let numberOfYears = 15

class ExpiryDatePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var months: [Int] = []
    private var years: [Int] = []
    private var currentMonth = Calendar.current.component(.month, from: Date())
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        notify()
    }
    
    private func initialize() {
        self.months = (1...12).map { $0 }
        let currentYear = Calendar.current.component(.year, from: Date())
        self.years = (0..<numberOfYears).map { $0+currentYear }
        
        self.delegate = self
        self.dataSource = self
        selectCurrentMonth()
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return months.count
        case 1: return years.count
        default: return 0
        }
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(months[row])"
        case 1: return "\(years[row])"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.selectedRow(inComponent: 1) == 0 && self.selectedRow(inComponent: 0)+1 < currentMonth {
            selectCurrentMonth()
        }
        notify()
    }
    
    private func selectCurrentMonth() {
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        self.selectRow(0, inComponent: 1, animated: false)
    }
    
    private func notify() {
        let month = self.selectedRow(inComponent: 0)+1
        let year = years[self.selectedRow(inComponent: 1)]
        onDateSelected?(month, year)
    }
}