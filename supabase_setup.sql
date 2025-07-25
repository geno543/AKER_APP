-- AKER Animal Rescue App - Supabase Database Setup
-- Run this script in your Supabase SQL Editor to create all necessary tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    profile_image_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    rescue_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create animal_reports table
CREATE TABLE IF NOT EXISTS public.animal_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    reporter_name TEXT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    animal_type TEXT NOT NULL CHECK (animal_type IN ('dog', 'cat', 'bird', 'wildlife', 'livestock', 'other')),
    animal_breed TEXT,
    condition TEXT NOT NULL CHECK (condition IN ('injured', 'sick', 'lost', 'trapped', 'abandoned', 'aggressive', 'dead')),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT NOT NULL,
    image_urls TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'reported' CHECK (status IN ('reported', 'in_progress', 'rescued', 'closed')),
    is_emergency BOOLEAN DEFAULT FALSE,
    contact_phone TEXT,
    contact_name TEXT,
    rescue_organization TEXT,
    rescue_contact TEXT,
    rescue_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create storage bucket for animal images
-- Note: If this fails, create the bucket manually in Supabase Dashboard:
-- 1. Go to Storage in your Supabase Dashboard
-- 2. Click "New bucket"
-- 3. Name it "animal-images"
-- 4. Set it as Public
-- 5. Click "Save"

-- Try to create bucket via SQL (may require superuser privileges)
DO $$
BEGIN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES (
        'animal-images', 
        'animal-images', 
        true,
        52428800, -- 50MB limit
        ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
    )
    ON CONFLICT (id) DO NOTHING;
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Could not create storage bucket via SQL. Please create it manually in the Supabase Dashboard.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating storage bucket: %. Please create it manually in the Supabase Dashboard.', SQLERRM;
END $$;

-- Add missing columns if they don't exist (for existing databases)
DO $$
BEGIN
    -- Add animal_breed column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'animal_breed' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN animal_breed TEXT;
    END IF;
    
    -- Add reporter_name column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'reporter_name' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN reporter_name TEXT;
    END IF;
    
    -- Add assigned_volunteer_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'assigned_volunteer_id' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN assigned_volunteer_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    END IF;
    
    -- Add assigned_volunteer_name column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'assigned_volunteer_name' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN assigned_volunteer_name TEXT;
    END IF;
    
    -- Add tags column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'tags' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN tags TEXT[] DEFAULT '{}';
    END IF;
    
    -- Add helpers_count column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'helpers_count' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN helpers_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add helper_ids column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'animal_reports' 
                   AND column_name = 'helper_ids' 
                   AND table_schema = 'public') THEN
        ALTER TABLE public.animal_reports ADD COLUMN helper_ids TEXT[] DEFAULT '{}';
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_animal_reports_location ON public.animal_reports USING GIST (ST_Point(longitude, latitude));
CREATE INDEX IF NOT EXISTS idx_animal_reports_status ON public.animal_reports(status);
CREATE INDEX IF NOT EXISTS idx_animal_reports_created_at ON public.animal_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_animal_reports_emergency ON public.animal_reports(is_emergency) WHERE is_emergency = true;
CREATE INDEX IF NOT EXISTS idx_animal_reports_reporter ON public.animal_reports(reporter_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animal_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
DROP POLICY IF EXISTS "Users can view all profiles" ON public.user_profiles;
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS policies for animal_reports
DROP POLICY IF EXISTS "Anyone can view reports" ON public.animal_reports;
CREATE POLICY "Anyone can view reports" ON public.animal_reports
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can create reports" ON public.animal_reports;
CREATE POLICY "Anyone can create reports" ON public.animal_reports
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update own reports" ON public.animal_reports;
CREATE POLICY "Users can update own reports" ON public.animal_reports
    FOR UPDATE USING (auth.uid() = reporter_id OR auth.uid() IS NULL);

DROP POLICY IF EXISTS "Users can delete own reports" ON public.animal_reports;
CREATE POLICY "Users can delete own reports" ON public.animal_reports
    FOR DELETE USING (auth.uid() = reporter_id OR auth.uid() IS NULL);

-- RLS policies for user_profiles
DROP POLICY IF EXISTS "Users can view all profiles" ON public.user_profiles;
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Storage policies for animal images
DROP POLICY IF EXISTS "Anyone can view animal images" ON storage.objects;
CREATE POLICY "Anyone can view animal images" ON storage.objects
    FOR SELECT USING (bucket_id = 'animal-images');

DROP POLICY IF EXISTS "Anyone can upload animal images" ON storage.objects;
CREATE POLICY "Anyone can upload animal images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'animal-images');

DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;
CREATE POLICY "Users can update own images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'animal-images' AND auth.uid()::text = (storage.foldername(name))[1]);

DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;
CREATE POLICY "Users can delete own images" ON storage.objects
    FOR DELETE USING (bucket_id = 'animal-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to list storage buckets (required for storage operations)
DROP POLICY IF EXISTS "Allow bucket listing" ON storage.buckets;
CREATE POLICY "Allow bucket listing" ON storage.buckets
    FOR SELECT USING (true);

-- Function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_animal_reports_updated_at ON public.animal_reports;
CREATE TRIGGER update_animal_reports_updated_at
    BEFORE UPDATE ON public.animal_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Insert some sample data for testing (optional)
-- Note: Sample data will only be inserted if users exist in auth.users table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM auth.users LIMIT 1) THEN
        INSERT INTO public.animal_reports (
            reporter_id,
            title,
            description,
            animal_type,
            condition,
            latitude,
            longitude,
            address,
            is_emergency,
            contact_phone,
            contact_name
        ) VALUES 
        (
            (SELECT id FROM auth.users LIMIT 1),
            'Injured Dog Found',
            'Found an injured dog near the main road. Appears to have a broken leg and needs immediate medical attention.',
            'dog',
            'injured',
            -1.2921,
            36.8219,
            'Nairobi CBD, Kenya',
            true,
            '+254700000000',
            'John Doe'
        ),
        (
            (SELECT id FROM auth.users LIMIT 1),
            'Lost Cat in Westlands',
            'Small orange cat, very friendly. Missing for 2 days. Owner is very worried.',
            'cat',
            'lost',
            -1.2630,
            36.8063,
            'Westlands, Nairobi, Kenya',
            false,
            '+254700000001',
            'Jane Smith'
        ),
        (
            (SELECT id FROM auth.users LIMIT 1),
            'Trapped Bird',
            'Bird trapped in netting at construction site. Unable to free itself.',
            'bird',
            'trapped',
            -1.3031,
            36.8441,
            'Karen, Nairobi, Kenya',
            false,
            '+254700000002',
            'Mike Johnson'
        )
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- Create a view for statistics
CREATE OR REPLACE VIEW public.rescue_statistics AS
SELECT 
    COUNT(*) as total_reports,
    COUNT(*) FILTER (WHERE status = 'rescued') as rescued_animals,
    COUNT(*) FILTER (WHERE status IN ('reported', 'in_progress')) as active_reports,
    COUNT(*) FILTER (WHERE is_emergency = true AND status != 'closed') as emergency_cases
FROM public.animal_reports;

-- Create function to get nearby reports using PostGIS
-- Drop existing function first to avoid return type conflicts
DROP FUNCTION IF EXISTS public.get_nearby_reports(double precision, double precision, double precision);

CREATE OR REPLACE FUNCTION public.get_nearby_reports(
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 10.0
)
RETURNS TABLE (
    id UUID,
    reporter_id UUID,
    reporter_name TEXT,
    title TEXT,
    description TEXT,
    animal_type TEXT,
    animal_breed TEXT,
    condition TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address TEXT,
    image_urls TEXT[],
    status TEXT,
    is_emergency BOOLEAN,
    contact_phone TEXT,
    contact_name TEXT,
    assigned_volunteer_id UUID,
    assigned_volunteer_name TEXT,
    tags TEXT[],
    helpers_count INTEGER,
    helper_ids TEXT[],
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    distance_km DOUBLE PRECISION
)
LANGUAGE SQL
AS $$
    SELECT 
        ar.id,
        ar.reporter_id,
        COALESCE(up.name, 'Anonymous') as reporter_name,
        ar.title,
        ar.description,
        ar.animal_type,
        ar.animal_breed,
        ar.condition,
        ar.latitude,
        ar.longitude,
        ar.address,
        ar.image_urls,
        ar.status,
        ar.is_emergency,
        ar.contact_phone,
        ar.contact_name,
        ar.assigned_volunteer_id,
        ar.assigned_volunteer_name,
        ar.tags,
        ar.helpers_count,
        ar.helper_ids,
        ar.created_at,
        ar.updated_at,
        ST_Distance(
            ST_Point(lng, lat)::geography,
            ST_Point(ar.longitude, ar.latitude)::geography
        ) / 1000 AS distance_km
    FROM public.animal_reports ar
    LEFT JOIN public.user_profiles up ON ar.reporter_id = up.id
    WHERE ST_DWithin(
        ST_Point(lng, lat)::geography,
        ST_Point(ar.longitude, ar.latitude)::geography,
        radius_km * 1000
    )
    ORDER BY distance_km ASC;
$$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.user_profiles TO anon, authenticated;
GRANT ALL ON public.animal_reports TO anon, authenticated;
GRANT SELECT ON public.rescue_statistics TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_nearby_reports TO anon, authenticated;

-- Success message
SELECT 'AKER database setup completed successfully!' as message;

-- IMPORTANT: If you're still getting "Bucket not found" errors:
-- 1. Go to your Supabase Dashboard
-- 2. Navigate to Storage section
-- 3. Click "New bucket"
-- 4. Create a bucket named "animal-images"
-- 5. Set it as Public
-- 6. Set file size limit to 50MB
-- 7. Set allowed MIME types to: image/jpeg, image/png, image/webp, image/gif
-- 8. Click "Save"
-- 9. Restart your Flutter app to test image uploads