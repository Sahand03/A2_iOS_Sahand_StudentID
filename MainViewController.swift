import UIKit
import CoreData

class MainViewController: UIViewController, UISearchBarDelegate {

    let context = PersistenceController.shared.context
    var products: [Product] = []
    var currentIndex = 0
    var filteredProducts: [Product] = []

    let idLabel = UILabel()
    let nameLabel = UILabel()
    let descLabel = UILabel()
    let priceLabel = UILabel()
    let providerLabel = UILabel()
    let searchBar = UISearchBar()

    let prevButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    let addButton = UIButton(type: .system)
    let listButton = UIButton(type: .system)
    let resetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
        view.backgroundColor = .systemBackground
        setupUI()
        seedInitialProductsIfNeeded()
        fetchProducts()
        displayCurrentProduct()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
        displayCurrentProduct()
    }

    func setupUI() {
        searchBar.placeholder = "Search by name or description"
        searchBar.delegate = self

        [idLabel, nameLabel, descLabel, priceLabel, providerLabel].forEach {
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 18)
        }

        prevButton.setTitle("Previous", for: .normal)
        nextButton.setTitle("Next", for: .normal)
        addButton.setTitle("Add Product", for: .normal)
        listButton.setTitle("View All Products", for: .normal)
        resetButton.setTitle("Reset Search", for: .normal)

        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(listTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetSearchTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            searchBar,
            idLabel,
            nameLabel,
            descLabel,
            priceLabel,
            providerLabel,
            prevButton,
            nextButton,
            addButton,
            listButton,
            resetButton
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

    func fetchProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            products = try context.fetch(request)
            filteredProducts = products
            if currentIndex >= filteredProducts.count {
                currentIndex = 0
            }
        } catch {
            print("Error fetching products: \(error)")
        }
    }

    func displayCurrentProduct() {
        guard !filteredProducts.isEmpty else {
            idLabel.text = "Product ID: N/A"
            nameLabel.text = "Product Name: No products found"
            descLabel.text = "Description: N/A"
            priceLabel.text = "Price: N/A"
            providerLabel.text = "Provider: N/A"
            return
        }

        let product = filteredProducts[currentIndex]
        idLabel.text = "Product ID: \(product.productID ?? "")"
        nameLabel.text = "Product Name: \(product.productName ?? "")"
        descLabel.text = "Description: \(product.productDesc ?? "")"
        priceLabel.text = "Price: $\(String(format: "%.2f", product.productPrice))"
        providerLabel.text = "Provider: \(product.productProvider ?? "")"
    }

    @objc func prevTapped() {
        guard !filteredProducts.isEmpty else { return }
        currentIndex = (currentIndex - 1 + filteredProducts.count) % filteredProducts.count
        displayCurrentProduct()
    }

    @objc func nextTapped() {
        guard !filteredProducts.isEmpty else { return }
        currentIndex = (currentIndex + 1) % filteredProducts.count
        displayCurrentProduct()
    }

    @objc func addTapped() {
        navigationController?.pushViewController(AddProductViewController(), animated: true)
    }

    @objc func listTapped() {
        navigationController?.pushViewController(ProductListViewController(), animated: true)
    }

    @objc func resetSearchTapped() {
        searchBar.text = ""
        filteredProducts = products
        currentIndex = 0
        displayCurrentProduct()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter {
                ($0.productName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.productDesc?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        currentIndex = 0
        displayCurrentProduct()
    }

    func seedInitialProductsIfNeeded() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            let count = try context.count(for: request)
            if count == 0 {
                let sampleProducts = [
                    ("P001", "iPhone 15", "Apple smartphone with powerful camera", 1299.99, "Apple"),
                    ("P002", "Galaxy S24", "Samsung flagship Android phone", 1199.99, "Samsung"),
                    ("P003", "MacBook Air", "Lightweight Apple laptop", 1499.99, "Apple"),
                    ("P004", "iPad Pro", "High-performance Apple tablet", 1399.99, "Apple"),
                    ("P005", "AirPods Pro", "Wireless earbuds with noise cancellation", 329.99, "Apple"),
                    ("P006", "PlayStation 5", "Sony gaming console", 649.99, "Sony"),
                    ("P007", "Xbox Series X", "Microsoft gaming console", 649.99, "Microsoft"),
                    ("P008", "Dell XPS 13", "Premium Windows ultrabook", 1599.99, "Dell"),
                    ("P009", "Logitech MX Master 3", "Advanced wireless mouse", 129.99, "Logitech"),
                    ("P010", "Apple Watch", "Smartwatch with health tracking", 599.99, "Apple")
                ]

                for item in sampleProducts {
                    let product = Product(context: context)
                    product.productID = item.0
                    product.productName = item.1
                    product.productDesc = item.2
                    product.productPrice = item.3
                    product.productProvider = item.4
                }

                PersistenceController.shared.saveContext()
            }
        } catch {
            print("Seeding error: \(error)")
        }
    }
}
