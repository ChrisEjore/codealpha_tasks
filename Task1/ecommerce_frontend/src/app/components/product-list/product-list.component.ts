import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

export interface Product {
  id: number;
  title: string;
  description: string;
  price: number;
  category: string;
  imageUrl: string;
  discountBadge?: string;
  oldPrice?: number;
  ratingStars?: string;
  ratingCount?: number;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.css']
})
export class ProductListComponent {
  isCartOpen = false;
  isRegisterOpen = false;
  checkoutStep: 'review' | 'checkout' = 'review';

  cart: CartItem[] = [];

  regData = { fullName: '', email: '', password: '' };
  orderData = { shippingAddress: '', paymentMethod: 'card', cardNumber: '' };

  products: Product[] = [
    {
      id: 1,
      title: "Men's Classic Denim Jacket",
      description: 'Timeless vintage denim jacket with warm cotton lining.',
      price: 89.99,
      oldPrice: 179.99,
      discountBadge: '25% OFF',
      ratingStars: '★★★★☆',
      ratingCount: 54,
      category: "Men's Apparel",
      imageUrl: 'https://images.unsplash.com/photo-1495105787522-5334e3ffa0ef?auto=format&fit=crop&w=600&q=80'
    },
    {
      id: 2,
      title: "Women's Floral Summer Dress",
      description: 'Lightweight, breathable cotton dress designed for comfort.',
      price: 50.99,
      oldPrice: 74.99,
      discountBadge: 'SALE',
      ratingStars: '★★★★★',
      ratingCount: 88,
      category: "Women's Apparel",
      imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=600&q=80'
    },
    {
      id: 3,
      title: 'Kids Organic Cotton Hoodie',
      description: 'Ultra-soft fleece hoodie designed for play and day-long wear.',
      price: 38.99,
      ratingStars: '★★★★☆',
      ratingCount: 29,
      category: "Kids' Apparel",
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=600&q=80'
    },
    {
      id: 4,
      title: 'Nike Air Max Sneakers',
      description: 'Iconic cushioned design providing maximum comfort and style.',
      price: 120.99,
      oldPrice: 159.99,
      discountBadge: 'HOT',
      ratingStars: '★★★★★',
      ratingCount: 142,
      category: 'Footwear',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80'
    }
  ];

  get cartTotal(): number {
    return this.cart.reduce((sum, item) => sum + item.product.price * item.quantity, 0);
  }

  toggleCart(): void {
    this.isCartOpen = !this.isCartOpen;
    if (!this.isCartOpen) {
      this.checkoutStep = 'review';
    }
  }

  toggleRegisterModal(): void {
    this.isRegisterOpen = !this.isRegisterOpen;
  }

  toggleWishlist(product: Product): void {
    console.log('Toggled wishlist item:', product);
  }

  addToCart(product: Product): void {
    const existing = this.cart.find(i => i.product.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      this.cart.push({ product, quantity: 1 });
    }
    this.isCartOpen = true; // Opens cart drawer automatically on click
  }

  removeFromCart(productId: number): void {
    this.cart = this.cart.filter(i => i.product.id !== productId);
    if (this.cart.length === 0) {
      this.checkoutStep = 'review';
    }
  }

  proceedToCheckout(): void {
    this.checkoutStep = 'checkout';
  }

  backToReview(): void {
    this.checkoutStep = 'review';
  }

  onRegister(): void {
    console.log('Registering user:', this.regData);
    alert(`Account created for ${this.regData.fullName}!`);
    this.isRegisterOpen = false;
    this.regData = { fullName: '', email: '', password: '' };
  }

  onProcessOrder(): void {
    console.log('Processing order:', this.orderData, this.cart);
    alert(`Order completed successfully! Total: $${this.cartTotal.toFixed(2)}`);
    this.cart = [];
    this.checkoutStep = 'review';
    this.isCartOpen = false;
  }
}