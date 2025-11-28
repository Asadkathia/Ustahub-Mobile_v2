-- Seed data for development
-- This file is executed after migrations during `supabase db reset`

-- Insert sample services
INSERT INTO public.services (id, name, description, icon, is_active) VALUES
  (gen_random_uuid(), 'Appliances', 'Home appliance repair and maintenance', 'svg_appliances', true),
  (gen_random_uuid(), 'Plumbing', 'Plumbing services and repairs', 'svg_plumbing', true),
  (gen_random_uuid(), 'Electrical', 'Electrical installation and repair', 'svg_electrical', true),
  (gen_random_uuid(), 'Cleaning', 'Home and office cleaning services', 'svg_cleaning', true),
  (gen_random_uuid(), 'Carpentry', 'Furniture and woodwork services', 'svg_carpentry', true)
ON CONFLICT DO NOTHING;

-- Insert sample banners (if needed)
-- INSERT INTO public.banners (id, image, title, link, is_active, display_order) VALUES
--   (gen_random_uuid(), 'https://example.com/banner1.jpg', 'Banner 1', 'https://example.com', true, 1)
-- ON CONFLICT DO NOTHING;


