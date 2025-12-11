//
//  ChatViewModel.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import Foundation
import MessageKit

protocol ChatViewModelProtocol {
    var delegate: ChatViewModelDelegate? { get set }
    var directMessage: DirectMessage? { get set }
    var requestMessage: RequestMessageModel? { get set }
    var roomMessage: RoomMessages? { get }
    var messages: [Message] { get }
    var currentSender: Sender { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func startListening()
    func stopListening()
    func sendMessage(_ text: String)
    func fetchRoomMessages() async
    func approveRequest() async
    func rejectRequest() async
    func blockRoom() async
    func getRoomId() -> String?
}

protocol ChatViewModelDelegate: AnyObject {
    func didUpdateMessages(isPagination: Bool)
    func didApproveRequest()
    func didRejectRequest()
    func didBlockRoom()
    func diderror(_ error: Error)
}

final class ChatViewModel: NSObject {
    weak var delegate: ChatViewModelDelegate?
    var directMessage: DirectMessage?
    var requestMessage: RequestMessageModel?
    var roomMessage: RoomMessages?
    
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    private(set) var messages: [Message] = []
    private(set) var currentSender: Sender
    private var chatService: ChatServiceProtocol!
    private var requestMessageService: RequestMessageServiceProtocol
    private var isConnected = false
    
    init(chatService: ChatServiceProtocol = ChatService(), requestMessageService: RequestMessageServiceProtocol = RequestMessageService()) {
        self.chatService = chatService
        self.requestMessageService = requestMessageService
        self.currentSender = Sender(senderId: UserManager.shared.getUser()?.id ?? "", displayName: "Ben")
        super.init()
        self.chatService.delegate = self
    }
    
    func startListening() {
        guard let roomId = directMessage?.roomID else {
            let error = APIError(code: 4300, type: "MissingInfo")
            delegate?.diderror(error)
            return
        }
        if !isConnected {
            chatService.startChatSession(roomId: roomId)
        } else {
            print("⚠️ Mesaj gönderilemedi, bağlantı yok.")
        }
    }
    
    func stopListening() {
        chatService.endChatSession()
    }
    
    func sendMessage(_ text: String) {
        let newMessage = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(newMessage)
        delegate?.didUpdateMessages(isPagination: false)
        
        chatService.sendMessage(text)
    }
    
    func fetchRoomMessages() async {
        guard let roomID = directMessage?.roomID else {
            delegate?.diderror(APIError(code: 4300, type: "MissingInfo"))
            return
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        let isPaginationRequest = self.roomMessage != nil
        do {
            let newRoomMessages = try await chatService.getRoomMessages(page: currentPage, limit: 20, with: roomID)
            
            if self.roomMessage == nil {
                self.roomMessage = newRoomMessages
            } else {
                self.roomMessage?.data.append(contentsOf: newRoomMessages.data)
            }
            
            convertToMessageKitMessages(from: newRoomMessages.data)
            
            
            hasMoreData = currentPage < newRoomMessages.totalPages
            if hasMoreData { currentPage += 1 }
            
            delegate?.didUpdateMessages(isPagination: isPaginationRequest)
            
        } catch {
            delegate?.diderror(error)
            hasMoreData = false
        }
    }
    
    private func convertToMessageKitMessages(from roomMessages: [MessageData]) {
        let convertedMessages: [Message] = roomMessages.map { msgData in
            let sender: Sender
            
            if msgData.isMyMessage {
                sender = currentSender
            } else {
                sender = Sender(senderId: directMessage?.username ?? "other_user", displayName: directMessage?.username ?? "Karşı Taraf")
            }
            
            let date = Date(isoStringWithFractionalSeconds: msgData.createdAt) ?? Date(timeIntervalSince1970: 0)
            
            return Message(sender: sender, messageId: "\(msgData.id)", sentDate: date, kind: .text(msgData.content))
        }
        
        self.messages.insert(contentsOf: convertedMessages.reversed(), at: 0)
    }
    
    func approveRequest() async {
        guard let request = requestMessage else {
            let error = APIError(code: 1300, type: "ViewModelError")
            delegate?.diderror(error)
            return
        }
        
        do {
            try await requestMessageService.approveRequest(requestID: request.requestID)
            let confirmedRoomID = request.roomID
            self.directMessage = DirectMessage(
                roomID: confirmedRoomID,
                username: request.requesterUsername,
                lastMessage: request.initialMessage,
                lastMessageDate: request.createdAt,
                isLastMessageMine: false,
                status: "active",
                unreadMessageCount: 0
            )
            delegate?.didApproveRequest()
            
        } catch {
            delegate?.diderror(error)
        }
    }
    
    func rejectRequest() async {
        guard let requestID = requestMessage?.requestID else {
            return
        }
        do {
            try await requestMessageService.rejectRequest(requestID: requestID)
            delegate?.didRejectRequest()
        } catch {
            delegate?.diderror(error)
        }
    }
    
    func blockRoom() async {
        guard let roomId = directMessage?.roomID else {
            let error = APIError(code: 4300, type: "MissingInfo")
            delegate?.diderror(error)
            return
        }
        
        do {
            try await chatService.blockRoom(roomId: roomId)
            delegate?.didBlockRoom()
        } catch {
            delegate?.diderror(error)
        }
    }
    
    func getRoomId() -> String? {
        guard let directMessage = directMessage else { return nil }
        return directMessage.roomID
    }
}

extension ChatViewModel: ChatViewModelProtocol { }

extension ChatViewModel: ChatServiceDelegate {
    
    func chatDidConnect() {
        isConnected = true
        print("🟢 ViewModel: Chat oturumu aktif.")
    }
    
    func chatDidDisconnect() {
        isConnected = false
        print("🔴 ViewModel: Chat oturumu kapandı.")
    }
    
    func chatDidReceive(message: String) {
        let otherSender = Sender(senderId: directMessage?.username ?? "other_user", displayName: directMessage?.username ?? "Karşı Taraf")
        let newMessage = Message(sender: otherSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(message))
        messages.append(newMessage)
        delegate?.didUpdateMessages(isPagination: false)
    }
    
    func chatSessionFailed(with error: Error) {
        isConnected = false
        print("❌ ViewModel: Chat oturumu başlatılamadı. Hata: \(error.localizedDescription)")
    }
}
