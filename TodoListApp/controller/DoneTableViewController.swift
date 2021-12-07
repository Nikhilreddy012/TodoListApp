//
//  DoneTableViewController.swift
//  TodoListApp
//
//  Created by student on 11/8/21.
//

import UIKit

class DoneTableViewController: UITableViewController, Animatable {
    
    private let databaseManager = DatabaseManager()
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTasksListener()
    }
    
    private func addTasksListener() {
        databaseManager.addTasksListener(forDoneTasks: true){ [weak self] (result) in
            switch result {
            case .success(let tasks):
                self?.tasks = tasks
            case .failure(let error):
                self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
        
    }
    
    private func handleActionButton(for task: Task) {
        guard let id = task.id else { return }
        databaseManager.updateTaskStatus(id: id, isDone: false) { [weak self] (result) in
            switch result {
            case .success:
                self?.showToast(state: .info, message: "Moved to Todo", duration: 1.5)
                case .failure(let error):
                    self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
}

extension DoneTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DoneTasksTableViewCell
        let task = tasks[indexPath.item]
        cell.configure(with: task)
        cell.actionButtonDidTap = { [weak self] in self?.handleActionButton(for: task)}
        return cell
    }
    
    
    
}
