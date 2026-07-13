import SwiftUI
import PhotosUI

struct CreateProductScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    let onCreated: () -> Void
    
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var oldPrice: String = ""
    @State private var stock: String = ""
    @State private var unlimitedStock: Bool = false
    @State private var shortDescription: String = ""
    @State private var description: String = ""
    @State private var rootCategoryId: String = ""
    @State private var secondCategoryId: String = ""
    @State private var leafCategoryId: String = ""
    @State private var specValues: [String: String] = [:]
    @State private var selectedImages: [UIImage] = []
    @State private var localError: String?
    @State private var showImagePicker: Bool = false
    
    private let maxPhotos = 8
    
    private var isEditing: Bool { viewModel.productEditor != nil }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                basicCard
                categoryCard
                specificationsCard
                photosCard
                submitButton
            }
            .padding(16)
        }
        .onAppear {
            Task { await viewModel.loadCategories() }
            if let editor = viewModel.productEditor {
                hydrate(from: editor)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxSelection: maxPhotos - selectedImages.count)
        }
    }
    
    private var basicCard: some View {
        FormCard(title: "Основное") {
            VStack(spacing: 12) {
                SellerTextField(title: "Название товара", text: $name)
                SellerTextField(title: "Цена", text: $price, keyboardType: .decimalPad)
                SellerTextField(title: "Старая цена", text: $oldPrice, keyboardType: .decimalPad)
                HStack {
                    SellerTextField(title: "Остаток", text: $stock, keyboardType: .numberPad)
                    Toggle("Без лимита", isOn: $unlimitedStock)
                        .toggleStyle(.switch)
                }
                SellerTextField(title: "Краткое описание", text: $shortDescription)
                SellerTextField(title: "Описание", text: $description, minLines: 4)
            }
        }
    }
    
    private var categoryCard: some View {
        FormCard(title: "Категория") {
            VStack(spacing: 12) {
                Picker("Раздел", selection: $rootCategoryId) {
                    Text("Выберите раздел").tag("")
                    ForEach(viewModel.rootCategories()) { category in
                        Text(category.name ?? "—").tag(category.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: rootCategoryId) { _ in
                    secondCategoryId = ""
                    leafCategoryId = ""
                    specValues = [:]
                }
                
                Picker("Категория", selection: $secondCategoryId) {
                    Text(rootCategoryId.isEmpty ? "Сначала выберите предыдущий уровень" : "Выберите категорию").tag("")
                    ForEach(viewModel.childrenOf(parentId: rootCategoryId)) { category in
                        Text(category.name ?? "—").tag(category.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(rootCategoryId.isEmpty)
                .onChange(of: secondCategoryId) { _ in
                    leafCategoryId = ""
                    specValues = [:]
                }
                
                Picker("Тип товара", selection: $leafCategoryId) {
                    Text(secondCategoryId.isEmpty ? "Сначала выберите предыдущий уровень" : "Выберите тип товара").tag("")
                    ForEach(viewModel.childrenOf(parentId: secondCategoryId)) { category in
                        Text(category.name ?? "—").tag(category.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(secondCategoryId.isEmpty)
                .onChange(of: leafCategoryId) { newValue in
                    if !newValue.isEmpty {
                        Task { await viewModel.loadSpecificationTemplate(categoryId: newValue) }
                    }
                }
            }
        }
    }
    
    private var specificationsCard: some View {
        FormCard(title: "Характеристики") {
            if viewModel.specificationGroups.isEmpty {
                EmptyPanel(text: "Характеристики появятся после выбора типа товара", systemImage: "list.bullet.clipboard")
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.specificationGroups, id: \.title) { group in
                        if let items = group.items {
                            ForEach(items) { item in
                                specField(for: item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func specField(for item: SpecificationTemplateItemDto) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.label ?? item.specKey ?? "Характеристика")
                    .font(.sellerCaption)
                    .foregroundColor(.authFieldLabel)
                if item.required == true {
                    Text("обязательно")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerOrange)
                }
            }
            
            if let options = item.options, !options.isEmpty {
                Picker(item.label ?? "", selection: Binding(
                    get: { specValues[item.specKey ?? ""] ?? "" },
                    set: { specValues[item.specKey ?? ""] = $0 }
                )) {
                    Text("Выберите из списка").tag("")
                    ForEach(options, id: \.value) { option in
                        Text(option.label ?? option.value ?? "—").tag(option.value ?? "")
                    }
                }
                .pickerStyle(.menu)
            } else if item.type == "boolean" {
                Picker(item.label ?? "", selection: Binding(
                    get: { specValues[item.specKey ?? ""] ?? "" },
                    set: { specValues[item.specKey ?? ""] = $0 }
                )) {
                    Text("Выберите значение").tag("")
                    Text("Да").tag("true")
                    Text("Нет").tag("false")
                }
                .pickerStyle(.menu)
            } else {
                TextField(item.placeholder ?? "Введите значение", text: Binding(
                    get: { specValues[item.specKey ?? ""] ?? "" },
                    set: { specValues[item.specKey ?? ""] = $0 }
                ))
                .padding(12)
                .background(Color.sellerSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.authFieldBorder, lineWidth: 1)
                )
                .cornerRadius(8)
            }
        }
    }
    
    private var photosCard: some View {
        FormCard(title: "Фотографии") {
            VStack(spacing: 12) {
                HStack {
                    Button("Добавить фото") {
                        showImagePicker = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Spacer()
                    Text("\(selectedImages.count)/\(maxPhotos)")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
                
                if selectedImages.isEmpty {
                    EmptyPanel(text: "Фото пока не добавлены", systemImage: "photo")
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    if index == 0 {
                                        Text("Главное")
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.sellerBlack)
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                            .padding(4)
                                    }
                                    
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                    Text("Первое фото будет главным в карточке товара")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            Task { await submit() }
        }) {
            Text(isEditing ? "Сохранить и опубликовать" : "Создать товар")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.sellerBlack)
                .cornerRadius(26)
        }
    }
    
    private func submit() async {
        let issues = collectIssues()
        guard issues.isEmpty else {
            localError = "Проверьте поля: " + issues.joined(separator: ", ")
            viewModel.setError(localError!)
            return
        }
        
        let imageInputs = selectedImages.enumerated().compactMap { index, image -> ProductImageInputDto? in
            guard let base64 = ImageResizer.base64JPEG(image: image) else { return nil }
            return ProductImageInputDto(
                imageUrl: nil,
                thumbnailUrl: nil,
                base64: base64,
                altText: name,
                isPrimary: index == 0
            )
        }
        
        let specs = specValues.compactMap { key, value -> ProductSpecInputDto? in
            guard !key.isEmpty, !value.isEmpty else { return nil }
            return ProductSpecInputDto(specKey: key, specValue: value)
        }
        
        let request = UpsertSellerProductRequest(
            name: name,
            price: price.normalizedDouble(allowBlank: false) ?? 0,
            oldPrice: oldPrice.normalizedDouble(allowBlank: true),
            categoryId: leafCategoryId,
            stockQuantity: unlimitedStock ? nil : Int(stock),
            isUnlimitedStock: unlimitedStock,
            status: isEditing ? (viewModel.productEditor?.status ?? "draft") : "draft",
            description: description.isEmpty ? nil : description,
            shortDescription: shortDescription.isEmpty ? nil : shortDescription,
            images: imageInputs,
            specifications: specs
        )
        
        if isEditing, let productId = viewModel.productEditor?.id {
            await viewModel.updateProduct(productId: productId, request: request)
        } else {
            await viewModel.createProduct(request: request)
        }
        viewModel.clearProductEditor()
        onCreated()
    }
    
    private func collectIssues() -> [String] {
        var issues: [String] = []
        if name.trimmingCharacters(in: .whitespaces).count < 2 { issues.append("название товара") }
        guard let parsedPrice = price.normalizedDouble(allowBlank: false), parsedPrice > 0 else {
            issues.append("цена")
        }
        if parsedPrice > 99_999_999.99 { issues.append("цена не может превышать 99 999 999.99") }
        if let parsedOld = oldPrice.normalizedDouble(allowBlank: true) {
            if parsedOld > 99_999_999.99 { issues.append("старая цена не может превышать 99 999 999.99") }
            if parsedOld < parsedPrice { issues.append("старая цена не меньше текущей") }
        } else if !oldPrice.isEmpty {
            issues.append("старая цена")
        }
        if !unlimitedStock, (Int(stock) ?? 0) <= 0 { issues.append("остаток") }
        if rootCategoryId.isEmpty { issues.append("раздел") }
        if secondCategoryId.isEmpty { issues.append("категория") }
        if leafCategoryId.isEmpty { issues.append("тип товара") }
        
        for group in viewModel.specificationGroups {
            for item in group.items ?? [] {
                if item.required == true, let key = item.specKey, specValues[key]?.isEmpty != false {
                    issues.append("характеристика «\(item.label ?? key)»")
                }
            }
        }
        
        if selectedImages.isEmpty && !isEditing { issues.append("фотографии") }
        return issues
    }
    
    private func hydrate(from product: SellerProductDto) {
        name = product.name ?? ""
        price = product.price.map { String($0) } ?? ""
        oldPrice = product.oldPrice.map { String($0) } ?? ""
        stock = product.stockQuantity.map { String($0) } ?? ""
        unlimitedStock = product.isUnlimitedStock ?? false
        shortDescription = product.shortDescription ?? ""
        description = product.description ?? ""
        // Category hydration would require tree navigation; simplified here
        leafCategoryId = product.categoryId ?? ""
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxSelection: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = max(1, maxSelection)
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage, let resized = ImageResizer.resize(image: image) {
                            DispatchQueue.main.async {
                                if self.parent.selectedImages.count < 8 {
                                    self.parent.selectedImages.append(resized)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
