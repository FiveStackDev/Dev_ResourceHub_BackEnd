-- Insert IT Equipment
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('Laptop', 'Electronics & IT', 10, 'Good', 'IT Department', TRUE),
('Desktop Computer', 'Electronics & IT', 15, 'Good', 'IT Department', TRUE),
('Projector', 'Electronics & IT', 5, 'Good', 'Conference Room', TRUE),
('Mouse', 'Electronics & IT', 25, 'New', 'IT Department', TRUE),
('Keyboard', 'Electronics & IT', 25, 'New', 'IT Department', TRUE),
('Router', 'Electronics & IT', 10, 'Good', 'IT Department', TRUE),
('Webcam', 'Electronics & IT', 8, 'Used', 'IT Department', TRUE),
('Headset', 'Electronics & IT', 12, 'Good', 'IT Department', TRUE),
('External Hard Drive', 'Electronics & IT', 6, 'Good', 'IT Department', TRUE),
('USB Flash Drive', 'Electronics & IT', 30, 'New', 'IT Department', TRUE);

-- Insert Office Supplies
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('Printer', 'Office Supplies', 5, 'New', 'Office', TRUE),
('Scanner', 'Office Supplies', 3, 'Good', 'Office', TRUE),
('Paper Clips', 'Office Supplies', 100, 'New', 'Office', TRUE),
('Stapler', 'Office Supplies', 20, 'Good', 'Office', TRUE),
('Folders', 'Office Supplies', 50, 'New', 'Office', TRUE),
('Sticky Notes', 'Office Supplies', 200, 'New', 'Office', TRUE),
('Whiteboard Markers', 'Office Supplies', 30, 'New', 'Conference Room', TRUE),
('Binders', 'Office Supplies', 15, 'Good', 'Office', TRUE),
('Scissors', 'Office Supplies', 10, 'Good', 'Office', TRUE),
('Tape Dispensers', 'Office Supplies', 12, 'New', 'Office', TRUE);

-- Insert Furniture
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('Office Chair', 'Furniture', 20, 'Used', 'Office', TRUE),
('Desk', 'Furniture', 15, 'Good', 'Office', TRUE),
('Bookshelf', 'Furniture', 10, 'New', 'Office', TRUE),
('Conference Table', 'Furniture', 2, 'Good', 'Conference Room', TRUE),
('Filing Cabinet', 'Furniture', 10, 'Good', 'Office', TRUE),
('Sofa', 'Furniture', 5, 'Used', 'Lounge', TRUE),
('Meeting Table', 'Furniture', 4, 'New', 'Meeting Room', TRUE),
('Coffee Table', 'Furniture', 8, 'Good', 'Lounge', TRUE),
('Cabinet', 'Furniture', 6, 'Used', 'Office', TRUE),
('Standing Desk', 'Furniture', 3, 'New', 'Office', TRUE);

-- Insert Electrical Appliances
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('Air Conditioner', 'Electrical Appliances', 8, 'Good', 'Office', TRUE),
('Microwave', 'Electrical Appliances', 4, 'Good', 'Kitchen', TRUE),
('Refrigerator', 'Electrical Appliances', 3, 'Used', 'Kitchen', TRUE),
('Electric Kettle', 'Electrical Appliances', 10, 'New', 'Kitchen', TRUE),
('Toaster', 'Electrical Appliances', 5, 'Good', 'Kitchen', TRUE),
('Coffee Machine', 'Electrical Appliances', 2, 'Good', 'Kitchen', TRUE),
('Fan', 'Electrical Appliances', 12, 'New', 'Office', TRUE),
('Air Purifier', 'Electrical Appliances', 6, 'Good', 'Office', TRUE),
('Heater', 'Electrical Appliances', 7, 'Used', 'Office', TRUE),
('Projector Screen', 'Electrical Appliances', 4, 'Good', 'Conference Room', TRUE);

-- Insert Machinery & Tools
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('Drilling Machine', 'Machinery & Tools', 3, 'Fair', 'Workshop', TRUE),
('Welding Machine', 'Machinery & Tools', 2, 'Good', 'Workshop', TRUE),
('Lathe Machine', 'Machinery & Tools', 4, 'Good', 'Workshop', TRUE),
('Angle Grinder', 'Machinery & Tools', 5, 'Used', 'Workshop', TRUE),
('Circular Saw', 'Machinery & Tools', 3, 'Good', 'Workshop', TRUE),
('CNC Machine', 'Machinery & Tools', 1, 'Good', 'Workshop', TRUE),
('Hand Drill', 'Machinery & Tools', 10, 'New', 'Workshop', TRUE),
('Toolbox', 'Machinery & Tools', 20, 'Used', 'Workshop', TRUE),
('Pressure Washer', 'Machinery & Tools', 4, 'Good', 'Workshop', TRUE),
('Compressor', 'Machinery & Tools', 2, 'Good', 'Workshop', TRUE);

-- Insert Miscellaneous
INSERT INTO assets (asset_name, category, quantity, condition_type, location, is_available)
VALUES 
('First Aid Kit', 'Miscellaneous', 10, 'Good', 'Office', TRUE),
('Fire Extinguisher', 'Miscellaneous', 8, 'Good', 'Office', TRUE),
('Cleaning Supplies', 'Miscellaneous', 30, 'New', 'Office', TRUE),
('Trash Can', 'Miscellaneous', 20, 'Good', 'Office', TRUE),
('Umbrellas', 'Miscellaneous', 15, 'Good', 'Lobby', TRUE),
('Broom', 'Miscellaneous', 10, 'Used', 'Janitor', TRUE),
('Flashlight', 'Miscellaneous', 25, 'New', 'Office', TRUE),
('Safety Signs', 'Miscellaneous', 10, 'New', 'Workshop', TRUE),
('Posters', 'Miscellaneous', 50, 'New', 'Office', TRUE),
('Event Decorations', 'Miscellaneous', 5, 'Used', 'Storage', TRUE);
