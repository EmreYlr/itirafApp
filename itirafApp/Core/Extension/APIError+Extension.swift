//
//  APIError+Extension.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

extension APIError: UserFriendlyError {
    var title: String {
        switch code {
        // General
        case 1000...1001, 4000...4001: return "Sunucu Hatası"
        case 1002, 4002: return "Hatalı İstek"
        case 1003, 4003: return "Çok Fazla İstek"
            
        // Validation
        case 1100...1199, 4100...4199: return "Doğrulama Hatası"
            
        // Database
        case 1200, 4200: return "Sunucu Hatası"
        case 1201, 4201: return "Kayıt Mevcut"
            
        // Resource
        case 1300, 4300: return "Bulunamadı"
        case 1301, 4301: return "Zaten Mevcut"
        case 1302, 4302: return "Çakışma"
            
        // Authentication
        case 1400, 4400: return "Yetkisiz Giriş"
        case 1401, 4401: return "Oturum Geçersiz"
        case 1402, 4402: return "Oturum Süresi Doldu"
        case 1403, 4403: return "Erişim Engellendi"
        case 1404, 4404: return "Kimlik Doğrulama Hatası"
        case 1405, 4405: return "Hesap Doğrulanmadı"
        case 1406...1408, 4406...4408: return "Giriş Hatası"
            
        // External Service
        case 1500, 4500: return "Sunucu Hatası"
        case 1501, 4501: return "Zaman Aşımı"
        case 1503...1504, 4503...4504: return "Sunucu Hatası"
            
        // Business Logic
        case 1600, 4600: return "İşlem Hatası"
        case 1601...1602, 4601...4602: return "Sunucu Hatası"
            
        // WebSocket
        case 1700...1999, 4700...4999: return "Bağlantı Hatası"
            
        default: return "Hata"
        }
    }
    
    var message: String {
        switch code {
        // INTERNAL ERRORS - Hide details from user
        case 1000, 1001, 1200, 1500, 1503, 1504, 1601, 1602,
             4000, 4001, 4200, 4500, 4503, 4504, 4601, 4602:
            return "Sunucularımızda geçici bir sorun oluştu. Lütfen daha sonra tekrar deneyiniz."
            
        // CLIENT DISPLAYABLE ERRORS
        // General
        case 1002, 4002: return "İstek hatalı. Lütfen kontrol edip tekrar deneyin."
        case 1003, 4003: return "Çok fazla işlem yaptınız. Lütfen biraz bekleyin."
            
        // Validation
        case 1100, 4100: return "Girdiğiniz bilgilerde hata var. Lütfen kontrol edin."
        case 1101, 4101: return "Geçersiz veri girişi yaptınız."
        case 1102, 4102: return "Lütfen tüm zorunlu alanları doldurun."
        case 1100...1199, 4100...4199: return "Girdiğiniz bilgileri kontrol edip tekrar deneyin."
            
        // Database
        case 1201, 4201: return "Bu kayıt zaten mevcut."
            
        // Resource
        case 1300, 4300: return "Aradığınız içerik bulunamadı."
        case 1301, 4301: return "Bu içerik zaten mevcut."
        case 1302, 4302: return "İşlem sırasında bir çakışma oluştu."
            
        // Authentication
        case 1400, 4400: return "Bu işlemi yapmak için yetkiniz yok."
        case 1401, 4401: return "Oturumunuz geçersiz. Lütfen tekrar giriş yapın."
        case 1402, 4402: return "Oturum süreniz doldu. Lütfen tekrar giriş yapın."
        case 1403, 4403: return "Bu kaynağa erişim izniniz yok."
        case 1404, 4404: return "Kimlik doğrulama işlemi başarısız oldu."
        case 1405, 4405: return "Hesabınız henüz doğrulanmamış. Lütfen e-postanızı kontrol edin."
        case 1406, 4406: return "Geçersiz sosyal giriş sağlayıcısı."
        case 1407, 4407: return "Sosyal giriş token'ı geçersiz."
        case 1408, 4408: return "Sosyal hesap e-postası doğrulanmamış."
            
        // External Service
        case 1501, 4501: return "İşlem zaman aşımına uğradı. Lütfen tekrar deneyin."
            
        // Business Logic
        case 1600, 4600: return "İşlem gerçekleştirilemedi. Lütfen tekrar deneyin."
            
        // WebSocket
        case 1700...1999, 4700...4999:
            return "Bağlantı ile ilgili bir sorun oluştu. Lütfen internet bağlantınızı kontrol edin."
            
        default:
            // Bilinmeyen hatalar için genel mesaj
            return "Beklenmedik bir hata oluştu. Lütfen daha sonra tekrar deneyin."
        }
    }
}

