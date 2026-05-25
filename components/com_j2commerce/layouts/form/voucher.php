<?php
/**
 * @package     J2Commerce
 * @subpackage  com_j2commerce
 *
 * @copyright   (C)2024-2026 J2Commerce, LLC <https://www.j2commerce.com>
 * @license     GNU General Public License version 2 or later; see LICENSE.txt
 */

// phpcs:disable PSR1.Files.SideEffects
\defined('_JEXEC') or die;
// phpcs:enable PSR1.Files.SideEffects

use J2Commerce\Component\J2commerce\Administrator\Helper\CurrencyHelper;
use J2Commerce\Component\J2commerce\Site\Service\ProductLayoutService;
use Joomla\CMS\Factory;
use Joomla\CMS\Language\Text;
use Joomla\CMS\Router\Route;
use Joomla\CMS\Session\Session;

// Self-load com_j2commerce strings — layout may render on non-component pages (cart drawer, mini-cart, custom modules).
$lang = Factory::getApplication()->getLanguage();
$lang->load('com_j2commerce', JPATH_SITE)
    || $lang->load('com_j2commerce', JPATH_SITE . '/components/com_j2commerce');

// Self-register assets (once per request, no matter how many instances)
static $assetsRegistered = false;
if (!$assetsRegistered) {
    $doc = Factory::getApplication()->getDocument();
    $wa  = $doc->getWebAssetManager();
    $wa->registerAndUseScript('com_j2commerce.coupon-voucher', 'media/com_j2commerce/js/site/coupon-voucher.js', [], ['defer' => true], ['core']);
    $wa->registerAndUseStyle('com_j2commerce.coupon-voucher.css', 'media/com_j2commerce/css/site/coupon-voucher.css');
    $doc->addScriptOptions('j2commerce.couponVoucher', [
        'baseUrl'   => Route::_('index.php?option=com_j2commerce', false),
        'csrfToken' => Session::getFormToken(),
        'strings'   => [
            'enterCoupon'  => Text::_('COM_J2COMMERCE_ENTER_COUPON_CODE'),
            'applyCoupon'  => Text::_('COM_J2COMMERCE_APPLY_COUPON'),
            'couponCode'   => Text::_('COM_J2COMMERCE_COUPON_CODE'),
            'removeCoupon' => Text::_('COM_J2COMMERCE_REMOVE_COUPON'),
            'enterVoucher' => Text::_('COM_J2COMMERCE_ENTER_VOUCHER_CODE'),
            'applyVoucher' => Text::_('COM_J2COMMERCE_APPLY_VOUCHER'),
            'voucherCode'  => Text::_('COM_J2COMMERCE_VOUCHER_CODE'),
            'removeVoucher'=> Text::_('COM_J2COMMERCE_REMOVE_VOUCHER'),
            'remove'       => Text::_('COM_J2COMMERCE_REMOVE'),
        ],
    ]);
    Text::script('COM_J2COMMERCE_LOADING');
    $assetsRegistered = true;
}

// Normalize framework: caller passes 'framework' key from its own context
$rawFramework = $displayData['framework'] ?? 'bootstrap5';
$framework = ($rawFramework === 'uikit3' || $rawFramework === 'uikit') ? 'uikit' : 'bootstrap5';

// Compute discount label (framework-agnostic) — passed into framework files so they stay purely presentational
$voucherCode  = $displayData['voucherCode'] ?? '';
$showDiscount = !empty($displayData['showDiscount']);
$hasVoucher   = !empty($voucherCode);

$discountLabel = '';
if ($hasVoucher && $showDiscount) {
    static $voucherCache = [];

    if (!isset($voucherCache[$voucherCode])) {
        $voucherModel = Factory::getApplication()->bootComponent('com_j2commerce')
            ->getMVCFactory()->createModel('Voucher', 'Administrator', ['ignore_request' => true]);
        $voucherCache[$voucherCode] = $voucherModel?->getVoucher($voucherCode);
    }

    $voucherRecord = $voucherCache[$voucherCode];

    if ($voucherRecord && isset($voucherRecord->amount)) {
        $discountLabel = Text::sprintf('COM_J2COMMERCE_VOUCHER_BALANCE', CurrencyHelper::format((float) $voucherRecord->amount));
    }
}

$displayData['discountLabel'] = $discountLabel;

ProductLayoutService::setSubtemplateOverride($framework);
try {
    echo ProductLayoutService::renderLayout('form.voucher', $displayData);
} finally {
    ProductLayoutService::clearSubtemplateOverride();
}
