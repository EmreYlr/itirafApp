//
//  TermsViewModel.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

protocol TermsViewModelProtocol {
    var terms: [TermsModel] { get }
}

final class TermsViewModel {
    var terms: [TermsModel] = []
    
    init() {
        terms = [
            TermsModel(icon: "person.crop.circle.badge.exclamationmark", title: "terms_privacy_title".localized, content: "terms_privacy_content".localized),
            TermsModel(icon: "building.columns.fill", title: "terms_service_title".localized, content: "terms_service_content".localized),
            TermsModel(icon: "theatermasks.fill", title: "terms_conduct_title".localized, content: "terms_conduct_content".localized)
        ]
    }
}

extension TermsViewModel: TermsViewModelProtocol { }

