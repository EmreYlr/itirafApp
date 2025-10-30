//
//  EditConfessionViewModel.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

protocol EditConfessionViewModelProtocol {
    var delegate: EditConfessionViewModelDelegate? { get set }
    var myConfession: MyConfessionData { get }
    func editConfession(title: String, message: String) async
}
protocol EditConfessionViewModelDelegate: AnyObject {
    func didUpdateConfession()
    func didError(error: Error)
}

@MainActor
final class EditConfessionViewModel {
    weak var delegate: EditConfessionViewModelDelegate?
    var myConfession: MyConfessionData
    let editConfessionService: EditConfessionServiceProtocol
    
    init(myConfession: MyConfessionData, editConfessionService: EditConfessionServiceProtocol = EditConfessionService()) {
        self.myConfession = myConfession
        self.editConfessionService = editConfessionService
    }
    
    func editConfession(title: String, message: String) async {
        var tempMyConfession = self.myConfession
        tempMyConfession.title = title
        tempMyConfession.message = message
        
        do {
            try await editConfessionService.editConfession(myConfession: tempMyConfession)
            delegate?.didUpdateConfession()
        } catch {
            delegate?.didError(error: error)
        }
    }
    
}

extension EditConfessionViewModel: @preconcurrency EditConfessionViewModelProtocol { }
