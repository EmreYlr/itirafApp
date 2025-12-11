//
//  ReportViewModel.swift
//  itirafApp
//
//  Created by Emre on 11.12.2025.
//

protocol ReportViewModelProtocol {
    var delegate: ReportViewModelDelegate? { get set }
    func getContentCharrecterCount() -> Int
    func submitReport(reason: String) async
}

protocol ReportViewModelDelegate: AnyObject {
    func didSubmitReport()
    func didFailWithError(_ error: Error)
}

final class ReportViewModel {
    weak var delegate: ReportViewModelDelegate?
    let service: ReportServiceProtocol
    private let maxContentCharacterCount = 500
    private let target: ReportTarget
    
    init(service: ReportServiceProtocol = ReportService(), target: ReportTarget) {
        self.service = service
        self.target = target
    }
    
    func submitReport(reason: String) async {
        do {
            switch target {
            case .confession(let messageId):
                try await service.reportConfession(messageId: messageId, reason: reason)
                
            case .room(let roomId):
                try await service.reportRoom(roomId: roomId, reason: reason)
                
            case .comment(let replyId):
                try await service.reportReply(replyId: replyId, reason: reason)
            }
            
            self.delegate?.didSubmitReport()
            
        } catch {
            self.delegate?.didFailWithError(error)
        }
    }
    
    func getContentCharrecterCount() -> Int {
        return maxContentCharacterCount
    }
}

extension ReportViewModel: ReportViewModelProtocol { }

