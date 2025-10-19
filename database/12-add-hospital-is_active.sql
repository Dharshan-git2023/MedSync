-- Add is_active to hospitals if it does not exist (safe to run)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='hospitals' AND column_name='is_active'
  ) THEN
    ALTER TABLE hospitals ADD COLUMN is_active BOOLEAN DEFAULT true;
  END IF;
END$$;

-- Optional: set existing hospitals to active if desired
-- UPDATE hospitals SET is_active = true WHERE is_active IS NULL;
