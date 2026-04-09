import UIKit

class AddProductViewController: UIViewController {

    let context = PersistenceController.shared.context

    let idField = UITextField()
    let nameField = UITextField()
    let descField = UITextField()
    let priceField = UITextField()
    let providerField = UITextField()
    let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Product"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    func setupUI() {
        [idField, nameField, descField, priceField, providerField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
        }

        idField.placeholder = "Product ID"
        nameField.placeholder = "Product Name"
        descField.placeholder = "Product Description"
        priceField.placeholder = "Product Price"
        providerField.placeholder = "Product Provider"
        priceField.keyboardType = .decimalPad

        saveButton.setTitle("Save Product", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            idField, nameField, descField, priceField, providerField, saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func saveTapped() {
        guard
            let id = idField.text, !id.isEmpty,
            let name = nameField.text, !name.isEmpty,
            let desc = descField.text, !desc.isEmpty,
            let priceText = priceField.text, let price = Double(priceText),
            let provider = providerField.text, !provider.isEmpty
        else {
            showAlert(message: "Please fill in all fields correctly.")
            return
        }

        let product = Product(context: context)
        product.productID = id
        product.productName = name
        product.productDesc = desc
        product.productPrice = price
        product.productProvider = provider

        PersistenceController.shared.saveContext()
        showAlert(message: "Product added successfully!") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
