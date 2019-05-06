//
//  UIViewController+ActivityIndicator.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showActivityIndicator(in view: UIView, style: UIActivityIndicatorView.Style = .whiteLarge, color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7500642123), belowSubview: UIView? = nil) {
        
        if !view.subviews.contains(where: {$0 is UIActivityIndicatorView }) {
            view.endEditing(true)
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.style = style
            activityIndicator.backgroundColor = backgroundColor
            activityIndicator.color = color
            activityIndicator.alpha = 0
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            if let belowSubview = belowSubview {
                view.insertSubview(activityIndicator, belowSubview: belowSubview)
            } else {
                view.addSubview(activityIndicator)
            }
            
            NSLayoutConstraint.activate([
                activityIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            
            UIView.animate(withDuration: 0.3, animations: {
                activityIndicator.alpha = 1
            })
        }
    }
    
    func hideActivityIndicator(in view: UIView, withAnimation: Bool = true) {
        if let activityIndicator = view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            if withAnimation {
                UIView.animate(withDuration: 0.3, animations: {
                    activityIndicator.alpha = 0
                }) { (result) in
                    activityIndicator.removeFromSuperview()
                }
            } else {
                activityIndicator.removeFromSuperview()
            }
        }
    }
}

extension UIView {
    
    func showActivityIndicator(style: UIActivityIndicatorView.Style = .whiteLarge, color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7500642123), belowSubview: UIView? = nil) {
        
        if !subviews.contains(where: {$0 is UIActivityIndicatorView }) {
            endEditing(true)
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.style = style
            activityIndicator.backgroundColor = backgroundColor
            activityIndicator.color = color
            activityIndicator.alpha = 0
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            if let belowSubview = belowSubview {
                insertSubview(activityIndicator, belowSubview: belowSubview)
            } else {
                addSubview(activityIndicator)
            }
            
            NSLayoutConstraint.activate([
                activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
                ])
            
            UIView.animate(withDuration: 0.3, animations: {
                activityIndicator.alpha = 1
            })
        }
    }
    
    func hideActivityIndicator(withAnimation: Bool = true) {
        if let activityIndicator = subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            if withAnimation {
                UIView.animate(withDuration: 0.3, animations: {
                    activityIndicator.alpha = 0
                }) { (result) in
                    activityIndicator.removeFromSuperview()
                }
            } else {
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
