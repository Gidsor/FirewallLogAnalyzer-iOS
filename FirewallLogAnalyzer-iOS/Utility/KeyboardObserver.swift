//
//  KeyboardObserver.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 21/04/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

enum KeyboardObserverNotification {
    
    case show
    
    case hide
    
    case change
}

protocol KeyboardObserver {
    
    var constraintsToAdjust: [NSLayoutConstraint] { get }
    var constantForDefault: CGFloat { get }
    
    func addKeyboardObservers(observers: [KeyboardObserverNotification])
    func removeKeyboardObservers(observers: [KeyboardObserverNotification])
    
    func keyboard(observer: KeyboardObserverNotification, didChange notification: Notification)
    func keyboard(observer: KeyboardObserverNotification, didChange frame: CGRect, with duration: Double)
}

extension KeyboardObserver where Self: UIViewController {
    
    var constraintsToAdjust: [NSLayoutConstraint] { return [] }
    var constantForDefault: CGFloat { return 0 }
    
    func addKeyboardObservers(observers: [KeyboardObserverNotification] = [.show, .hide, .change]) {
        
        if observers.contains(.show) {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
                self?.keyboardNotification(observer: .show, notification: notification)
            }
        }
        
        if observers.contains(.hide) {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
                self?.keyboardNotification(observer: .hide, notification: notification)
            }
        }
        
        if observers.contains(.change) {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
                self?.keyboardNotification(observer: .change, notification: notification)
            }
        }
    }
    
    func removeKeyboardObservers(observers: [KeyboardObserverNotification] = [.show, .hide, .change]) {
        
        if observers.contains(.show) {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        
        if observers.contains(.hide) {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        if observers.contains(.change) {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    func keyboard(observer: KeyboardObserverNotification, didChange notification: Notification) { }
    func keyboard(observer: KeyboardObserverNotification, didChange frame: CGRect, with duration: Double) { }
    
    private func keyboardNotification(observer: KeyboardObserverNotification, notification: Notification) {
        keyboard(observer: observer, didChange: notification)
        
        if let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            keyboard(observer: observer, didChange: keyboardFrame, with: duration)
            
            if constraintsToAdjust.count > 0 {
                let isKeyboardWillHideNotification = observer == .hide
                constraintsToAdjust.forEach { $0.constant = isKeyboardWillHideNotification ? constantForDefault : keyboardFrame.height }
                
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

