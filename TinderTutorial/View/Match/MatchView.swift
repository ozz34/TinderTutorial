//
//  MatchView.swift
//  TinderTutorial
//
//  Created by Иван Худяков on 13.03.2023.
//

import UIKit

// MARK: - MatchViewDelegate
protocol MatchViewDelegate: AnyObject {
    func matchView(_ view: MatchView, wantsToSendMessageTo user: User)
}

final class MatchView: UIView {
    // MARK: - Properties
    weak var delegate: MatchViewDelegate?
    
    private let viewModel: MatchViewViewModel
   
    private let matchImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let currentUserImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        
        return iv
    }()
    
    private let matchedUserImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        
        return iv
    }()
    
    private lazy var sendMessageButton: UIButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(didTapSendMessage),
                         for: .touchUpInside)
        
        return button
    }()
    
    private lazy var keepSwipingButton: UIButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(handleDismissal),
                         for: .touchUpInside)
        
        return button
    }()
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    lazy var views = [
        matchImageView,
        descriptionLabel,
        currentUserImageView,
        matchedUserImageView,
        sendMessageButton,
        keepSwipingButton
    ]
    
    // MARK: - Lifecycle
    init(viewModel: MatchViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        loadUserData()
        configureBlurView()
        configureUI()
        configureAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    @objc func didTapSendMessage() {
        delegate?.matchView(self, wantsToSendMessageTo: viewModel.matchedUser)
    }
    
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - Helpers
    private func loadUserData() {
        descriptionLabel.text = viewModel.matchLabelText
        currentUserImageView.sd_setImage(with: viewModel.currentUserImageUrl)
        matchedUserImageView.sd_setImage(with: viewModel.matchedUserImageUrl)
    }
    
    private func configureUI() {
        views.forEach { view in
            addSubview(view)
            view.alpha = 0
        }
        
        currentUserImageView.anchor(right: centerXAnchor, paddingRight: 16)
        currentUserImageView.setDimensions(height: 140, width: 140)
        currentUserImageView.layer.cornerRadius = 140 / 2
        currentUserImageView.centerY(inView: self)
        
        matchedUserImageView.anchor(left: centerXAnchor, paddingLeft: 16)
        matchedUserImageView.setDimensions(height: 140, width: 140)
        matchedUserImageView.layer.cornerRadius = 140 / 2
        matchedUserImageView.centerY(inView: self)
        
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor,
                                 left: leftAnchor,
                                 right: rightAnchor,
                                 paddingTop: 32,
                                 paddingLeft: 48,
                                 paddingRight: 48)
        sendMessageButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor,
                                 left: leftAnchor,
                                 right: rightAnchor,
                                 paddingTop: 32,
                                 paddingLeft: 48,
                                 paddingRight: 48)
        keepSwipingButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        descriptionLabel.anchor(left: leftAnchor,
                                bottom: currentUserImageView.topAnchor,
                                right: rightAnchor,
                                paddingLeft: 16,
                                paddingBottom: 32,
                                paddingRight: 16)
        matchImageView.anchor(bottom: descriptionLabel.topAnchor, paddingBottom: 16)
        matchImageView.centerX(inView: self)
        matchImageView.setDimensions(height: 80, width: 300)
    }
    
    private func configureAnimations() {
        views.forEach { $0.alpha = 1 }
        
        let angle = 30 * CGFloat.pi / 180
        
        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        matchedUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3,
                                delay: 0,
                                options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.matchedUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.matchedUserImageView.transform = .identity
            }
        }
        
        UIView.animate(withDuration: 0.75,
                       delay: 0.6 * 1.3,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut) {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        }
    }
    
    private func configureBlurView() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleDismissal))
        visualEffectView.addGestureRecognizer(tap)
        
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { self.visualEffectView.alpha = 1 },
                       completion: nil)
    }
}
