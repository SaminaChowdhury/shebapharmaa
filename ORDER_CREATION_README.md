# Order Creation API Integration

This Flutter app now includes a complete order creation system that integrates with the API endpoint: `https://shebaai.pythonanywhere.com/api/orders/create/`

## Features Implemented

### 1. Cart Management
- **CartProvider**: State management for cart items using Provider pattern
- **CartItem Model**: Data structure for cart items with medicine details
- **Add to Cart**: Button on medicine cards to add items to cart
- **Cart Screen**: Displays cart items with quantity controls and total calculation

### 2. Order Creation
- **OrderService**: Handles API communication for order operations
- **Checkout Screen**: Collects shipping information and payment method
- **API Integration**: Creates orders using the provided endpoint

### 3. Data Models
- **CartItem**: Contains medicine ID, name, price, quantity, etc.
- **Order**: Contains shipping address, payment method, items, etc.

## How to Use

### Adding Items to Cart
1. Navigate to the home screen
2. Click "Add to Cart" button on any medicine card
3. Items are automatically added to the cart
4. Cart badge shows current item count

### Viewing Cart
1. Click the cart icon in the bottom navigation
2. View all cart items with quantities and prices
3. Adjust quantities using +/- buttons
4. Clear cart using the delete icon

### Creating an Order
1. In the cart screen, click "Proceed to Checkout"
2. Fill in shipping information:
   - Shipping address (required)
   - Phone number (required)
3. Select payment method:
   - Cash on Delivery
   - Credit Card
   - Debit Card
   - Mobile Money
4. Add optional notes
5. Click "Place Order"

## API Endpoint Details

### Order Creation
- **URL**: `POST https://shebaai.pythonanywhere.com/api/orders/create/`
- **Headers**: 
  - `Content-Type: application/json`
  - `Authorization: Bearer {token}` (when authentication is implemented)

### Request Body Format
```json
{
  "shipping_address": "123 Main St, City",
  "phone_number": "1234567890",
  "payment_method": "cash_on_delivery",
  "notes": "Please deliver in the evening",
  "items": [
    {
      "medicine_id": 6,
      "quantity": 1
    }
  ]
}
```

### Response Format
```json
{
  "success": true,
  "data": {
    "id": 1,
    "shipping_address": "123 Main St, City",
    "phone_number": "1234567890",
    "payment_method": "cash_on_delivery",
    "notes": "Please deliver in the evening",
    "items": [...],
    "total_amount": 25.99,
    "status": "pending",
    "created_at": "2024-01-01T12:00:00Z"
  },
  "message": "Order created successfully"
}
```

## Testing the Order Creation

### Demo Mode
1. Go to the cart screen when it's empty
2. Click "Add Demo Items (Testing)" button
3. This adds sample medicines to test the order flow
4. Proceed to checkout and test the order creation

### Real API Testing
1. Add actual medicines from the home screen
2. Fill in real shipping information
3. The app will make a real API call to create the order

## Error Handling

The app handles various error scenarios:
- Network errors
- API validation errors
- Invalid form data
- Server errors

Error messages are displayed to the user via SnackBar notifications.

## Future Enhancements

- **Authentication**: Add user authentication and token management
- **Order History**: View and track previous orders
- **Payment Processing**: Integrate real payment gateways
- **Order Status Updates**: Real-time order status tracking
- **Push Notifications**: Order confirmation and status updates

## Dependencies Added

- `provider: ^6.1.1` - State management
- `http: ^1.1.0` - API communication (already present)

## File Structure

```
lib/
├── core/
│   ├── order_service.dart      # API service for orders
│   ├── cart_provider.dart      # Cart state management
│   ├── models.dart             # Data models
│   └── api_config.dart         # API configuration
├── screens/
│   ├── cart/
│   │   ├── cart_screen.dart    # Cart display and management
│   │   └── checkout_screen.dart # Order creation form
│   └── home/
│       └── home_screen.dart    # Medicine listing with add to cart
└── main.dart                   # App entry with providers
```

## Getting Started

1. Run `flutter pub get` to install dependencies
2. The app is ready to use with the order creation functionality
3. Test by adding items to cart and creating orders
4. Monitor API calls in the debug console

## Notes

- The current implementation doesn't require authentication (authToken is null)
- All API calls include proper error handling and user feedback
- The cart state persists during the app session
- The order creation follows the exact API specification provided
