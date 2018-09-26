//
//  ProgressRingView.swift
//  LIProgressRing
//
//  Created by ivan lares on 9/25/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit

public class ProgressRingView: UIView {
    
    // MARK: Private Properties
    
    private let progressRing: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        return layer
    }()
    
    private let backgroundRing: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        return layer
    }()
    
    /// container view in the center of the rings
    /// use this to add custom subviews like labels and image views
    ///
    /// Tip: You can use the `constrainViewToCenter` method to add custom subviews
    public let centerContainerView: UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var radius: CGFloat {
        
        let minLength = min(frame.height, frame.width)
        let radius = (minLength - strokeWidth)/2
        return radius
    }
    
    private var centerContainerHeightConstraint: NSLayoutConstraint?
    private var centerContainerWidthConstraint: NSLayoutConstraint?
    private var centerContainerCenterXConstraint: NSLayoutConstraint?
    private var centerContainerCenterYConstraint: NSLayoutConstraint?
    
    // MARK: Public properties
    
    public var strokeWidth: CGFloat = 20 {
        
        didSet {
            self.positionRings()
        }
    }
    
    public var strokeEnd: CGFloat {
        
        set {
            
            progressRing.strokeEnd = newValue
        }
        
        get {
            
            return progressRing.strokeEnd
        }
    }
    
    public var ringColor: UIColor = Pallet.defaultStrokeColor {
        
        didSet {
            
            progressRing.strokeColor = ringColor.cgColor
        }
    }
    
    public var backgroundRingColor: UIColor = Pallet.defaultBackgroundStrokeColor {
        
        didSet {
            
            backgroundRing.strokeColor = backgroundRingColor.cgColor
        }
    }
    
    public var clockwise: Bool = true {
        
        didSet {
            
            positionRings()
        }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        strokeEnd = 0
        // style layers
        styleRing(layer: backgroundRing, strokeColor: backgroundRingColor, fillColor: .clear)
        styleRing(layer: progressRing, strokeColor: ringColor, fillColor: .clear)
        // add layers
        layer.addSublayer(backgroundRing)
        layer.addSublayer(progressRing)
        addSubview(centerContainerView)
    }
    
    // MARK: Layout
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        positionRings()
        postionCenterView()
    }
    
    private func positionRings() {
        
        positionRing(layer: backgroundRing)
        positionRing(layer: progressRing)
    }
    
    // MARK: - User Interface
    
    private func positionRing(layer: CAShapeLayer) {
        
        layer.lineWidth = strokeWidth
        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: (3*CGFloat.pi)/2, endAngle: ((3*CGFloat.pi)/2) + 2*CGFloat.pi, clockwise: clockwise)
        layer.path = circularPath.cgPath
        layer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    private func postionCenterView() {
        
        // radius from self.center to the inner stroke end
        let adjustedRadius = (radius - strokeWidth/2)
        let containerLength = (adjustedRadius*adjustedRadius*2).squareRoot()
        
        initializeCenterContainerConstraintsIfNeeded()
        
        [centerContainerHeightConstraint, centerContainerWidthConstraint].forEach({
            $0?.constant = containerLength
        })
    }
    
    private func initializeCenterContainerConstraintsIfNeeded() {
        
        guard let _ = centerContainerWidthConstraint,
            let _ = centerContainerHeightConstraint,
            let _ = centerContainerCenterXConstraint,
            let _ = centerContainerCenterYConstraint else {
                
                centerContainerCenterYConstraint = centerContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
                centerContainerCenterXConstraint = centerContainerView.centerXAnchor.constraint(equalTo: centerXAnchor)
                centerContainerHeightConstraint = centerContainerView.heightAnchor.constraint(equalToConstant: 0)
                centerContainerWidthConstraint = centerContainerView.widthAnchor.constraint(equalToConstant: 0)
                [centerContainerCenterYConstraint, centerContainerCenterXConstraint, centerContainerHeightConstraint, centerContainerWidthConstraint].forEach({
                    $0?.isActive = true
                })
                return
        }
    }
    
    private func styleRing(layer: CAShapeLayer, strokeColor: UIColor, fillColor: UIColor){
        
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = self.center
    }
    
    // MARK: - Public Methods
    
    /// Animates the progress ring
    ///
    /// - Parameters:
    ///   - toValue: end value must be between 0-1
    ///   - fromValue: start value must be between 0-1.
    ///   - duration: animation duration
    ///   - fillMode:  the default is kCAFillModeRemoved
    ///   - animationDelegate: Default is nil, use this value to get notified
    public func animate(toValue: CGFloat?, fromValue: CGFloat?, duration: CFTimeInterval, fillMode: String?, animationDelegate: CAAnimationDelegate? = nil) {
        
        let basicAnimation = CABasicAnimation(keyPath: Constants.strokeEndKey)
        basicAnimation.fromValue = fromValue
        basicAnimation.toValue = toValue
        basicAnimation.duration = duration
        if let fillMode = fillMode {
            
            basicAnimation.fillMode = fillMode
        }
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.delegate = animationDelegate
        progressRing.add(basicAnimation, forKey: Constants.progressRingStrokeAnimationKey)
    }
    
    /// Constrains and adds the subview to the center of the rings.
    ///
    /// Note: This method will automatically add the subview as a child.
    ///
    /// - Parameter centerSubview: view to constrain
    public func constrainViewToCenter(_ centerSubview: UIView) {
        
        centerSubview.translatesAutoresizingMaskIntoConstraints = false
        centerContainerView.addSubview(centerSubview)
        // constrainsts
        centerSubview.leftAnchor.constraint(equalTo: centerContainerView.leftAnchor).isActive = true
        centerContainerView.rightAnchor.constraint(equalTo: centerSubview.rightAnchor).isActive = true
        centerSubview.topAnchor.constraint(equalTo: centerContainerView.topAnchor).isActive = true
        centerContainerView.bottomAnchor.constraint(equalTo: centerSubview.bottomAnchor).isActive = true 
    }
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let progressRingStrokeAnimationKey = "strokeAnimationProgressRingKey"
        static let strokeEndKey = "strokeEnd"
    }
    
    enum Pallet {
        
        static let defaultBackgroundStrokeColor =
            UIColor(red:0.29, green:0.74, blue:0.67, alpha:1.0)
        static let defaultStrokeColor =
            UIColor(red:0.99, green:0.29, blue:0.10, alpha:1.0)
        static let defaultTextColor =
            UIColor(red:0.87, green:0.86, blue:0.89, alpha:1.0)
    }
    
}
