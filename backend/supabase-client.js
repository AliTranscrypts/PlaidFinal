const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL || 'https://gopghvkksnlzisvaazhl.supabase.co';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvcGdodmtrc25semlzdmFhemhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Njc0NDcsImV4cCI6MjA2NjQ0MzQ0N30.NbX1EP8x_wqzG15hVmXhWckBjPmqdGE__VfbEYgBkgY';

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey);

module.exports = supabase; 