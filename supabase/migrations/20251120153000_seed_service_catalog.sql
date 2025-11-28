-- Seed canonical service categories for providers
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'services_name_key'
      AND table_name = 'services'
      AND table_schema = 'public'
  ) THEN
    ALTER TABLE public.services
      ADD CONSTRAINT services_name_key UNIQUE (name);
  END IF;
END$$;

INSERT INTO public.services (id, name, description, icon, image, is_active)
VALUES
  ('1a5a01f2-44e1-47ac-a9ac-04fcb85b460d', 'Home Cleaning', 'Recurring or one-time housekeeping, dusting, mopping, and tidying for apartments and villas.', 'home_cleaning', NULL, TRUE),
  ('6d44ad0c-78a2-43d5-a6ce-b0e0819e9d2d', 'Deep Cleaning', 'Intensive kitchen, bathroom, and upholstery cleaning with steam/sanitization equipment.', 'deep_cleaning', NULL, TRUE),
  ('78d10033-7f0f-4d45-a837-b24f4689da6d', 'Plumbing', 'Leak repairs, pipe fitting, fixture installation, and emergency plumbing support.', 'plumbing', NULL, TRUE),
  ('263bba44-cf36-4ca7-86d5-c53afb82a7db', 'Electrical Repair', 'Wiring fixes, appliance installation, lighting upgrades, and safety inspections.', 'electrical', NULL, TRUE),
  ('2a8e6c4e-eb8b-41c2-9a71-9e3fd5907fbc', 'AC Service & Repair', 'Split/duct AC servicing, gas refills, compressor fixes, and annual maintenance.', 'ac_service', NULL, TRUE),
  ('89d5e75b-7625-4851-bfba-0b2c1bdcede2', 'Appliance Repair', 'Diagnosis and repair for refrigerators, washing machines, cookers, and small appliances.', 'appliance', NULL, TRUE),
  ('9f81ec36-a6bf-418f-8b9b-a714e659bd89', 'Carpentry & Handyman', 'Furniture assembly, custom shelving, door/window fixes, and minor renovation tasks.', 'carpentry', NULL, TRUE),
  ('bc05e1fa-c847-48a8-90f6-8b7d85bf04bc', 'Painting & Waterproofing', 'Interior/exterior painting, textured finishes, and damp-proof coating solutions.', 'painting', NULL, TRUE),
  ('0924d7cd-03ce-4694-b19a-3f8412893750', 'Pest Control', 'Termite, rodent, bedbug, and mosquito treatments with eco-friendly chemicals.', 'pest_control', NULL, TRUE),
  ('36ba8445-6292-4c1a-86aa-3f91a84c284a', 'Moving & Packing', 'End-to-end relocation support, packing materials, and inter-city logistics.', 'moving', NULL, TRUE)
ON CONFLICT (name) DO UPDATE
SET
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  image = EXCLUDED.image,
  is_active = EXCLUDED.is_active;

