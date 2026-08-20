from django.db import transaction
from django.shortcuts import render
from rest_framework import generics, permissions
from .models import Product, User , Order, OrderItem, Cart
from .serializers import UserSerializer, UserRegistrationSerializer, UserLoginSerializer, productSerializer, orderSerializer, orderItemSerializer
from rest_framework.response import Response
from rest_framework.views import APIView
# Create your views here.
class UserRegistrationView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]
    
class UserLoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        user = User.objects.filter(email=email).first()
        if user is not None and user.check_password(password):
            return Response({'message': 'Login successful'})
        return Response({'message': 'Invalid credentials'}, status=400)
        
class ProductListView(generics.ListCreateAPIView):
    queryset = Product.objects.all()
    serializer_class = productSerializer
    permission_classes = [permissions.IsAuthenticated]        
    
class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.all()
    serializer_class = productSerializer
    permission_classes = [permissions.IsAuthenticated]
    
class OrderListView(generics.ListCreateAPIView):
    queryset = Order.objects.all()
    serializer_class = orderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
class OrderDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Order.objects.all()
    serializer_class = orderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @transaction.atomic
    def post(self, request, *args, **kwargs):
        user = request.user
        cart = Cart.objects.get(user=user)
        
        if not cart.products.exists():
            return Response({'message': 'Cart is empty'}, status=400)
        
        order = Order.objects.create(user=user, total_price=0)
        total_price = 0 
        
        for cart_item in cart.cartitem_set.all():
            product = cart_item.product
            quantity = cart_item.quantity
            total_price += product.price * quantity
            
            OrderItem.objects.create(
                order=order,
                product=product,
                quantity=quantity,
                total_price=product.price * quantity
            )
        order.total_price = total_price
        order.save()
        serializer = orderSerializer(order)
        return Response(serializer.data, status=201)