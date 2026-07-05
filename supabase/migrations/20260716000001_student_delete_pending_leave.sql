-- Allow students to delete/cancel their own pending leave requests
DROP POLICY IF EXISTS "User deletes own pending request" ON leave_requests;
CREATE POLICY "User deletes own pending request" ON leave_requests
  FOR DELETE
  USING (requester_id = auth.uid() AND status = 'pending');
