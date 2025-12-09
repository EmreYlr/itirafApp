//
//  OnboardingViewModel.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

protocol OnboardingViewModelProtocol {
    var delegate: OnboardingViewModelDelegate? { get set }
}

protocol OnboardingViewModelDelegate: AnyObject {
    func didCompleteOnboarding()
    func didError(_ error: Error)
}

final class OnboardingViewModel {
    weak var delegate: OnboardingViewModelDelegate?
}

extension OnboardingViewModel: OnboardingViewModelProtocol { }
