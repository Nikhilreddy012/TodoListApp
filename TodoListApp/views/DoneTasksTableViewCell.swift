//
//  DoneTasksTableViewCell.swift
//  TodoListApp
//
//  Created by student on 12/5/21.
//

import UIKit

class DoneTasksTableViewCell: UITableViewCell {
    
    var actionButtonDidTap: (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with task: Task) {
        titleLabel.text = task.title
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        actionButtonDidTap?()
    }
}
