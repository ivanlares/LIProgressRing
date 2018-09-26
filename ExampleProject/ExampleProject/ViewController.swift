//
//  ViewController.swift
//  ExampleProject
//
//  Created by ivan lares on 9/25/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit
import LIProgressRing

class ViewController: UIViewController {
    
    let progressRingView: ProgressRingView = {
        
        let view = ProgressRingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    let progressLabel = UILabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        addProgressRing()
        fireTimer()
    }
    
    private func fireTimer() {
        
        var seconds: TimeInterval = 0
        progressLabel.text = "\(Int(seconds))"
        Timer.scheduledTimer(withTimeInterval: Constants.timeInterval, repeats: true, block: {
            timer in
            
            seconds += timer.timeInterval
            self.progressLabel.text = "\(Int(seconds))"
            self.progressRingView.strokeEnd = CGFloat(seconds/Constants.maxSeconds)
            if seconds >= Constants.maxSeconds {
                timer.invalidate()
                // refresh timer
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.fireTimer()
                })
                return
            }
        })
    }
    
    private func configureView() {
        
        view.backgroundColor = .white
        // progress label
        progressLabel.textColor = .lightGray
        progressLabel.font = UIFont.systemFont(ofSize: 28)
        progressLabel.textAlignment = .center
        progressRingView.constrainViewToCenter(progressLabel)
    }
    
    /// constrains and adds progress ring as a subview
    private func addProgressRing() {
        
        view.addSubview(progressRingView)
        progressRingView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        progressRingView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        progressRingView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        progressRingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    enum Constants {
        
        /// length of timer
        static let maxSeconds: TimeInterval = 10
        /// rate at wich timer fires
        static let timeInterval: TimeInterval = 0.05
    }
}
