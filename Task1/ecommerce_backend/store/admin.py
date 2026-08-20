from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Product, Cart, CartItem, Order, OrderItem

# 1. Custom User Admin
@admin.register(User)
class CustomUserAdmin(BaseUserAdmin):
    # Display custom fields in the list view
    list_display = ('email', 'username', 'is_seller', 'is_staff', 'is_superuser')
    list_filter = ('is_seller', 'is_staff', 'is_superuser')
    
    # Include 'is_seller' when editing a user in admin
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Custom Attributes', {'fields': ('is_seller',)}),
    )
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('Custom Attributes', {'fields': ('is_seller',)}),
    )

# 2. Product Admin
@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'seller', 'price', 'category', 'created_at')
    list_filter = ('category', 'created_at')
    search_fields = ('name', 'description', 'seller__email')

# 3. Cart & Cart Items (Inline view for convenience)
class CartItemInline(admin.TabularInline):
    model = CartItem
    extra = 1

@admin.register(Cart)
class CartAdmin(admin.ModelAdmin):
    list_display = ('user', 'created_at')
    inlines = [CartItemInline]

# 4. Order & Order Items (Inline view so you can see items inside each order)
class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('price_at_purchase',)

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'total_price', 'payment_method', 'created_at')
    list_filter = ('status', 'created_at', 'payment_method')
    search_fields = ('user__email', 'shipping_address')
    inlines = [OrderItemInline]