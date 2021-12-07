//
//  ViewController.swift
//  TodoListApp
//
//  Created by student on 11/8/21.
//

import UIKit

class ListViewController: UIViewController, Animatable {

    @IBOutlet weak var menuSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TodoContainerView: UIView!
    @IBOutlet weak var DoneContainerView: UIView!
    
    private let databaseManager = DatabaseManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        TodoContainerView.isHidden = false
        DoneContainerView.isHidden = true
    }
    
    private func setupSegmentedControl(){
        menuSegmentedControl.removeAllSegments()
        
        MenuSection.allCases.enumerated().forEach { (index, section) in
            menuSegmentedControl.insertSegment(withTitle: section.rawValue, at: index, animated: false)
        }
            menuSegmentedControl.selectedSegmentIndex = 0
            showContainerView(for: .todo)
        }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            showContainerView(for: .todo)
        case 1:
            showContainerView(for: .done)
        default: break
        }
    }
    
    private func showContainerView(for section: MenuSection){
        switch section {
        case .todo:
            TodoContainerView.isHidden = false
            DoneContainerView.isHidden = true
        case .done:
            TodoContainerView.isHidden = true
            DoneContainerView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewTask",
           let destination = segue.destination as? NewTaskViewController {
            destination.delegate = self
        } else if segue.identifier == "showTodoTasks" {
            let destination = segue.destination as? TodoTableViewController
            destination?.delegate = self
        } else if segue.identifier == "showEditTask", let destination = segue.destination as? NewTaskViewController, let tasktoEdit = sender as? Task {
            destination.delegate = self
            destination.taskToEdit = tasktoEdit
        }
    }
    
    private func deleteTask(id: String) {
        databaseManager.deleteTask(id: id) { [weak self](result) in
            switch result {
            case .success:
                self?.showToast(state: .success, message: "Task deleted successfully")
            case .failure(let error):
                self?.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    
    private func editTask(task:Task){
        performSegue(withIdentifier: "showEditTask", sender: task)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton){
        performSegue(withIdentifier: "showNewTask", sender: nil)
    }

}

extension ListViewController: TodoTasksTVCDelegate {
     func showOptions(for task: Task) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {[unowned self] _ in
            guard let id = task.id else {return}
            self.deleteTask(id: id)
        }
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { [unowned self] _ in
            self.editTask(task: task)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        present(alertController, animated: true, completion: nil)

    }
}

extension ListViewController: NewTaskVCDelegate {
    func didEditTask(_ task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {
            guard let id = task.id else {return}
            self.databaseManager.editTask(id: id, title: task.title, deadline: task.deadline) { [weak self] (result) in
                switch result {
                case .success:
                    self?.showToast(state: .success, message: "Task updated succesfully")
                case .failure(let error):
                    self?.showToast(state: .error, message: error.localizedDescription)
                }
            }
        })
    }
    
    func didAddTask(_ task: Task) {
        
        presentedViewController?.dismiss(animated: true, completion: { [unowned self] in
            self.databaseManager.addTask(task) { [weak self] (result) in
                switch result {
                case .success: break
                case .failure(let error):
                    self?.showToast(state: .error, message: error.localizedDescription)
                }
            }
        })

    }
}

