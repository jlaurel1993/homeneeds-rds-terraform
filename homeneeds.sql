-- HomeNeedsService.com Database
CREATE DATABASE IF NOT EXISTS homeneeds;
USE homeneeds;

-- ==============================
-- User Tables
-- ==============================
CREATE TABLE user (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(30),
  password_hash VARCHAR(255) NOT NULL,
  is_provider BOOLEAN DEFAULT 0,
  is_client BOOLEAN DEFAULT 1
);

-- ==============================
-- Provider & Client Profiles
-- ==============================
CREATE TABLE provider_profile (
  provider_id INT PRIMARY KEY,
  bio TEXT,
  hourly_rate DECIMAL(10,2),
  radius_miles DECIMAL(5,2),
  avg_rating DECIMAL(3,2) DEFAULT 0,
  rating_count INT DEFAULT 0,
  FOREIGN KEY (provider_id) REFERENCES user(user_id)
);

CREATE TABLE client_profile (
  client_id INT PRIMARY KEY,
  default_address_id INT,
  FOREIGN KEY (client_id) REFERENCES user(user_id)
);

-- ==============================
-- Service Categories & Offerings
-- ==============================
CREATE TABLE service_category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE
);

CREATE TABLE service_offering (
  offering_id INT AUTO_INCREMENT PRIMARY KEY,
  provider_id INT,
  category_id INT,
  title VARCHAR(255),
  description TEXT,
  price DECIMAL(10,2),
  FOREIGN KEY (provider_id) REFERENCES provider_profile(provider_id),
  FOREIGN KEY (category_id) REFERENCES service_category(category_id)
);

-- ==============================
-- Bookings
-- ==============================
CREATE TABLE booking (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT,
  offering_id INT,
  start_time DATETIME,
  end_time DATETIME,
  status ENUM('REQUESTED','ACCEPTED','CANCELLED','COMPLETED') DEFAULT 'REQUESTED',
  FOREIGN KEY (client_id) REFERENCES client_profile(client_id),
  FOREIGN KEY (offering_id) REFERENCES service_offering(offering_id)
);

-- ==============================
-- Jobs, Payments, Reviews
-- ==============================
CREATE TABLE job (
  job_id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT UNIQUE,
  provider_id INT,
  status ENUM('SCHEDULED','IN_PROGRESS','DONE') DEFAULT 'SCHEDULED',
  FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
  FOREIGN KEY (provider_id) REFERENCES provider_profile(provider_id)
);

CREATE TABLE payment (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  job_id INT UNIQUE,
  amount DECIMAL(10,2),
  status ENUM('PENDING','PAID','FAILED'),
  FOREIGN KEY (job_id) REFERENCES job(job_id)
);

CREATE TABLE review (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  job_id INT UNIQUE,
  reviewer_id INT,
  reviewee_id INT,
  rating INT CHECK(rating BETWEEN 1 AND 5),
  comment TEXT,
  FOREIGN KEY (job_id) REFERENCES job(job_id),
  FOREIGN KEY (reviewer_id) REFERENCES user(user_id),
  FOREIGN KEY (reviewee_id) REFERENCES user(user_id)
);

-- ==============================
-- Sample Data
-- ==============================
INSERT INTO user (first_name, last_name, email, phone, password_hash, is_provider, is_client) VALUES
('Joe', 'Plumber', 'joe@example.com', '9561111111', 'hash1', 1, 0),
('Jane', 'Cleaner', 'jane@example.com', '9562222222', 'hash2', 1, 0),
('Mike', 'Electric', 'mike@example.com', '9563333333', 'hash3', 1, 0),
('Paul', 'Client', 'paul@example.com', '9564444444', 'hash4', 0, 1),
('Kassie', 'Client', 'kassie@example.com', '9565555555', 'hash5', 0, 1),
('Joey', 'Client', 'joey@example.com', '9566666666', 'hash6', 0, 1);

INSERT INTO provider_profile (provider_id, bio, hourly_rate, radius_miles) VALUES
(1, 'Experienced plumber, can travel within 50 miles.', 40.00, 50),
(2, 'Home cleaner, flexible schedule, reliable.', 25.00, 20),
(3, 'HVAC and electric service expert.', 60.00, 40);

INSERT INTO client_profile (client_id) VALUES (4), (5), (6);

INSERT INTO service_category (name) VALUES ('Plumbing'), ('Cleaning'), ('HVAC');

INSERT INTO service_offering (provider_id, category_id, title, description, price) VALUES
(1, 1, 'Fix leaks and plumbing issues', 'Reliable plumbing services in Edinburg.', 50.00),
(2, 2, 'House cleaning service', 'Flexible home cleaning in McAllen.', 30.00),
(3, 3, 'AC and Heating service', 'Affordable HVAC service in Brownsville.', 70.00);
