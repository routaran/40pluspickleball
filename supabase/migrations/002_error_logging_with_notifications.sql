-- Migration: Add Error Logging and Email Notifications
-- Version: 1.1 to 1.2
-- Description: Adds error_logs and email_queue tables with automatic admin notifications

-- =====================================================
-- ERROR_LOGS TABLE - System error tracking
-- =====================================================
CREATE TABLE IF NOT EXISTS error_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    error_type VARCHAR(50) NOT NULL CHECK (error_type IN ('auth', 'api', 'validation', 'system')),
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    user_id UUID REFERENCES users(id),
    event_id UUID REFERENCES events(id),
    browser_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id)
);

-- Index for performance when querying recent errors
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_error_logs_resolved ON error_logs(resolved, created_at DESC);

-- =====================================================
-- EMAIL_QUEUE TABLE - For admin notifications
-- =====================================================
CREATE TABLE IF NOT EXISTS email_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    error_log_id UUID REFERENCES error_logs(id),
    sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ,
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for processing pending emails
CREATE INDEX IF NOT EXISTS idx_email_queue_pending ON email_queue(sent, created_at) WHERE sent = false;

-- =====================================================
-- ERROR NOTIFICATION FUNCTION AND TRIGGER
-- =====================================================
CREATE OR REPLACE FUNCTION notify_admin_on_error()
RETURNS TRIGGER AS $$
DECLARE
    admin_email VARCHAR(255);
BEGIN
    -- Get admin email (first admin found)
    SELECT email INTO admin_email
    FROM users 
    WHERE role = 'admin' 
    LIMIT 1;
    
    -- If no admin found, try to get any organizer
    IF admin_email IS NULL THEN
        SELECT email INTO admin_email
        FROM users 
        WHERE role = 'organizer' 
        ORDER BY created_at
        LIMIT 1;
    END IF;
    
    -- Only create email queue entry if we have a recipient
    IF admin_email IS NOT NULL THEN
        INSERT INTO email_queue (
            to_email,
            subject,
            body,
            error_log_id,
            created_at
        ) VALUES (
            admin_email,
            'Error Alert: ' || NEW.error_type || ' error in 40+ Pickleball',
            'An error has occurred in the 40+ Pickleball application.' || E'\n\n' ||
            'Error Type: ' || NEW.error_type || E'\n' ||
            'Error Message: ' || NEW.error_message || E'\n\n' ||
            'Stack Trace: ' || E'\n' || COALESCE(NEW.stack_trace, 'No stack trace available') || E'\n\n' ||
            'Time: ' || NEW.created_at::text || E'\n' ||
            'User ID: ' || COALESCE(NEW.user_id::text, 'Not logged in') || E'\n' ||
            'Event ID: ' || COALESCE(NEW.event_id::text, 'No event context'),
            NEW.id,
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists (for re-running migration)
DROP TRIGGER IF EXISTS error_log_email_trigger ON error_logs;

-- Create trigger to send email notifications for errors
CREATE TRIGGER error_log_email_trigger
AFTER INSERT ON error_logs
FOR EACH ROW
EXECUTE FUNCTION notify_admin_on_error();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on new tables
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_queue ENABLE ROW LEVEL SECURITY;

-- Error logs - only admins can view, service role can insert
CREATE POLICY "Only admins can view error logs" ON error_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

-- Service role bypass for error log inserts (application can log errors)
CREATE POLICY "Service role can insert error logs" ON error_logs
    FOR INSERT WITH CHECK (true);

-- Email queue - only admins can view, service role can manage
CREATE POLICY "Only admins can view email queue" ON email_queue
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

-- Service role bypass for email queue management
CREATE POLICY "Service role can manage email queue" ON email_queue
    FOR ALL WITH CHECK (true);

-- =====================================================
-- MIGRATION NOTES
-- =====================================================
-- This migration adds error logging capabilities with automatic admin notifications.
-- 
-- To send actual emails, you'll need to:
-- 1. Create a Supabase Edge Function that monitors the email_queue table
-- 2. Configure an email service (SendGrid, Resend, etc.) in the Edge Function
-- 3. Process pending emails and mark them as sent
--
-- Alternative: Use Supabase Database Webhooks to call an external service
-- when new rows are inserted into error_logs.