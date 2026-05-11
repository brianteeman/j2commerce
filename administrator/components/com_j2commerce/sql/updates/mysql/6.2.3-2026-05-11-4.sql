--
-- Remove [IFNOT:ITEM_IMAGE] fallback block (📦 box icon) from seeded invoice
-- templates (issue #712 follow-up).
--
-- The fallback block's inner <table><tr><td>📦</td></tr></table> introduced a
-- nested <tr> that confused EmailHelper::wrapItemRowInLoop()'s tr-counting
-- walker, causing the items loop to wrap the wrong <tr>. Removing the block
-- eliminates the nested <tr> (so wrap detection always picks the correct outer
-- item row) AND drops the visible box icon that rendered below product images.
--
-- Two variants are removed per row: one with the proper 📦 utf8mb4 byte
-- sequence and one with the `????` corruption (issue #870) — so this works
-- regardless of whether the install ran with a utf8mb4 connection.
--
-- LIKE guards make this idempotent. Rows already cleaned are skipped.
--
-- All string operands are COLLATE utf8mb4_unicode_ci to match the `body`
-- column collation and avoid "Illegal mix of collations" errors during
-- REPLACE.
--
-- Tracking: GitHub issue #712
--

-- Variant A: block with real 📦 emoji (utf8mb4-installed rows)
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       CONCAT(' [IFNOT:ITEM_IMAGE]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<table border="0" cellspacing="0" cellpadding="0">', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<tbody>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<td style="width: 50px; height: 50px; background-color: #f3f4f6; border-radius: 6px; text-align: center; vertical-align: middle; font-size: 20px; color: #d1d5db;">',
              CONVERT(UNHEX('F09F93A6') USING utf8mb4),
              '</td>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</tbody>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</table>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '[/IFNOT:ITEM_IMAGE]') COLLATE utf8mb4_unicode_ci,
       '' COLLATE utf8mb4_unicode_ci),
       `body_json` = ''
 WHERE `invoice_type` IN ('invoice', 'packingslip')
   AND `body` LIKE '%[IFNOT:ITEM_IMAGE]%';

-- Variant B: block with corrupted `????` placeholder (latin1-installed rows)
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
       CONCAT(' [IFNOT:ITEM_IMAGE]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<table border="0" cellspacing="0" cellpadding="0">', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<tbody>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '<td style="width: 50px; height: 50px; background-color: #f3f4f6; border-radius: 6px; text-align: center; vertical-align: middle; font-size: 20px; color: #d1d5db;">????</td>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</tbody>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '</table>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4),
              '[/IFNOT:ITEM_IMAGE]') COLLATE utf8mb4_unicode_ci,
       '' COLLATE utf8mb4_unicode_ci),
       `body_json` = ''
 WHERE `invoice_type` IN ('invoice', 'packingslip')
   AND `body` LIKE '%[IFNOT:ITEM_IMAGE]%';

-- Defensive: re-attempt items <tr> wrap for any row that still has the empty
-- marker (covers installs that received earlier migration variants that
-- failed due to attribute-order mismatch in the original anchor). Shorter
-- cell-open anchor matches regardless of <img> attribute ordering.

-- id=1 Packing Slip
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
       CONCAT('</tr>', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Total Items Count -->') COLLATE utf8mb4_unicode_ci,
       CONCAT('</tr>[/ITEMS_LOOP]', CHAR(13 USING utf8mb4), CHAR(10 USING utf8mb4), '<!-- Total Items Count -->') COLLATE utf8mb4_unicode_ci
   ),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 1
   AND `body` LIKE '%[ITEMS_LOOP] [/ITEMS_LOOP]%';

-- id=2 Invoice
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

-- id=4 Receipt (Full Page)
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

-- id=2 Invoice: replace hard-coded "Invoice" h1 with [SITENAME] (idempotent)
UPDATE `#__j2commerce_invoicetemplates`
   SET `body` = REPLACE(`body`,
           '>Invoice</h1>' COLLATE utf8mb4_unicode_ci,
           '>[SITENAME]</h1>' COLLATE utf8mb4_unicode_ci),
       `body_json` = ''
 WHERE `j2commerce_invoicetemplate_id` = 2
   AND `body` LIKE '%>Invoice</h1>%';
