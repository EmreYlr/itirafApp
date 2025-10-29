//
//  EditConfessionViewModel.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

protocol EditConfessionViewModelProtocol {
    var delegate: EditConfessionViewModelDelegate? { get set }
    var myConfession: MyConfessionData { get }
}
protocol EditConfessionViewModelDelegate: AnyObject {
    func didUpdateConfession()
    func didError(error: Error)
}

final class EditConfessionViewModel {
    weak var delegate: EditConfessionViewModelDelegate?
    var myConfession: MyConfessionData
    
    init(myConfession: MyConfessionData) {
        self.myConfession = myConfession
    }
}

extension EditConfessionViewModel: EditConfessionViewModelProtocol { }
