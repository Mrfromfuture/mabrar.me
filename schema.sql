-- =====================================================================
-- Phase 2 schema. Run ONCE in Supabase: SQL Editor -> New query -> Run.
-- It only ADDS things. It does not touch your existing rows.
-- Admin rule used here: any logged-in (authenticated) user is the admin.
-- Keep public sign-ups OFF in Authentication settings so only you exist.
-- If your existing "projects" policies use a different admin check, change
-- the "to authenticated" policies below to match it.
-- =====================================================================

-- 1) Extra case-study columns on projects
alter table public.projects add column if not exists audience text;
alter table public.projects add column if not exists outcome  text;

-- 2) Site settings (contact details, vision, mission, SEO, social links)
create table if not exists public.site_settings (
  key text primary key,
  value text not null default '',
  updated_at timestamptz not null default now()
);

-- 3) Services
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text,
  description text,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

-- 4) FAQs
create table if not exists public.faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

-- 5) Testimonials (shown publicly only if published AND permission confirmed)
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(),
  author_name text not null,
  author_role text,
  quote text not null,
  permission_confirmed boolean not null default false,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

-- 6) Technology logos for the moving strip
create table if not exists public.tech_logos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text not null,
  link_url text,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

-- 7) Client inquiries (private)
create table if not exists public.inquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  phone text,
  company text,
  service text,
  message text not null,
  budget text,
  timeline text,
  reference_link text,
  status text not null default 'New'
    check (status in ('New','In Review','Contacted','In Progress','Closed')),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------
alter table public.site_settings enable row level security;
alter table public.services      enable row level security;
alter table public.faqs          enable row level security;
alter table public.testimonials  enable row level security;
alter table public.tech_logos    enable row level security;
alter table public.inquiries     enable row level security;

-- Public READ (only what is meant to be public)
drop policy if exists "public read settings" on public.site_settings;
create policy "public read settings" on public.site_settings for select to anon, authenticated using (true);

drop policy if exists "public read services" on public.services;
create policy "public read services" on public.services for select to anon using (published);

drop policy if exists "public read faqs" on public.faqs;
create policy "public read faqs" on public.faqs for select to anon using (published);

drop policy if exists "public read testimonials" on public.testimonials;
create policy "public read testimonials" on public.testimonials for select to anon using (published and permission_confirmed);

drop policy if exists "public read logos" on public.tech_logos;
create policy "public read logos" on public.tech_logos for select to anon using (published);

-- Admin: full access
drop policy if exists "admin all settings" on public.site_settings;
create policy "admin all settings" on public.site_settings for all to authenticated using (true) with check (true);
drop policy if exists "admin all services" on public.services;
create policy "admin all services" on public.services for all to authenticated using (true) with check (true);
drop policy if exists "admin all faqs" on public.faqs;
create policy "admin all faqs" on public.faqs for all to authenticated using (true) with check (true);
drop policy if exists "admin all testimonials" on public.testimonials;
create policy "admin all testimonials" on public.testimonials for all to authenticated using (true) with check (true);
drop policy if exists "admin all logos" on public.tech_logos;
create policy "admin all logos" on public.tech_logos for all to authenticated using (true) with check (true);

-- Inquiries: the public may ONLY insert (never read). Admin may read/update/delete.
drop policy if exists "public insert inquiries" on public.inquiries;
create policy "public insert inquiries" on public.inquiries for insert to anon
  with check (
    status = 'New'
    and char_length(name) between 1 and 120
    and char_length(email) between 5 and 200
    and char_length(message) between 10 and 5000
    and (phone is null or char_length(phone) <= 40)
    and (company is null or char_length(company) <= 160)
    and (service is null or char_length(service) <= 160)
    and (budget is null or char_length(budget) <= 120)
    and (timeline is null or char_length(timeline) <= 120)
    and (reference_link is null or char_length(reference_link) <= 500)
  );
drop policy if exists "admin all inquiries" on public.inquiries;
create policy "admin all inquiries" on public.inquiries for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- Starting content (taken from your requirements document). Edit in admin.
-- ---------------------------------------------------------------------
insert into public.site_settings (key, value) values
 ('phone','03206421287'),
 ('phone_link','+923206421287'),
 ('whatsapp','923206421287'),
 ('email','memrabrar@gmail.com'),
 ('site_url','https://mabrar.me'),
 ('vision','To become a trusted and innovative software house that empowers individuals, startups, and businesses to turn their ideas into practical digital solutions. We aim to make modern technology more accessible through reliable websites, intelligent applications, and customized software that helps our clients grow, work smarter, and compete in an increasingly digital world.'),
 ('mission','Our mission is to deliver practical, user-focused, and affordable digital solutions by combining modern development technologies, AI-assisted tools, and thoughtful problem-solving. We aim to understand each client''s unique needs, build solutions that address real problems, maintain transparent communication, and continuously improve our skills and services. Through quality work and long-term client relationships, we strive to help businesses and individuals achieve their digital goals.'),
 ('values',
  'Innovation|Explore useful technologies and modern development approaches.' || E'\n' ||
  'Reliability|Build, test, and maintain solutions responsibly.' || E'\n' ||
  'Client Focus|Understand each client''s goals before proposing a solution.' || E'\n' ||
  'Transparency|Communicate scope, limitations, pricing, and timelines clearly.' || E'\n' ||
  'Accessibility|Make practical digital solutions available to a broader range of clients.' || E'\n' ||
  'Continuous Improvement|Learn, adapt, and improve our work as technology evolves.')
on conflict (key) do nothing;

insert into public.services (title, category, description, sort_order, published)
select * from (values
 ('Website development','Websites','Business and corporate sites, portfolios, online stores, restaurant and school websites, landing pages and custom websites built to your requirements.',1,true),
 ('Web application development','Web apps','Custom web applications, admin panels and content management systems, dashboards, and booking or inquiry systems.',2,true),
 ('Mobile application development','Mobile','Mobile apps built to your requirements, working prototypes and MVPs, and integrations where technically feasible.',3,true),
 ('AI-powered solutions and automation','AI','AI features for websites and apps, workflow automation and integrations, and custom digital tools for your business needs.',4,true),
 ('Custom projects','Custom','Bring a personal idea or a business problem. We review each request for feasibility, scope, budget and technical needs.',5,true),
 ('Website support','Support','Maintenance, bug fixing, content updates, performance and SEO improvements, and new features.',6,true)
) as v(title,category,description,sort_order,published)
where not exists (select 1 from public.services);
