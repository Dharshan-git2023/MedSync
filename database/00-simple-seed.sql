-- Minimal seed for development (users, hospitals, feedback)

INSERT INTO users (user_id, email, password_hash, role, full_name, phone_number, is_active)
VALUES
  ('u_admin1','admin1@medsync.com','$2b$12$4IvMw8hevF2QOHC/m8b2iOF1RO8NPqTRssZzjFOJrSzy0NnQQk3qC','admin','Admin One','+10000000001',true)
ON CONFLICT DO NOTHING;

INSERT INTO hospitals (hospital_id, hospital_name, address, contact_number, license_number, is_active)
VALUES
  ('h1','Central City Hospital','123 Main St, Central City','+14045550101','LIC-CCH-0001',false)
ON CONFLICT DO NOTHING;

INSERT INTO feedbacks (feedback_id, name, email, phone, message)
VALUES
  ('f1', 'Alice Reviewer', 'alice@example.com', '+14045559900', 'Great platform, would love more telemedicine features.'),
  ('f2', 'Bob Patient', 'bob@example.com', '+14045559800', 'I had trouble with appointment booking, please help.')
ON CONFLICT DO NOTHING;
