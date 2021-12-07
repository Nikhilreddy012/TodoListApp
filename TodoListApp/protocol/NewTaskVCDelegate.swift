//
//  TasksVCDelegate.swift
//  TodoListApp
//
//  Created by student on 11/21/21.
//

import Foundation

protocol NewTaskVCDelegate: class {
    func didAddTask(_ task: Task)
    func didEditTask(_ task: Task)
}
