//
//  OnboardingViewModel.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

protocol OnboardingViewModelProtocol {
    var delegate: OnboardingViewModelDelegate? { get set }
    var numberOfSlides: Int { get }
    func getSlide(at index: Int) -> OnboardingSlide
    func handleNextAction(currentIndex: Int) -> Int?
}

protocol OnboardingViewModelDelegate: AnyObject {
    func didCompleteOnboarding()
}

final class OnboardingViewModel {
    weak var delegate: OnboardingViewModelDelegate?

    private var slides: [OnboardingSlide] = []
    
    init() {
        slides = [
            OnboardingSlide(title: "onboarding_slide1_title".localized, description: "onboarding_slide1_desc".localized, imageName: "onboarding_1_icon"),
            OnboardingSlide(title: "onboarding_slide2_title".localized, description: "onboarding_slide2_desc".localized, imageName: "onboarding_2_icon"),
            OnboardingSlide(title: "onboarding_slide3_title".localized, description: "onboarding_slide3_desc".localized, imageName: "onboarding_3_icon")
        ]
    }
    
    var numberOfSlides: Int {
        return slides.count
    }
    
    func getSlide(at index: Int) -> OnboardingSlide {
        return slides[index]
    }
    
    func handleNextAction(currentIndex: Int) -> Int? {
        if currentIndex == slides.count - 1 {
            delegate?.didCompleteOnboarding()
            return nil
        } else {
            return currentIndex + 1
        }
    }
}

extension OnboardingViewModel: OnboardingViewModelProtocol { }
