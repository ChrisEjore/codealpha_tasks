import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private mockProducts: Product[] = [
    {
      id: 1,
      name: 'Wireless Headphones',
      price: 99.99,
      description: 'High-quality sound with noise cancellation features.',
      imageUrl: 'https://via.placeholder.com/150',
      category: 'Electronics'
    },
    {
      id: 2,
      name: 'Smart Watch',
      price: 149.99,
      description: 'Track your fitness, heart rate, and daily activity.',
      imageUrl: 'https://via.placeholder.com/150',
      category: 'Electronics'
    },
    {
      id: 3,
      name: 'Running Shoes',
      price: 79.99,
      description: 'Lightweight and durable athletic running shoes.',
      imageUrl: 'https://via.placeholder.com/150',
      category: 'Footwear'
    }
  ];

  getProducts(): Observable<Product[]> {
    return of(this.mockProducts);
  }
}