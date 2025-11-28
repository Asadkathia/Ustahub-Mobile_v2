-- Seed location-aware banners and onboarding slides
-- This migration assumes that the corresponding images have already been uploaded
-- to Supabase Storage under the `banners` and `service-images/onboarding` buckets.

WITH new_banners AS (
    INSERT INTO public.banners (image, title, link, city, country, is_active, display_order)
    VALUES
        -- Global banners (visible everywhere)
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/global/1.png',
         'Global Experts On Demand', NULL, NULL, 'all', true, 10),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/global/4.png',
         'Fast Help Anywhere', NULL, 'all', 'all', true, 20),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/global/7.png',
         'Book Services Worldwide', NULL, NULL, 'all', true, 30),

        -- Russia-specific banners
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/russia/2.png',
         'Уютный дом в Москве', NULL, 'Moscow', 'RU', true, 40),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/russia/5.png',
         'Сервис для вашей техники', NULL, 'Saint Petersburg', 'RU', true, 50),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/russia/8.png',
         'Красота и уход рядом', NULL, NULL, 'RU', true, 60),

        -- Uzbekistan-specific banners
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/uzbekistan/3.png',
         'Xizmatlar Toshkentda', NULL, 'Tashkent', 'UZ', true, 70),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/uzbekistan/6.png',
         'Maishiy texnika ustalari', NULL, 'Samarkand', 'UZ', true, 80),
        ('https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/uzbekistan/9.png',
         'Goʻzallik va salomatlik', NULL, NULL, 'UZ', true, 90)
    RETURNING id, title
)
INSERT INTO public.onboarding_slides (
    banner_id,
    title,
    subtitle,
    description,
    locale,
    audience,
    cta_text,
    cta_route,
    image_override,
    city,
    country,
    is_active,
    display_order
)
VALUES
    -- Global slides
    (
        (SELECT id FROM new_banners WHERE title = 'Global Experts On Demand'),
        'Discover trusted pros worldwide',
        'Book licensed experts in minutes, wherever you are',
        'Browse 40+ vetted home, beauty, and tech services available across every city.',
        'en',
        'all',
        'Continue',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/global/5.png',
        NULL,
        'all',
        true,
        10
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Fast Help Anywhere'),
        'Track every booking with ease',
        'Stay informed from request to completion with real-time updates',
        'Instant notifications and live chat keep you connected with your specialists anywhere.',
        'en',
        'all',
        'Continue',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/global/6.png',
        NULL,
        'all',
        true,
        20
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Book Services Worldwide'),
        'Flexible packages for every need',
        'Compare plans, pricing, and availability instantly',
        'Premium, standard, or basic—choose what fits and confirm in just a few taps.',
        'en',
        'all',
        'Continue',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/global/7.png',
        NULL,
        'all',
        true,
        30
    ),

    -- Russia slides
    (
        (SELECT id FROM new_banners WHERE title = 'Уютный дом в Москве'),
        'Домашний сервис в Москве',
        'Локальные мастера, готовые помочь сегодня',
        'Выбирайте проверенных специалистов для уборки, ремонта и доставки прямо из приложения.',
        'ru',
        'consumer',
        'Продолжить',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/russia/10.png',
        'Moscow',
        'RU',
        true,
        40
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Сервис для вашей техники'),
        'Ремонт без ожидания',
        'Срочные заявки на уход за техникой и домом',
        'Следите за статусом заказа, общайтесь с мастером и оплачивайте онлайн.',
        'ru',
        'consumer',
        'Продолжить',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/russia/12.png',
        'Saint Petersburg',
        'RU',
        true,
        50
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Красота и уход рядом'),
        'Здоровье и красота у вас дома',
        'Найдите парикмахеров, массажистов и косметологов рядом с вами',
        'Все специалисты подтверждены, а цены и отзывы доступны заранее.',
        'ru',
        'consumer',
        'Продолжить',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/russia/13.png',
        NULL,
        'RU',
        true,
        60
    ),

    -- Uzbekistan slides
    (
        (SELECT id FROM new_banners WHERE title = 'Xizmatlar Toshkentda'),
        'Toshkentda uy xizmatlari',
        'Mahalliy usta va servislar bitta ilovada',
        'Tozalash, taʼmirlash va yetkazib berish boʼyicha eng yaxshi ustalarni tanlang.',
        'uz',
        'consumer',
        'Davom etish',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/uzbekistan/6.png',
        'Tashkent',
        'UZ',
        true,
        70
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Maishiy texnika ustalari'),
        'Ustozlar bir zumda',
        'Kundalik texnikangiz uchun tezkor yordam',
        'Buyurtmani kuzating, ustoz bilan bogʼlaning va xavfsiz toʼlovni ilova orqali amalga oshiring.',
        'uz',
        'consumer',
        'Davom etish',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/uzbekistan/7.png',
        'Samarkand',
        'UZ',
        true,
        80
    ),
    (
        (SELECT id FROM new_banners WHERE title = 'Goʻzallik va salomatlik'),
        'Goʻzallik va salomatlik xizmatlari',
        'Professional stilist va terapevtlar uyga kelishadi',
        'Jadvalingizga mos keladigan vaqtni tanlang va mutaxassislar tezda yetib kelishadi.',
        'uz',
        'consumer',
        'Davom etish',
        '/login',
        'https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/service-images/onboarding/uzbekistan/9.png',
        NULL,
        'UZ',
        true,
        90
    );

