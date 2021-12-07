//
//  Animatable.swift
//  TodoListApp
//
//  Created by student on 12/5/21.
//

import Foundation
import Loaf

protocol Animatable {
    
}

extension Animatable where Self: UIViewController {
    func showToast(state: Loaf.State, message: String, location: Loaf.Location = .top, duration: TimeInterval = 1.0) {
        DispatchQueue.main.async {
            Loaf(message,
                 state: state,
                 location: location,
                 sender: self)
                .show(.custom(duration))
        }
    }
}
