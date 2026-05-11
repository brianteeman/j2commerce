--
-- Fix ITEMS_LOOP placement in seeded invoice templates so order items render
-- correctly (issue #712).
--
-- The empty [ITEMS_LOOP] [/ITEMS_LOOP] marker placed before the items <table>
-- caused EmailHelper::wrapItemRowInLoop() to pick the inner <tr> nested inside
-- the [IFNOT:ITEM_IMAGE] fallback table when scanning for the item row. The
-- chosen loop boundary was wrong, so per-item expansion duplicated only the
-- fallback row, both IF and IFNOT image blocks rendered together, and the
-- qty/price/total cells fell outside the loop body and were stripped as
-- unprocessed tags.
--
-- This migration moves the ITEMS_LOOP markers directly around the item <tr>
-- of templates id=1 (Packing Slip), id=2 (Invoice), and id=4 (Receipt Full
-- Page). Template id=3 (Receipt Thermal) already has correct ITEMS_LOOP
-- placement and is not touched.
--
-- Also replaces the hard-coded "Invoice" h1 banner in the Modern Invoice
-- Template (id=2) with [SITENAME] so the store/company name appears above
-- the order number.
--
-- Each UPDATE is guarded by LIKE checks so user-edited templates (those that
-- no longer contain the canonical seed body) are NOT touched.
--
-- All string literals and CONCAT/CHAR results are coerced to
-- utf8mb4_unicode_ci to match the `body` column collation. Without this,
-- MySQL throws "Illegal mix of collations" during the inner REPLACE.
--
-- Tracking: GitHub issue #712
--

-- id=1 Packing Slip: remove empty marker + wrap item <tr> with ITEMS_LOOP
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(
       REPLACE(
           REPLACE(`body`,
               '[ITEMS_LOOP] [/ITEMS_LOOP]' COLLATE utf8mb4_unicode_ci,
               '' COLLATE utf8mb4_unicode_ci
           ),
           CONCAT('<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 0 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top; width: 60px;">[IF:ITEM_IMAGE] <img class="item-img"') COLLATE utf8mb4_unicode_ci,
           CONCAT('[ITEMS_LOOP]<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 0 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top; width: 60px;">[IF:ITEM_IMAGE] <img class="item-img"') COLLATE utf8mb4_unicode_ci
       ),
       CONCAT('</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Total Items Count -->') COLLATE utf8mb4_unicode_ci,
       CONCAT('</tr>[/ITEMS_LOOP]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Total Items Count -->') COLLATE utf8mb4_unicode_ci
   ),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%[ITEMS_LOOP] [/ITEMS_LOOP]%'
   AND `body` LIKE '%<img class="item-img"%';

-- id=2 Invoice: remove empty marker + wrap item <tr> with ITEMS_LOOP
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(
       REPLACE(
           REPLACE(`body`,
               '[ITEMS_LOOP] [/ITEMS_LOOP]' COLLATE utf8mb4_unicode_ci,
               '' COLLATE utf8mb4_unicode_ci
           ),
           CONCAT('<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 0 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top; width: 60px;">[IF:ITEM_IMAGE]') COLLATE utf8mb4_unicode_ci,
           CONCAT('[ITEMS_LOOP]<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 0 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top; width: 60px;">[IF:ITEM_IMAGE]') COLLATE utf8mb4_unicode_ci
       ),
       CONCAT('</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Totals -->', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 0 20px; border-top: 2px solid #e5e7eb;" colspan="5">') COLLATE utf8mb4_unicode_ci,
       CONCAT('</tr>[/ITEMS_LOOP]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Totals -->', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 0 20px; border-top: 2px solid #e5e7eb;" colspan="5">') COLLATE utf8mb4_unicode_ci
   ),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 2
   AND `body` LIKE '%[ITEMS_LOOP] [/ITEMS_LOOP]%';

-- id=2 Invoice: replace hard-coded "Invoice" h1 with [SITENAME]
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
           '>Invoice</h1>' COLLATE utf8mb4_unicode_ci,
           '>[SITENAME]</h1>' COLLATE utf8mb4_unicode_ci),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 2
   AND `body` LIKE '%>Invoice</h1>%';

-- id=4 Receipt (Full Page): remove empty marker + wrap item <tr> with ITEMS_LOOP
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(
       REPLACE(
           REPLACE(`body`,
               '[ITEMS_LOOP] [/ITEMS_LOOP]' COLLATE utf8mb4_unicode_ci,
               '' COLLATE utf8mb4_unicode_ci
           ),
           CONCAT('<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top;"><span style="font-size: 14px; font-weight: 600; color: #1f2937;">[ITEM_NAME]</span>') COLLATE utf8mb4_unicode_ci,
           CONCAT('[ITEMS_LOOP]<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 12px 20px; border-top: 1px solid #f3f4f6; vertical-align: top;"><span style="font-size: 14px; font-weight: 600; color: #1f2937;">[ITEM_NAME]</span>') COLLATE utf8mb4_unicode_ci
       ),
       CONCAT('</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Totals -->', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 0 20px; border-top: 2px solid #e5e7eb;" colspan="4">') COLLATE utf8mb4_unicode_ci,
       CONCAT('</tr>[/ITEMS_LOOP]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Totals -->', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<td style="padding: 0 20px; border-top: 2px solid #e5e7eb;" colspan="4">') COLLATE utf8mb4_unicode_ci
   ),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 4
   AND `body` LIKE '%[ITEMS_LOOP] [/ITEMS_LOOP]%';
