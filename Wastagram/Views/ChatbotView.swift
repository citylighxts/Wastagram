import SwiftUI

struct ChatbotView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Halo! Saya WastaBot. Tanya saya apa saja tentang pengolahan sampah, daur ulang, atau cara memilah sampah!", isUser: false)
    ]
    
    let apiKey = ""
    let endpointUrl = "https://openrouter.ai/api/v1/chat/completions"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("WastaBot AI")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Powered by OpenRouter")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(hex: "2DAD02"))
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("WastaBot sedang mengetik...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.leading)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack(spacing: 10) {
                TextField("Tanya tentang sampah...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isLoading ? .gray : Color(hex: "2DAD02"))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 2)
        }
    }
    
    func sendMessage() {
        let userText = messageText
        let userMsg = ChatMessage(text: userText, isUser: true)
        
        messages.append(userMsg)
        messageText = ""
        isLoading = true
        
        callOpenRouter(query: userText)
    }
    
    func callOpenRouter(query: String) {
        guard let url = URL(string: endpointUrl) else { return }
        
        let currentModel = "deepseek/deepseek-r1-0528:free"
        
        let systemPrompt = """
        Kamu adalah WastaBot, asisten AI aplikasi Wastagram.
        Jawablah pertanyaan seputar sampah dan daur ulang dalam Bahasa Indonesia.
        Format jawabanmu menggunakan Markdown sederhana (bold, italic) agar mudah dibaca di HP.
        """
        
        let parameters: [String: Any] = [
            "model": currentModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": query]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("https://wastagram.app", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("Wastagram iOS", forHTTPHeaderField: "X-Title")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        if let errorObj = json["error"] as? [String: Any],
                           let message = errorObj["message"] as? String {
                            self.messages.append(ChatMessage(text: "API Error: \(message)", isUser: false))
                            return
                        }
                        
                        if let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let messageContent = firstChoice["message"] as? [String: Any],
                           let content = messageContent["content"] as? String {
                            
                            let cleanContent = self.cleanDeepSeekResponse(content)
                            self.messages.append(ChatMessage(text: cleanContent, isUser: false))
                            
                        } else {
                            self.messages.append(ChatMessage(text: "WastaBot tidak merespon.", isUser: false))
                        }
                    }
                } catch {
                    self.messages.append(ChatMessage(text: "Gagal memproses data.", isUser: false))
                }
            }
        }.resume()
    }
    
    func cleanDeepSeekResponse(_ text: String) -> String {
        if let rangeStart = text.range(of: "<think>"), let rangeEnd = text.range(of: "</think>") {
            let rangeToRemove = rangeStart.lowerBound..<rangeEnd.upperBound
            var newText = text
            newText.removeSubrange(rangeToRemove)
            return newText
                .replacingOccurrences(of: "</think>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isUser { Spacer() } else {
                ZStack {
                    Circle().fill(Color(hex: "2DAD02"))
                        .frame(width: 30, height: 30)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            Text(LocalizedStringKey(message.text))
                .padding()
                .background(message.isUser ? Color(hex: "2DAD02") : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .black)
                .font(.system(size: 15))
                .cornerRadius(15)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView()
    }
}
