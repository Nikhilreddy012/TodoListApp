//
//  TodoTableViewController.swift
//  TodoListApp
//
//  Created by student on 11/8/21.
//

import UIKit
import Loaf

protocol TodoTasksTVCDelegate: AnyObject {
    func showOptions(for task: Task)
}

class TodoTableViewController: UITableViewController, Animatable {
    
    private let databaseManager = DatabaseManager()
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: TodoTasksTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTasksListener()
    }
    
    private func addTasksListener() {
        databaseManager.addTasksListener(forDoneTasks: false){ [weak self] (result) in
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
        databaseManager.updateTaskStatus(id: id, isDone: true) { [weak self] (result) in
            switch result {
            case .success:
                self?.showToast(state: .info, message: "Moved to Done", duration: 1.5)
                case .failure(let error):
                    self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    
}


    
    extension TodoTableViewController {
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TodoTasksTableViewCell
            let task = tasks[indexPath.row]
            cell.actionButtonDidTap = { [weak self] in
                self?.handleActionButton(for: task)
            }
            cell.configure(with: task)
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let task = tasks[indexPath.item]
            delegate?.showOptions(for: task)
        }
        
        
    }
