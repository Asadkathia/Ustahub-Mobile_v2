import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../design_system/colors/app_colors_v2.dart';

class ServiceIconConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const ServiceIconConfig({
    required this.icon,
    required this.iconColor,
    this.backgroundColor = Colors.white,
  });
}

class ServiceIconHelper {
  static const ServiceIconConfig _defaultConfig = ServiceIconConfig(
    icon: FluentIcons.apps_24_filled,
    iconColor: AppColorsV2.primary,
    backgroundColor: Colors.white,
  );

  // Pool of fallback icons & colors so remaining services still get
  // visually distinct icons without manual overrides for every name.
  static const List<IconData> _iconPool = [
    FluentIcons.toolbox_24_filled,
    FluentIcons.wrench_screwdriver_24_filled,
    FluentIcons.vehicle_car_profile_24_filled,
    FluentIcons.vehicle_truck_profile_24_filled,
    FluentIcons.briefcase_24_filled,
    FluentIcons.briefcase_medical_24_filled,
    FluentIcons.calendar_ltr_24_filled,
    FluentIcons.clock_alarm_24_filled,
    FluentIcons.chat_help_24_filled,
    FluentIcons.people_community_24_filled,
    FluentIcons.food_cake_24_filled,
    FluentIcons.food_24_filled,
    FluentIcons.paint_brush_24_filled,
    FluentIcons.eraser_24_filled,
    FluentIcons.dumbbell_24_filled,
    FluentIcons.shield_task_24_filled,
    FluentIcons.shield_checkmark_24_filled,
    FluentIcons.wallet_credit_card_24_filled,
    FluentIcons.document_text_24_filled,
    FluentIcons.document_bullet_list_24_filled,
    FluentIcons.slide_multiple_24_filled,
    FluentIcons.desktop_24_filled,
    FluentIcons.phone_24_filled,
    FluentIcons.wifi_1_24_filled,
    FluentIcons.weather_sunny_24_filled,
    FluentIcons.weather_snowflake_24_filled,
    FluentIcons.weather_rain_showers_day_24_filled,
    FluentIcons.leaf_three_24_filled,
    FluentIcons.window_24_filled,
    FluentIcons.home_24_filled,
    FluentIcons.building_home_24_filled,
    FluentIcons.building_retail_24_filled,
    FluentIcons.key_24_filled,
    FluentIcons.camera_24_filled,
    FluentIcons.video_clip_multiple_24_filled,
    FluentIcons.book_open_24_filled,
    FluentIcons.book_question_mark_24_filled,
    FluentIcons.person_24_filled,
    FluentIcons.person_support_24_filled,
  ];

  static const List<Color> _iconColorPool = [
    Color(0xFF00ACC1),
    Color(0xFF42A5F5),
    Color(0xFF5E35B1),
    Color(0xFFE91E63),
    Color(0xFFFFB300),
    Color(0xFF8E24AA),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFFF57C00),
    Color(0xFF6D4C41),
    Color(0xFF00897B),
    Color(0xFF558B2F),
  ];

  static final Map<String, ServiceIconConfig> _exactOverrides = {
    'window & glass services': ServiceIconConfig(
      icon: FluentIcons.panel_top_gallery_24_filled,
      iconColor: Color(0xFF00ACC1),
      backgroundColor: Color(0xFFE0F7FA),
    ),
    'wedding services': ServiceIconConfig(
      icon: FluentIcons.ribbon_24_filled,
      iconColor: Color(0xFFC2185B),
      backgroundColor: Color(0xFFFCE4EC),
    ),
    'web & graphic design': ServiceIconConfig(
      icon: FluentIcons.design_ideas_24_filled,
      iconColor: Color(0xFF5E35B1),
      backgroundColor: Color(0xFFEDE7F6),
    ),
    'videographers': ServiceIconConfig(
      icon: FluentIcons.video_clip_multiple_24_filled,
      iconColor: Color(0xFF039BE5),
      backgroundColor: Color(0xFFE1F5FE),
    ),
    'veterinarians': ServiceIconConfig(
      icon: FluentIcons.animal_cat_24_filled,
      iconColor: Color(0xFF8E24AA),
      backgroundColor: Color(0xFFF3E5F5),
    ),
    'tuition & educational coaching': ServiceIconConfig(
      icon: FluentIcons.book_question_mark_24_filled,
      iconColor: Color(0xFF558B2F),
      backgroundColor: Color(0xFFE8F5E9),
    ),
    'travel agents & tour operators': ServiceIconConfig(
      icon: FluentIcons.airplane_24_filled,
      iconColor: Color(0xFF00897B),
      backgroundColor: Color(0xFFE0F2F1),
    ),
    'towing services': ServiceIconConfig(
      icon: FluentIcons.vehicle_truck_profile_24_filled,
      iconColor: Color(0xFF546E7A),
      backgroundColor: Color(0xFFECEFF1),
    ),
    'tire & battery services': ServiceIconConfig(
      icon: FluentIcons.vehicle_car_profile_24_filled,
      iconColor: Color(0xFFF57C00),
      backgroundColor: Color(0xFFFFF3E0),
    ),
    'tailoring & alteration services': ServiceIconConfig(
      icon: FluentIcons.cut_24_filled,
      iconColor: Color(0xFFD81B60),
      backgroundColor: Color(0xFFFCE4EC),
    ),
    'solar panel installation': ServiceIconConfig(
      icon: FluentIcons.weather_sunny_24_filled,
      iconColor: Color(0xFFFBC02D),
      backgroundColor: Color(0xFFFFF8E1),
    ),
    'security & cctv installation': ServiceIconConfig(
      icon: FluentIcons.shield_keyhole_24_filled,
      iconColor: Color(0xFF1E88E5),
      backgroundColor: Color(0xFFE3F2FD),
    ),
    'roofing': ServiceIconConfig(
      icon: FluentIcons.home_24_filled,
      iconColor: Color(0xFF6D4C41),
      backgroundColor: Color(0xFFD7CCC8),
    ),
    'real estate services': ServiceIconConfig(
      icon: FluentIcons.building_bank_24_filled,
      iconColor: Color(0xFF37474F),
      backgroundColor: Color(0xFFECEFF1),
    ),
    'plumbing': ServiceIconConfig(
      icon: FluentIcons.tap_double_24_filled,
      iconColor: Color(0xFF00ACC1),
      backgroundColor: Color(0xFFE0F7FA),
    ),
    'photographers': ServiceIconConfig(
      icon: FluentIcons.camera_sparkles_24_filled,
      iconColor: Color(0xFF8E24AA),
      backgroundColor: Color(0xFFF3E5F5),
    ),
    'pet grooming services': ServiceIconConfig(
      icon: FluentIcons.animal_dog_24_filled,
      iconColor: Color(0xFF43A047),
      backgroundColor: Color(0xFFE8F5E9),
    ),
    'pest control': ServiceIconConfig(
      icon: FluentIcons.alert_24_filled,
      iconColor: Color(0xFF558B2F),
      backgroundColor: Color(0xFFE8F5E9),
    ),
    'painting services': ServiceIconConfig(
      icon: FluentIcons.paint_brush_24_filled,
      iconColor: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFCE4EC),
    ),
    'painting & waterproofing services': ServiceIconConfig(
      icon: FluentIcons.weather_rain_showers_day_24_filled,
      iconColor: Color(0xFF2196F3),
      backgroundColor: Color(0xFFE3F2FD),
    ),
  };

  static ServiceIconConfig getConfig(String? serviceName) {
    final key = serviceName?.toLowerCase().trim() ?? '';

    if (key.isNotEmpty && _exactOverrides.containsKey(key)) {
      return _exactOverrides[key]!;
    }

    return _matchByKeyword(key);
  }

  static ServiceIconConfig _matchByKeyword(String key) {
    if (key.contains('electric')) {
      return ServiceIconConfig(
        icon: FluentIcons.flash_24_filled,
        iconColor: Color(0xFFFFB300),
        backgroundColor: Color(0xFFFFF3E0),
      );
    }
    if (key.contains('plumb')) {
      return ServiceIconConfig(
        icon: FluentIcons.wrench_screwdriver_24_filled,
        iconColor: Color(0xFF26C6DA),
        backgroundColor: Color(0xFFE0F7FA),
      );
    }
    if (key.contains('ac') || key.contains('refrigerator') || key.contains('cool')) {
      return ServiceIconConfig(
        icon: FluentIcons.weather_snowflake_24_filled,
        iconColor: Color(0xFF42A5F5),
        backgroundColor: Color(0xFFE3F2FD),
      );
    }
    if (key.contains('gas')) {
      return ServiceIconConfig(
        icon: FluentIcons.fire_24_filled,
        iconColor: Color(0xFFBA68C8),
        backgroundColor: Color(0xFFF3E5F5),
      );
    }
    if (key.contains('clean')) {
      return ServiceIconConfig(
        icon: FluentIcons.broom_24_filled,
        iconColor: Color(0xFF66BB6A),
        backgroundColor: Color(0xFFE8F5E9),
      );
    }
    if (key.contains('paint')) {
      return ServiceIconConfig(
        icon: FluentIcons.paint_bucket_24_filled,
        iconColor: Color(0xFFF06292),
        backgroundColor: Color(0xFFFCE4EC),
      );
    }
    if (key.contains('garden') || key.contains('landscap')) {
      return ServiceIconConfig(
        icon: FluentIcons.leaf_three_24_filled,
        iconColor: Color(0xFF43A047),
        backgroundColor: Color(0xFFE8F5E9),
      );
    }
    if (key.contains('security') || key.contains('cctv')) {
      return ServiceIconConfig(
        icon: FluentIcons.shield_task_24_filled,
        iconColor: Color(0xFF1E88E5),
        backgroundColor: Color(0xFFE3F2FD),
      );
    }
    if (key.contains('roof')) {
      return ServiceIconConfig(
        icon: FluentIcons.home_24_filled,
        iconColor: Color(0xFF6D4C41),
        backgroundColor: Color(0xFFD7CCC8),
      );
    }
    if (key.contains('travel') || key.contains('tour')) {
      return ServiceIconConfig(
        icon: FluentIcons.airplane_24_filled,
        iconColor: Color(0xFF00897B),
        backgroundColor: Color(0xFFE0F2F1),
      );
    }
    if (key.contains('water')) {
      return ServiceIconConfig(
        icon: FluentIcons.water_24_filled,
        iconColor: Color(0xFF26C6DA),
        backgroundColor: Color(0xFFE0F7FA),
      );
    }
    if (key.contains('repair') || key.contains('service')) {
      return ServiceIconConfig(
        icon: FluentIcons.toolbox_24_filled,
        iconColor: Color(0xFF42A5F5),
        backgroundColor: Color(0xFFE3F2FD),
      );
    }

    // Fallback: deterministic mapping from name -> icon/color so
    // every remaining service still gets a unique-ish visual.
    return _hashedConfig(key);
  }

  static ServiceIconConfig _hashedConfig(String key) {
    if (key.isEmpty) return _defaultConfig;

    final hash = key.codeUnits.fold<int>(0, (prev, char) => prev + char);
    final icon = _iconPool[hash % _iconPool.length];
    final color = _iconColorPool[hash % _iconColorPool.length];

    return ServiceIconConfig(
      icon: icon,
      iconColor: color,
      backgroundColor: Colors.white,
    );
  }
}

