-- "Section" read as unfamiliar academic jargon to admins; renaming the whole
-- concept to "Class" end-to-end (table, FK columns, indexes, RLS policies).

ALTER TABLE sections RENAME TO classes;
ALTER TABLE classes RENAME COLUMN section_code TO class_code;

ALTER TABLE enrollments RENAME COLUMN section_id TO class_id;
ALTER TABLE attendance RENAME COLUMN section_id TO class_id;

ALTER INDEX sections_course_id_idx RENAME TO classes_course_id_idx;
ALTER INDEX sections_semester_id_idx RENAME TO classes_semester_id_idx;
ALTER INDEX sections_teacher_id_idx RENAME TO classes_teacher_id_idx;
ALTER INDEX sections_program_idx RENAME TO classes_program_idx;
ALTER INDEX sections_schedule_idx RENAME TO classes_schedule_idx;
ALTER INDEX enrollments_section_id_idx RENAME TO enrollments_class_id_idx;
ALTER INDEX attendance_section_id_idx RENAME TO attendance_class_id_idx;

ALTER POLICY "Admin manages sections" ON classes RENAME TO "Admin manages classes";
ALTER POLICY "Teacher views own sections" ON classes RENAME TO "Teacher views own classes";
ALTER POLICY "Student views enrolled sections" ON classes RENAME TO "Student views enrolled classes";
