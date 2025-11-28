-- Fix address default constraint to allow multiple non-default addresses
-- The unique constraint on (user_id, is_default) was causing issues when inserting
-- multiple addresses with is_default=false

-- Drop the existing unique constraint
ALTER TABLE public.addresses 
DROP CONSTRAINT IF EXISTS unique_default_address;

-- Create a partial unique index that only enforces uniqueness when is_default = true
-- This allows multiple addresses with is_default = false
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_default_address 
ON public.addresses(user_id) 
WHERE is_default = true;

-- The trigger function ensure_single_default_address() already handles
-- setting other addresses to false when a new default is set, so we keep that

