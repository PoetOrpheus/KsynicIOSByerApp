import SwiftUI
import UniformTypeIdentifiers

struct DocumentsScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    
    @State private var businessType: String = "ip"
    @State private var legalName: String = ""
    @State private var taxId: String = ""
    @State private var registrationNumber: String = ""
    @State private var isEditingRequisites: Bool = false
    @State private var selectedDocumentType: String?
    @State private var showFilePicker: Bool = false
    @State private var showSubmitAlert: Bool = false
    
    private let documentTypes: [(String, String)] = [
        ("agency_contract", "Агентский договор"),
        ("tax_registration", "ИНН / налоговый документ"),
        ("business_registration", "ОГРН / ОГРНИП"),
        ("bank_details", "Банковские реквизиты"),
        ("identity", "Паспорт ИП"),
        ("company_charter", "Устав организации"),
        ("representative_authority", "Полномочия руководителя"),
        ("other", "Другой документ")
    ]
    
    private var requiredTypes: [(String, String)] {
        documentTypes.filter { type, _ in
            if type == "identity" { return businessType == "ip" }
            if type == "company_charter" || type == "representative_authority" { return businessType == "company" }
            if type == "other" { return false }
            return true
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statusPanel
                requisitesCard
                documentsCard
                submitButton
            }
            .padding(16)
        }
        .refreshable {
            await viewModel.refreshDocuments()
            await viewModel.refreshProfile()
        }
        .onAppear {
            Task {
                await viewModel.refreshDocuments()
                await viewModel.refreshProfile()
            }
            if let profile = viewModel.profile {
                businessType = profile.businessType ?? "ip"
                legalName = profile.legalName ?? ""
                taxId = profile.taxId ?? ""
                registrationNumber = profile.registrationNumber ?? ""
            }
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker { url in
                handlePickedFile(url: url)
            }
        }
        .alert(isPresented: $showSubmitAlert) {
            Alert(
                title: Text("Не все документы приложены"),
                message: Text("Вы не загрузили обязательные документы. Отправить уже загруженные документы на проверку?"),
                primaryButton: .default(Text("Отправить")) {
                    Task { await viewModel.submitVerification() }
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
    
    private var statusPanel: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(statusTitle)
                .font(.sellerHeadline)
                .foregroundColor(statusColor)
            Spacer()
        }
        .padding(16)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        if viewModel.session.documentsVerified { return "checkmark.circle.fill" }
        return "exclamationmark.circle.fill"
    }
    
    private var statusColor: Color {
        if viewModel.session.documentsVerified { return .sellerGreen }
        return .sellerOrange
    }
    
    private var statusTitle: String {
        if viewModel.session.documentsVerified { return "Документы проверены" }
        return "Документы не отправлены на проверку"
    }
    
    private var requisitesCard: some View {
        FormCard(title: "Реквизиты") {
            VStack(spacing: 12) {
                if isEditingRequisites {
                    HStack(spacing: 12) {
                        FilterChip(title: "ИП", isSelected: businessType == "ip") { businessType = "ip" }
                        FilterChip(title: "Компания", isSelected: businessType == "company") { businessType = "company" }
                    }
                    SellerTextField(title: "Название компании или ИП", text: $legalName)
                    SellerTextField(title: "ИНН", text: $taxId, keyboardType: .numberPad)
                    SellerTextField(title: "ОГРН / ОГРНИП", text: $registrationNumber, keyboardType: .numberPad)
                    Button("Сохранить реквизиты") {
                        Task {
                            await viewModel.saveProfile(request: UpdateSellerRequest(
                                businessType: businessType,
                                legalName: legalName,
                                taxId: taxId,
                                registrationNumber: registrationNumber
                            ))
                            isEditingRequisites = false
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    infoRow(title: "Форма", value: businessType == "ip" ? "ИП" : "Компания")
                    infoRow(title: "Название", value: legalName.ifEmpty("Не указано"))
                    infoRow(title: "ИНН", value: taxId.ifEmpty("Не указан"))
                    infoRow(title: "ОГРН / ОГРНИП", value: registrationNumber.ifEmpty("Не указан"))
                    Button("Редактировать реквизиты") {
                        isEditingRequisites = true
                    }
                    .buttonStyle(OutlineButtonStyle())
                }
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.sellerBody)
                .foregroundColor(.sellerMuted)
            Spacer()
            Text(value)
                .font(.sellerBody)
                .foregroundColor(.sellerInk)
        }
    }
    
    private var documentsCard: some View {
        FormCard(title: "Документы") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Выберите файлы по каждому типу документа. При отправке на проверку выбранные файлы загрузятся автоматически.")
                    .font(.sellerCaption)
                    .foregroundColor(.sellerMuted)
                
                ForEach(requiredTypes, id: \.0) { type, name in
                    documentRow(type: type, name: name)
                }
                
                if !viewModel.documents.isEmpty {
                    SectionTitle(text: "Загруженные документы")
                    ForEach(viewModel.documents) { document in
                        DocumentRow(document: document, onDelete: {
                            Task { await viewModel.deleteDocument(id: document.id ?? "") }
                        })
                    }
                }
            }
        }
    }
    
    private func documentRow(type: String, name: String) -> some View {
        let uploaded = viewModel.documents.first { $0.documentType == type }
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.sellerBody)
                if let uploaded = uploaded {
                    Text(statusTextForDocument(uploaded.reviewStatus))
                        .font(.sellerCaption)
                        .foregroundColor(.statusColor(uploaded.reviewStatus))
                } else {
                    Text("Не выбран *")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerOrange)
                }
            }
            Spacer()
            Button(uploaded == nil ? "Выбрать" : "Заменить") {
                selectedDocumentType = type
                showFilePicker = true
            }
            .buttonStyle(OutlineButtonStyle())
        }
        .padding(12)
        .background(Color.sellerCloud)
        .cornerRadius(8)
    }
    
    private var submitButton: some View {
        Button(action: {
            let missing = missingRequiredDocuments()
            if missing.isEmpty {
                Task { await viewModel.submitVerification() }
            } else {
                showSubmitAlert = true
            }
        }) {
            Text(submitButtonTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.sellerBlack)
                .cornerRadius(26)
        }
    }
    
    private var submitButtonTitle: String {
        if viewModel.session.isActive && viewModel.session.documentsVerified { return "На проверке" }
        return "Отправить на проверку"
    }
    
    private func missingRequiredDocuments() -> [String] {
        requiredTypes.compactMap { type, name in
            viewModel.documents.contains { $0.documentType == type } ? nil : name
        }
    }
    
    private func handlePickedFile(url: URL) {
        guard let type = selectedDocumentType else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let base64 = "data:application/pdf;base64," + data.base64EncodedString()
            let request = UploadSellerDocumentRequest(
                documentType: type,
                documentName: url.lastPathComponent,
                base64: base64,
                mimeType: "application/pdf",
                fileName: url.lastPathComponent
            )
            Task { await viewModel.uploadDocument(request: request) }
        } catch {
            viewModel.setError("Не удалось прочитать файл: \(url.lastPathComponent)")
        }
    }
    
    private func statusTextForDocument(_ status: String?) -> String {
        switch status {
        case "uploaded": return "Загружен"
        case "review": return "На проверке"
        case "approved": return "Проверен"
        case "rejected": return "Нужна замена"
        default: return status ?? "—"
        }
    }
}

struct DocumentRow: View {
    let document: SellerDocumentDto
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(document.documentName ?? document.fileName ?? "Документ")
                    .font(.sellerBody)
                Text(document.reviewStatus ?? "—")
                    .font(.sellerCaption)
                    .foregroundColor(.statusColor(document.reviewStatus))
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Color.sellerCloud)
        .cornerRadius(8)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.pdf,
            UTType.jpeg,
            UTType.png,
            UTType.webP
        ])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}
