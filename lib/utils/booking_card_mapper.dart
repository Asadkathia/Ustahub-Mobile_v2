class BookingCardMapper {
  static Map<String, dynamic> toLegacyForProvider(
    Map<String, dynamic> card,
  ) {
    final scheduled = card['scheduled'] ?? {};
    final consumer = card['counterparty'] ?? {};
    final service = card['service'] ?? {};

    return {
      'id': card['id'],
      'booking_id': card['bookingNumber'],
      'consumer_id': consumer['id'] ?? card['consumerId'],
      'provider_id': card['provider_id'] ?? card['providerId'],
      'service_id': service['id'] ?? card['serviceId'],
      'address_id': card['address_id'] ?? card['addressId'],
      'booking_date': scheduled['date'],
      'booking_time': scheduled['time'],
      'status': card['status'],
      'note': card['note'],
      'otp': card['otp'],
      'remark': card['remark'],
      'created_at': card['createdAt'] ?? card['created_at'],
      'updated_at': card['updatedAt'] ?? card['updated_at'],
      // Use 'consumer' key for provider view (they see the consumer)
      'consumer': {
        'id': consumer['id'],
        'name': consumer['name'],
        'profile_photo_url': consumer['avatar'],
      },
      'service': {
        'id': service['id'],
        'name': service['name'],
        'image': service['image'],
      },
      'address': {
        'id': card['address_id'],
        'address': card['address_full'] ?? card['addressPreview'],
        'city': card['address_city'],
        'state': card['address_state'],
        'country': null,
        'postal_code': card['address_postal'],
      },
    };
  }

  static Map<String, dynamic> toLegacyForConsumer(
    Map<String, dynamic> card,
  ) {
    final scheduled = card['scheduled'] ?? {};
    final provider = card['counterparty'] ?? {};
    final service = card['service'] ?? {};

    return {
      'id': card['id'],
      'booking_id': card['bookingNumber'],
      'consumer_id': card['consumer_id'] ?? card['consumerId'],
      'provider_id': provider['id'] ?? card['providerId'],
      'service_id': service['id'] ?? card['serviceId'],
      'address_id': card['address_id'] ?? card['addressId'],
      'booking_date': scheduled['date'],
      'booking_time': scheduled['time'],
      'status': card['status'],
      'note': card['note'],
      'otp': card['otp'],
      'remark': card['remark'],
      'created_at': card['createdAt'] ?? card['created_at'],
      'updated_at': card['updatedAt'] ?? card['updated_at'],
      // Use 'provider' key for consumer view (they see the provider)
      'provider': {
        'id': provider['id'],
        'name': provider['name'],
        'profile_photo_url': provider['avatar'],
      },
      'service': {
        'id': service['id'],
        'name': service['name'],
        'image': service['image'],
      },
      'address': {
        'id': card['address_id'] ?? card['addressId'],
        'address': card['address_full'] ?? card['addressPreview'],
        'city': card['address_city'],
        'state': card['address_state'],
        'country': null,
        'postal_code': card['address_postal'],
      },
    };
  }
}

