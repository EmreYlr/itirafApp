//
//  APIError+Extension.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

extension APIError: UserFriendlyError {
    var title: String {
        return "Sunucu Uyarısı"
    }
}
//
//extension APIError: UserFriendlyError {
//
//    // 1. Başlığı koda göre özelleştiriyoruz
//    var title: String {
//        switch code {
//        case 400:
//            return "Hatalı İstek"
//        case 401:
//            return "Oturum Hatası"
//        case 403:
//            return "Erişim Engellendi"
//        case 404:
//            return "Bulunamadı"
//        case 422:
//            return "Bilgiler Geçersiz"
//        case 429:
//            return "Çok Fazla Deneme"
//        case 500...599:
//            return "Sunucu Hatası"
//        default:
//            // Tanımlamadığımız diğer durumlarda server'dan gelen 'type'ı
//            // ya da genel bir başlığı kullanabiliriz.
//            return "Hata (\(code))"
//        }
//    }
//
//    // 2. Mesajı koda göre özelleştiriyoruz
//    var message: String {
//        switch code {
//
//        case 401:
//            return "Lütfen tekrar giriş yapınız."
//
//        case 403:
//            return "Bu işlemi gerçekleştirmek için yetkiniz bulunmuyor."
//
//        case 404:
//            return "Aradığınız veriye şu an ulaşılamıyor veya silinmiş."
//
//        case 500...599:
//            // Server 500 attığında genelde teknik mesaj döner, onu kullanıcıya gösterme!
//            return "Sunucularımızda geçici bir çalışma var. Lütfen daha sonra tekrar deneyin."
//
//        case 429:
//            return "Çok hızlı işlem yapıyorsunuz. Lütfen biraz bekleyin."
//
//        default:
//            // DİKKAT: 400, 422 gibi validation hatalarında genelde
//            // Backend "Şifre eksik" gibi doğru mesajı döner.
//            // O yüzden default durumda server'dan gelen mesajı olduğu gibi basıyoruz.
//            return self.message
//        }
//    }
//}
