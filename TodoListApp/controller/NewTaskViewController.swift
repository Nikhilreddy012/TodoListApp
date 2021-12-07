//
//  NewTaskViewController.swift
//  TodoListApp
//
//  Created by student on 11/9/21.
//

import UIKit
import Combine

class NewTaskViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var newTaskTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    private var subscribers = Set<AnyCancellable>()
    var taskToEdit: Task?
    @Published private var taskName: String?
    @Published private var deadline: Date?
    
    weak var delegate: NewTaskVCDelegate?
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        observeForm()
        setupGesture()
        observeKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newTaskTextField.becomeFirstResponder()
    }
    
    private func observeForm(){
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification).map { (notification) -> String? in
            return (notification.object as? UITextField)?.text
        }.sink { [unowned self](text) in
            self.taskName = text
        }.store(in: &subscribers)
        
        $taskName.sink { [unowned self](text) in
            self.saveButton.isEnabled = text?.isEmpty == false
        }.store(in: &subscribers)
        
        $deadline.sink { (date) in
            self.deadlineLabel.text = date?.toString() ?? ""
        }.store(in: &subscribers)
    }
    
    
    private func setupViews(){
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        containerViewBottomConstraint.constant = -containerView.frame.height
        if let taskToEdit  = self.taskToEdit {
            newTaskTextField.text = taskToEdit.title
            taskName = taskToEdit.title
            deadline = taskToEdit.deadline
            saveButton.setTitle("Update", for: .normal)
            calendarView.selectDate(date: taskToEdit.deadline)
        }
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func observeKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = getKeyboardHeight(notification: notification)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {[unowned self] in
            self.containerViewBottomConstraint.constant = keyboardHeight - (200 + 8)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        containerViewBottomConstraint.constant = -containerView.frame.height
    }
    
    private func getKeyboardHeight(notification: Notification) -> CGFloat{
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else{ return 0}
        return keyboardHeight

    }
    
    private func showCalendar() {
        view.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func dismissCalendarView(completion: () -> Void) {
        calendarView.removeFromSuperview()
        completion()
    }
    
    @objc private func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func CalendarButtonClicked(_ sender: Any) {
        newTaskTextField.resignFirstResponder()
        showCalendar()
    }
    @IBAction func SaveButtonClicked(_ sender: Any) {
        guard let taskName = self.taskName else { return }
        var task = Task(title: taskName, deadline: deadline)
        
        if let id = taskToEdit?.id {
            task.id = id
        }
        
        if taskToEdit == nil {
            delegate?.didAddTask(task)
        } else {
            delegate?.didEditTask(task)
        }
    }
}

extension NewTaskViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if calendarView.isDescendant(of: view) {
            if touch.view?.isDescendant(of: calendarView) == false {
                dismissCalendarView { [unowned self] in
                    self.newTaskTextField.becomeFirstResponder()
                }
            }
            return false
        }
        return true
    }
    
}

extension NewTaskViewController: CalendarViewDelegate {
    
    func calendarViewDidSelectDate(date: Date) {
        dismissCalendarView { [unowned self] in
            self.newTaskTextField.becomeFirstResponder()
            self.deadline = date
        }
    }
    
    func calendarViewDidTapRemoveButton() {
        dismissCalendarView {
            self.newTaskTextField.becomeFirstResponder()
            self.deadline = nil
        }
    }
    
    
    
    
}
