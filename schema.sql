-- JointVault v1 database schema
-- Run this in Supabase SQL Editor after creating a project.

create extension if not exists "uuid-ossp";

create type app_role as enum ('admin','senior_rep','rep','read_only');
create type entity_type as enum ('hospital','surgeon','product','document','procedure','note','checklist');
create type procedure_category as enum ('primary_tha','anterior_tha','posterior_tha','revision_tha','dual_mobility','fracture_hemi','primary_tka','velys_tka','uni','revision_tka','distal_femur_replacement','hinged_knee','other');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  initials text not null,
  role app_role not null default 'rep',
  created_at timestamptz not null default now()
);

create table hospitals (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text,
  general_notes text,
  inventory_notes text,
  tray_notes text,
  contacts jsonb default '[]',
  custom_fields jsonb default '{}',
  archived boolean default false,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table surgeons (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  overview text,
  hospitals uuid[] default '{}',
  pinned_pearls text[] default '{}',
  custom_fields jsonb default '{}',
  archived boolean default false,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table procedures (
  id uuid primary key default uuid_generate_v4(),
  surgeon_id uuid references surgeons(id) on delete cascade,
  category procedure_category not null,
  title text not null,
  implants_used text[] default '{}',
  trays_to_open text[] default '{}',
  standby_trays text[] default '{}',
  surgical_technique jsonb default '[]',
  pearls text[] default '{}',
  draft boolean default false,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table products (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  notes text,
  faqs jsonb default '[]',
  pearls text[] default '{}',
  archived boolean default false,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table documents (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  storage_path text not null,
  file_type text,
  tags text[] default '{}',
  linked_entities jsonb default '[]',
  uploaded_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table comments (
  id uuid primary key default uuid_generate_v4(),
  entity entity_type not null,
  entity_id uuid not null,
  body text not null,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table favorites (
  user_id uuid references profiles(id) on delete cascade,
  entity entity_type not null,
  entity_id uuid not null,
  created_at timestamptz default now(),
  primary key (user_id, entity, entity_id)
);

create table activity_log (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id),
  action text not null,
  entity entity_type not null,
  entity_id uuid,
  details jsonb default '{}',
  created_at timestamptz default now()
);

create table version_history (
  id uuid primary key default uuid_generate_v4(),
  entity entity_type not null,
  entity_id uuid not null,
  changed_by uuid references profiles(id),
  before jsonb,
  after jsonb,
  created_at timestamptz default now()
);

create table offline_pins (
  user_id uuid references profiles(id) on delete cascade,
  entity entity_type not null,
  entity_id uuid not null,
  created_at timestamptz default now(),
  primary key (user_id, entity, entity_id)
);

-- Storage bucket recommendation:
-- Create a private bucket named jointvault-documents in Supabase Storage.

alter table profiles enable row level security;
alter table hospitals enable row level security;
alter table surgeons enable row level security;
alter table procedures enable row level security;
alter table products enable row level security;
alter table documents enable row level security;
alter table comments enable row level security;
alter table favorites enable row level security;
alter table activity_log enable row level security;
alter table version_history enable row level security;
alter table offline_pins enable row level security;

-- Basic team-wide access policies. Tighten later if needed.
create policy "profiles read team" on profiles for select to authenticated using (true);
create policy "profiles update self" on profiles for update to authenticated using (auth.uid() = id);

create policy "team read hospitals" on hospitals for select to authenticated using (true);
create policy "team write hospitals" on hospitals for all to authenticated using (true) with check (true);
create policy "team read surgeons" on surgeons for select to authenticated using (true);
create policy "team write surgeons" on surgeons for all to authenticated using (true) with check (true);
create policy "team read procedures" on procedures for select to authenticated using (true);
create policy "team write procedures" on procedures for all to authenticated using (true) with check (true);
create policy "team read products" on products for select to authenticated using (true);
create policy "team write products" on products for all to authenticated using (true) with check (true);
create policy "team read documents" on documents for select to authenticated using (true);
create policy "team write documents" on documents for all to authenticated using (true) with check (true);
create policy "team read comments" on comments for select to authenticated using (true);
create policy "team write comments" on comments for all to authenticated using (true) with check (true);
create policy "user favorites" on favorites for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "team read activity" on activity_log for select to authenticated using (true);
create policy "team write activity" on activity_log for insert to authenticated with check (true);
create policy "team read versions" on version_history for select to authenticated using (true);
create policy "team write versions" on version_history for insert to authenticated with check (true);
create policy "user offline pins" on offline_pins for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
