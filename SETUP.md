# Setup guide: mabrar.me (static site + Supabase + Netlify)

Plain HTML. No npm, no build step, no framework. Supabase is the only backend.

## Files

| File | Purpose |
| --- | --- |
| `index.html` | Public site (the design you approved, plus content loaded from Supabase) |
| `admin.html` | Admin panel at `/admin.html` |
| `privacy.html`, `terms.html` | Legal pages (see the warning in section 9) |
| `schema.sql` | New database tables and security rules. Run once |
| `robots.txt`, `sitemap.xml` | Search engine files |
| `_headers` | Netlify security headers and `noindex` for the admin page |

Both `index.html` and `admin.html` contain the same config block with the Supabase URL and the **publishable** key. Never put a secret or `service_role` key in any file.

## 1. Supabase (about 10 minutes)

1. **Run the schema.** Open **SQL Editor → New query**, paste all of `schema.sql`, and click **Run**. It only adds tables, policies and starting content. It does not change your existing project rows.
2. **Create the admin user.** **Authentication → Users → Add user**, enter your email and a strong password, and auto-confirm the email.
3. **Turn off public sign-ups.** In the Authentication settings, disable "Allow new users to sign up". The security rules treat any logged-in user as the admin, so only your user must exist.
4. **Check your older `projects` rules.** `schema.sql` uses "logged-in user = admin". If your existing `projects` policy uses a different rule, make sure the same user passes it.
5. **Site URL.** **Authentication → URL Configuration:** Site URL `https://mabrar.me`, and add `https://mabrar.me/**` and `https://www.mabrar.me/**` to Redirect URLs.
6. **Storage.** Confirm the bucket `project-media` exists, is public, and allows JPG, PNG and WebP up to 5 MB. SVG is not allowed, so logos must be PNG or WebP.

## 2. Deploy to Netlify

**Drag and drop:** put all files in one folder and drop it on <https://app.netlify.com> via **Add new project → Deploy manually**.

**Git:** push the files to a repository, import it in Netlify, leave **Build command** empty and set **Publish directory** to `.`.

## 3. Connect mabrar.me

1. Netlify: **Domain management → Add a domain → `mabrar.me`**.
2. Either use Netlify DNS (**Options → Set up Netlify DNS**, then replace the nameservers at your registrar), or keep your DNS provider and add:
   - `A` record, name `@`, value `75.2.60.5` (or an ALIAS/ANAME to `apex-loadbalancer.netlify.com` if your provider supports it)
   - `CNAME` record, name `www`, value `your-site-name.netlify.app`
3. Wait for DNS (minutes to 24 hours), then **Domain management → HTTPS → Verify DNS configuration / Provision certificate**.
4. Set one primary domain so the other redirects to it.

Netlify's current instructions: <https://docs.netlify.com/domains/configure-domains/configure-external-dns/>

## 4. First-time content

1. Open `https://mabrar.me/admin.html` and log in.
2. **Site settings:** check phone, call-link phone, WhatsApp, email, then add your brand name, search title and description, and social links. Blank social links stay hidden on the site.
3. **Services:** six starting services are already published. Edit or unpublish them.
4. **Projects:** add real projects only. Publish client work only with permission.
5. **FAQs and testimonials:** add only real answers and real feedback. A testimonial cannot be published until you tick the permission box.
6. **Logos:** upload official PNG or WebP logos for tools you really use. Download each from its brand's official press or brand page. Do not redraw them, and do not add a logo that suggests a partnership you do not have. Use logos with a transparent or light background (dark mode shows them on white chips).

## 5. What is editable and what is not

Editable in the admin panel: projects and case studies (with images), services, FAQs, testimonials, logos, contact details, social links, vision, mission, brand values, home intro text, about intro text, and search title and description. Client inquiries are managed under **Inquiries**.

Not editable there: the home headline ("We build apps and AI products for startups.") and the menu labels. The headline is built word by word for its animation, so changing it needs a code edit. Image descriptions for project images use the project title.

## 6. Test checklist (do every step; nothing here has been run against your live project)

1. Public site loads at `https://mabrar.me`, no console errors.
2. **Our work** shows "New projects are coming soon." until you publish a project.
3. Admin: wrong password is refused; correct password logs in; Log out works.
4. Add a project with a cover image, tick Published, save. Reload the public site: the card appears.
5. Unpublish it: the card disappears. Delete the test project.
6. Settings: change the phone, save, reload the public Contact page.
7. Contact page: send a test project request. Then check **Inquiries** shows it, with the "New" count on the tab.
8. Change the inquiry status to each of the five statuses and reload to confirm it stays.
9. Log out and confirm `inquiries` cannot be read: in a private window, the public site must never show inquiry data.
10. Logos: upload two logos, publish them, check the strip scrolls without gaps on desktop and phone.
11. Phone settings with "reduce motion" on: the strip should stop and wrap, and other animations stop.
12. Keyboard only: Tab through the Contact form and admin forms, and check the focus outline is visible.

## 7. Backups and recovery

What Supabase's own documentation says (checked October 22, 2026): Pro plan projects keep 7 days of daily database backups, Team 14 days. The Free plan has no restorable backups, and Supabase recommends Free projects export their data with the CLI `db dump` command and keep copies off-site. **Database backups never include files in Storage**, only a record of their names.

Because of that, do this regardless of plan:

1. **Database export (monthly, and before big changes):** install the Supabase CLI, then run `supabase db dump --db-url "<connection string from Project Settings → Database>" -f backup.sql`. Keep the file somewhere other than Supabase (for example an encrypted drive). The connection string contains your database password: never commit it to a public repository.
2. **Quick table export:** in **Table Editor**, export `projects`, `services`, `faqs`, `testimonials`, `tech_logos`, `site_settings` and `inquiries` as CSV.
3. **Images:** download the contents of the `project-media` bucket regularly (the dashboard lets you download files; the CLI can copy a bucket too). Also keep your original images and logo files.
4. **Restore test:** at least once, create a second free Supabase project and run `backup.sql` in its SQL Editor to confirm the export really restores. A backup you never restored is a guess.
5. **Pro plan:** consider it once real client inquiries arrive. It costs from about $25 per month (check Supabase pricing).

Restoring: run `schema.sql` is **not** needed on a restored dump. For a rebuilt project, import the SQL dump first, then re-upload images to a bucket named `project-media` with the same paths.

## 8. Search (SEO and GEO) and analytics

Already in place: canonical URL, social-sharing tags, business structured data (ProfessionalService with your real phone and email), FAQ structured data built from your published FAQs, a sitemap, `robots.txt`, `noindex` on the admin page, descriptive image text, and a fast page with no tracking scripts.

Google Search Console: add `https://mabrar.me` as a property, verify it (DNS record is easiest), then submit `https://mabrar.me/sitemap.xml`.

**Known limit:** the site shows its sections (Services, Our work, About, Contact) with `#` links on one page, so search engines treat them as one page. Individual project pages with their own addresses would need either a `project.html?slug=...` page (still no build step) or a build step. This has not been built; decide before more projects are added.

**Analytics: not installed.** `privacy.html` says so. If you add a privacy-friendly tool (for example Cloudflare Web Analytics or Plausible), update the privacy page first, and test that the page stays fast.

## 9. Not done yet, and things to verify

- **Email notifications for new inquiries: not built.** Inquiries appear in the admin panel with a "new" count when you log in. Email alerts need a mail service account (such as Resend) and a Supabase Edge Function that holds a secret key. Do not put that key in these files.
- **Spam protection:** the form uses a hidden field and server-side length limits only. If spam arrives, add a CAPTCHA service (such as Cloudflare Turnstile), which needs server-side checking.
- **Legal pages:** `privacy.html` and `terms.html` describe what the site does today. Have them reviewed by someone qualified in your location before relying on them.
- **Brand name:** `[YOUR COMPANY]` is still in the page title, logo and footer. Nothing was renamed. When you choose a name, replace it in the files and in Site settings → Brand name.
- **Admin rule:** any logged-in user counts as admin. Keep sign-ups off.
- **Recurring costs:** domain renewal; Supabase Free is $0 but has no restorable backups; Supabase Pro from about $25 per month; Netlify (check its pricing page for your usage); an email service if you add notifications.
