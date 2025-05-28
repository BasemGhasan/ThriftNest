import 'package:flutter/material.dart';

// ----------------- Data Models -----------------

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

// ----------------- Mock Data -----------------

final List<Product> mockProducts = [
  Product(
    id: 1,
    name: 'Used Laptop',
    description: 'A well-maintained used laptop with 8GB RAM and 256GB SSD.',
    price: 350.0,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  Product(
    id: 2,
    name: 'Smartphone',
    description: 'Almost new smartphone with great camera and battery life.',
    price: 200.0,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  Product(
    id: 3,
    name: 'Gaming Headset',
    description: 'Comfortable headset with noise cancellation.',
    price: 50.0,
    imageUrl: 'https://via.placeholder.com/150',
  ),
];

// ----------------- Main Buyer App -----------------

void main() {
  runApp(BuyerApp());
}

class BuyerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThriftNest Buyer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ----------------- Product List Screen -----------------

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<CartItem> cart = [];

  void _addToCart(Product product) {
    setState(() {
      final existingIndex =
          cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItem(product: product));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cart: cart),
      ),
    ).then((_) => setState(() {})); // Refresh after return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products for Sale'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockProducts.length,
        itemBuilder: (context, index) {
          final product = mockProducts[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(product.imageUrl),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () => _addToCart(product),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(
                      product: product,
                      onAddToCart: _addToCart,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ----------------- Product Details Screen -----------------

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, height: 200),
            SizedBox(height: 20),
            Text(
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(product.description),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Add to Cart'),
                onPressed: () {
                  onAddToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Cart Screen -----------------

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;

  const CartScreen({Key? key, required this.cart}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Checkout'),
        content:
            Text('This is a dummy checkout. Thank you for your purchase!'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                widget.cart.clear();
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  double get totalPrice {
    return widget.cart.fold(
        0, (sum, item) => sum + item.product.price * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart (${widget.cart.length} items)'),
      ),
      body: widget.cart.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return ListTile(
                        leading: Image.network(item.product.imageUrl),
                        title: Text(item.product.name),
                        subtitle: Text(
                            '${item.quantity} x \$${item.product.price.toStringAsFixed(2)} = \$${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeItem(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: _checkout,
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}