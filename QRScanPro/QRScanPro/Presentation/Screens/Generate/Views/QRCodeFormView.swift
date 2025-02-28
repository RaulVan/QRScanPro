import SwiftUI

// 二维码表单视图
struct QRCodeFormView: View {
    let type: QRCodeType
    let historyManager: HistoryManager
    @EnvironmentObject private var generateViewModel: GenerateViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var generatedContent: String = ""
    @State private var showResult = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentContent: String? = nil
    
    // 各种表单字段
    @State private var email = ""
    @State private var subject = ""
    @State private var connent = ""
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var address = ""
    
    @State private var url = "https://"
    @State private var urlProtocol = "https://"
    
    @State private var message = ""
    @State private var recipient = ""
    
    @State private var ssid = ""
    @State private var password = ""
    @State private var isHidden = false
    @State private var wifiType = "WPA"
    
    @State private var latitude = ""
    @State private var longitude = ""
    
    @State private var text = ""  // 添加纯文本类型的字段
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 表单标题和图标
                    HStack {
                        Circle()
                            .fill(type.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(type.color)
                            )
                        
                        Text(type.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 根据类型渲染不同的表单
                    switch type {
                    case .email:
                        emailForm
                    case .contact:
                        contactForm
                    case .phone:
                        phoneForm
                    case .url:
                        urlForm
                    case .message:
                        messageForm
                    case .wifi:
                        wifiForm
                    case .clipboard:
                        clipboardForm
                    case .location:
                        locationForm
                    case .text:
                        textForm
                    }
                    
                    // 生成按钮
                    Button(action: generateQRCode) {
                        Text("Generate QR Code")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(type.color)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Generate QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showResult) {
                if let content = generateViewModel.generatedContent, !content.isEmpty {
                    GeneratedQRView(code: content, type: type) {
                        dismiss()
                        generateViewModel.reset()
                    }
                }
            }
            .alert("Invalid Input", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 各类型表单
    
    // 添加纯文本表单
    var textForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Text Content", value: $text, placeholder: "Enter any text", isMultiline: true)
        }
        .padding(.horizontal)
    }
    
    var emailForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Email Address", value: $email, placeholder: "example@email.com")
            FormField(title: "Subject", value: $subject, placeholder: "Email subject")
            FormField(title: "Body", value: $connent, placeholder: "Email content", isMultiline: true)
        }
        .padding(.horizontal)
    }
    
    var contactForm: some View {
        VStack(spacing: 15) {
            FormField(title: "First Name", value: $firstName, placeholder: "First name")
            FormField(title: "Last Name", value: $lastName, placeholder: "Last name")
            FormField(title: "Phone", value: $phone, placeholder: "Phone number")
            FormField(title: "Email", value: $email, placeholder: "Email address")
            FormField(title: "Address", value: $address, placeholder: "Address", isMultiline: true)
        }
        .padding(.horizontal)
    }
    
    var phoneForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Phone Number", value: $phone, placeholder: "e.g. +1234567890")
        }
        .padding(.horizontal)
    }
    
    var urlForm: some View {
        VStack(spacing: 15) {
            // 添加 URL 类型选择
            Picker("Protocol", selection: $urlProtocol) {
                Text("https://").tag("https://")
                Text("http://").tag("http://")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            FormField(
                title: "URL",
                value: Binding(
                    get: { url.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "") },
                    set: { url = urlProtocol + $0 }
                ),
                placeholder: "example.com"
            )
        }
        .padding(.horizontal)
    }
    
    var messageForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Recipient", value: $recipient, placeholder: "Phone number")
            FormField(title: "Message", value: $message, placeholder: "Message content", isMultiline: true)
        }
        .padding(.horizontal)
    }
    
    var wifiForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Network Name (SSID)", value: $ssid, placeholder: "WiFi network name")
            
            VStack(alignment: .leading) {
                Text("Password").fontWeight(.medium)
                
                if isHidden {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    TextField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Toggle("Hide Password", isOn: $isHidden)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            VStack(alignment: .leading) {
                Text("Network Type").fontWeight(.medium)
                
                Picker("Network Type", selection: $wifiType) {
                    Text("WPA/WPA2").tag("WPA")
                    Text("WEP").tag("WEP")
                    Text("None").tag("nopass")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.horizontal)
    }
    
    var clipboardForm: some View {
        VStack(spacing: 15) {
            if let clipboardString = UIPasteboard.general.string {
                Text("Clipboard Content:")
                    .fontWeight(.medium)
                Text(clipboardString)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No text found in clipboard")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    var locationForm: some View {
        VStack(spacing: 15) {
            FormField(title: "Latitude", value: $latitude, placeholder: "e.g. 37.7749")
            FormField(title: "Longitude", value: $longitude, placeholder: "e.g. -122.4194")
            
//            Button("Use Current Location") {
//                // This would need location permission handling
//                // For now, just set example values
//                latitude = "37.7749"
//                longitude = "-122.4194"
//            }
//            .foregroundColor(type.color)
//            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
    
    // 生成二维码
    func generateQRCode() {
        // 重置状态
        errorMessage = ""
        var content = ""
        var hasContent = false
        
        switch type {
        case .email:
            // 验证邮箱
            if email.isEmpty {
                // 显示错误提示
                errorMessage = "Please enter a valid email"
                showError = true
                return
            }
            
            var emailCode = "mailto:\(email)"
            if !subject.isEmpty || !connent.isEmpty {
                emailCode += "?"
                if !subject.isEmpty {
                    emailCode += "subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                }
                if !connent.isEmpty {
                    if !subject.isEmpty { emailCode += "&" }
                    emailCode += "body=\(connent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                }
            }
            content = emailCode
            hasContent = true
            
        case .contact:
            // 至少需要姓名
            if firstName.isEmpty && lastName.isEmpty {
                errorMessage = "Please enter both first and last name"
                showError = true
                return
            }
            
            // vCard format
            let vcard = """
            BEGIN:VCARD
            VERSION:3.0
            N:\(lastName);\(firstName)
            TEL:\(phone)
            EMAIL:\(email)
            ADR:\(address)
            END:VCARD
            """
            content = vcard
            hasContent = true
            
        case .phone:
            if phone.isEmpty {
                errorMessage = "Please enter a valid phone number"
                showError = true
                return
            }
            content = "tel:\(phone)"
            hasContent = true
            
        case .url:
            var processedUrl = url
                .replacingOccurrences(of: "https://https://", with: "https://")
                .replacingOccurrences(of: "http://http://", with: "http://")
            
            if !processedUrl.hasPrefix("http://") && !processedUrl.hasPrefix("https://") {
                processedUrl = "https://" + processedUrl
            }
            
            if processedUrl == "https://" || processedUrl == "http://" {
                errorMessage = "Please enter a valid URL"
                showError = true
                return
            }
            
            if let _ = URL(string: processedUrl) {
                content = processedUrl
                hasContent = true
            } else {
                errorMessage = "Invalid URL format"
                showError = true
                return
            }
            
        case .message:
            if recipient.isEmpty {
                errorMessage = "Please enter a recipient"
                showError = true
                return
            }
            var smsCode = "sms:\(recipient)"
            if !message.isEmpty {
                smsCode += "?body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
            content = smsCode
            hasContent = true
            
        case .wifi:
            if ssid.isEmpty {
                errorMessage = "Please enter a network name"
                showError = true
                return
            }
            content = "WIFI:T:\(wifiType);S:\(ssid);P:\(password);;"
            hasContent = true
            
        case .clipboard:
            if let clipboardString = UIPasteboard.general.string, !clipboardString.isEmpty {
                content = clipboardString
                hasContent = true
            } else {
                errorMessage = "No text found in clipboard"
                showError = true
                return
            }
            
        case .location:
            if latitude.isEmpty || longitude.isEmpty {
                errorMessage = "Please enter both latitude and longitude"
                showError = true
                return
            }
            content = "geo:\(latitude),\(longitude)"
            hasContent = true
            
        case .text:
            if text.isEmpty {
                errorMessage = "Please enter some text"
                showError = true
                return
            }
            content = text
            hasContent = true
        }
        
        if hasContent && !content.isEmpty {
            historyManager.addGeneratedRecord(content, type: type)
            generateViewModel.generateQRCode(content, type: type)
            showResult = true
        } else {
            errorMessage = "Please fill in the required fields"
            showError = true
            showResult = false
        }
    }
} 
