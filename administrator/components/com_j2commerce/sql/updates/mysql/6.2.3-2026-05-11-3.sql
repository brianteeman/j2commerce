--
-- Repair corrupted emoji + unicode glyphs in seeded invoice templates that
-- were stored as `?` characters because the installer connection charset
-- was not utf8mb4 when invoicetemplates.sql ran (issue #870 follow-up).
--
-- Prior migration 6.2.2-2026-04-27.sql repaired ONLY the HTML comment dividers
-- containing em-dashes (e.g. `<!-- ... ??? Modern Template -->`). This migration
-- repairs the remaining body content corruptions: 📦 📞 ✓ ⚠ • © em-dash glyphs.
--
-- Each UPDATE uses CONVERT(UNHEX('<utf8mb4 hex>') USING utf8mb4) to inject the
-- correct UTF-8 byte sequence regardless of this file's own encoding, then
-- COLLATE utf8mb4_unicode_ci to match the `body` column collation. Without
-- the COLLATE clause MySQL throws "Illegal mix of collations" during REPLACE.
-- LIKE guards make each statement idempotent so user-edited rows are not
-- touched.
--
-- UTF-8 hex used:
--   📦 = F09F93A6   📞 = F09F939E   📄 = F09F9384
--   ⚠  = E29AA0     ✓ = E29C93     • = E280A2
--   —  = E28094     © = C2A9
--
-- Tracking: GitHub issue #870 (follow-up to invoice/email template seed)
--

-- id=1 (Packing Slip) HTML comment header em-dash
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '<!-- J2Commerce Packing Slip ??? Modern Template -->' COLLATE utf8mb4_unicode_ci,
       CONCAT('<!-- J2Commerce Packing Slip ', CONVERT(UNHEX('E28094') USING utf8mb4), ' Modern Template -->') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%<!-- J2Commerce Packing Slip ??? Modern Template -->%';

-- id=1 banner box icon 📦
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'font-size: 24px; color: #ffffff;">????</td>' COLLATE utf8mb4_unicode_ci,
       CONCAT('font-size: 24px; color: #ffffff;">', CONVERT(UNHEX('F09F93A6') USING utf8mb4), '</td>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%font-size: 24px; color: #ffffff;">????</td>%';

-- id=1 shipping phone icon 📞
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '<br>???? [SHIPPING_PHONE]' COLLATE utf8mb4_unicode_ci,
       CONCAT('<br>', CONVERT(UNHEX('F09F939E') USING utf8mb4), ' [SHIPPING_PHONE]') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%<br>???? [SHIPPING_PHONE]%';

-- id=1 "Packed ???" check mark ✓
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'Packed ???</td>' COLLATE utf8mb4_unicode_ci,
       CONCAT('Packed ', CONVERT(UNHEX('E29C93') USING utf8mb4), '</td>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%Packed ???</td>%';

-- id=1 items fallback box icon 📦
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'color: #d1d5db;">????</td>' COLLATE utf8mb4_unicode_ci,
       CONCAT('color: #d1d5db;">', CONVERT(UNHEX('F09F93A6') USING utf8mb4), '</td>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%color: #d1d5db;">????</td>%';

-- id=1 Customer Note warning ⚠
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '">??? Customer Note</td>' COLLATE utf8mb4_unicode_ci,
       CONCAT('">', CONVERT(UNHEX('E29AA0') USING utf8mb4), ' Customer Note</td>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%">??? Customer Note</td>%';

-- id=1 footer © and • (combined replacement so anchors stay unique)
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'margin: 0;">?? [CURRENT_YEAR] [SITENAME] ??? [SITEURL]</p>' COLLATE utf8mb4_unicode_ci,
       CONCAT('margin: 0;">', CONVERT(UNHEX('C2A9') USING utf8mb4), ' [CURRENT_YEAR] [SITENAME] ', CONVERT(UNHEX('E280A2') USING utf8mb4), ' [SITEURL]</p>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%margin: 0;">?? [CURRENT_YEAR] [SITENAME] ??? [SITEURL]</p>%';

-- id=3 (Receipt Thermal) HTML comment header em-dash
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '<!-- J2Commerce Receipt ??? Thermal / POS Template -->' COLLATE utf8mb4_unicode_ci,
       CONCAT('<!-- J2Commerce Receipt ', CONVERT(UNHEX('E28094') USING utf8mb4), ' Thermal / POS Template -->') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 3
   AND `body` LIKE '%<!-- J2Commerce Receipt ??? Thermal / POS Template -->%';

-- id=4 (Receipt Full Page) HTML comment header em-dash
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '<!-- J2Commerce Receipt ??? Modern Template -->' COLLATE utf8mb4_unicode_ci,
       CONCAT('<!-- J2Commerce Receipt ', CONVERT(UNHEX('E28094') USING utf8mb4), ' Modern Template -->') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%<!-- J2Commerce Receipt ??? Modern Template -->%';

-- id=4 banner check ✓ (3 chars = `???`, distinct from id=1's 4-char `????`)
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'font-size: 24px; color: #ffffff;">???</td>' COLLATE utf8mb4_unicode_ci,
       CONCAT('font-size: 24px; color: #ffffff;">', CONVERT(UNHEX('E29C93') USING utf8mb4), '</td>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%font-size: 24px; color: #ffffff;">???</td>%';

-- id=4 Order date separator • bullet
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       '[ORDERID] ??? [ORDERDATE]' COLLATE utf8mb4_unicode_ci,
       CONCAT('[ORDERID] ', CONVERT(UNHEX('E280A2') USING utf8mb4), ' [ORDERDATE]') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%[ORDERID] ??? [ORDERDATE]%';

-- id=4 Payment received check ✓
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'text-align: center;">??? <strong>Payment received</strong>' COLLATE utf8mb4_unicode_ci,
       CONCAT('text-align: center;">', CONVERT(UNHEX('E29C93') USING utf8mb4), ' <strong>Payment received</strong>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%text-align: center;">??? <strong>Payment received</strong>%';

-- id=4 footer © and •
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       'margin: 0;">?? [CURRENT_YEAR] [SITENAME] ??? [SITEURL]</p>' COLLATE utf8mb4_unicode_ci,
       CONCAT('margin: 0;">', CONVERT(UNHEX('C2A9') USING utf8mb4), ' [CURRENT_YEAR] [SITENAME] ', CONVERT(UNHEX('E280A2') USING utf8mb4), ' [SITEURL]</p>') COLLATE utf8mb4_unicode_ci)
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%margin: 0;">?? [CURRENT_YEAR] [SITENAME] ??? [SITEURL]</p>%';
