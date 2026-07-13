-- Add custom start and end dates to class terms to support classes/majors starting at different times
ALTER TABLE class_terms ADD COLUMN start_date DATE;
ALTER TABLE class_terms ADD COLUMN end_date DATE;
