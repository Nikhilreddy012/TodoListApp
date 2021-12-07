//
//  CalendarViewDelegate.swift
//  TodoListApp
//
//  Created by student on 12/6/21.
//

import Foundation

protocol CalendarViewDelegate: AnyObject {
    func calendarViewDidSelectDate(date: Date)
    func calendarViewDidTapRemoveButton()
}
