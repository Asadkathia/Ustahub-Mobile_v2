# Quick Test Reference Card

## 🎯 Quick Access Routes

### Provider Portfolios
```dart
// View Portfolio Gallery
Get.to(() => PortfolioGalleryScreenV2(providerId: providerId));

// Add/Edit Portfolio (Provider only)
Get.to(() => AddEditPortfolioScreenV2(providerId: providerId));
```

### Price Comparison
```dart
// Create Quote Request (Consumer)
Get.to(() => CreateQuoteRequestScreenV2());

// Compare Quotes
Get.to(() => QuoteComparisonScreenV2(quoteRequestId: quoteRequestId));
```

### Advanced Search
```dart
// Advanced Search Screen
Get.to(() => AdvancedSearchScreenV2());
```

### Enhanced Reviews
```dart
// Enhanced Rating Screen (after booking)
Get.to(() => EnhancedRatingScreenV2(
  providerId: providerId,
  bookingId: bookingId,
));
```

---

## 📱 Testing Flow

### 1. Provider Portfolios (5 min)
1. Open any provider details → Scroll to Portfolio section
2. Tap "View All" → See gallery
3. (Provider) Add portfolio via account screen or direct navigation

### 2. Price Comparison (10 min)
1. (Consumer) Create quote request
2. (Provider) Respond to quote
3. (Consumer) Compare quotes and accept one

### 3. Advanced Search (5 min)
1. Open search → Apply filters
2. Test: Rating, Price, Distance, Verified, Available
3. Test sorting options

### 4. Enhanced Reviews (10 min)
1. (Consumer) Leave review with images
2. Vote review as helpful
3. (Provider) Respond to review
4. Filter reviews

---

## 🔍 Quick Database Checks

```sql
-- Portfolios count
SELECT COUNT(*) FROM provider_portfolios;

-- Active quote requests
SELECT COUNT(*) FROM quote_requests WHERE status = 'pending';

-- Reviews with images
SELECT COUNT(*) FROM ratings WHERE array_length(image_urls, 1) > 0;
```

---

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| Portfolios not loading | Check `portfolios` bucket exists |
| Quote requests fail | Verify RLS policies |
| Search returns empty | Check location permissions |
| Images not uploading | Verify storage permissions |

---

## 🎨 UI Entry Points to Add

If these don't exist, add navigation buttons:

1. **Provider Account Screen** → "Manage Portfolio" button
2. **Provider Details Screen** → "Request Quote" button (Consumer)
3. **Home Screen** → "Advanced Search" button
4. **Booking Complete Screen** → "Rate Provider" button

---

## ✅ Test Checklist

- [ ] Portfolios display on provider details
- [ ] Quote requests create successfully
- [ ] Search filters work
- [ ] Reviews with images submit
- [ ] Helpful votes work
- [ ] Provider responses appear

