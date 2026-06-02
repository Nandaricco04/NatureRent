<?php
ob_start();
require_once __DIR__ . '/includes/auth.php';

$admin = $_SESSION['admin'];
$allowedPages = [
    'dashboard' => 'Dashboard',
    'users' => 'User Management',
    'owners' => 'Owner Management',
    'informasi' => 'Informasi',
    'kategori' => 'Kategori Alat',
    'transaksi' => 'Transaksi',
    'komplain' => 'Komplain',
    'pajak' => 'Pajak',
    'banner' => 'Banner Destinasi',
    'promosi' => 'Promosi Alat',
];

$page = $_GET['page'] ?? 'dashboard';

if (!array_key_exists($page, $allowedPages)) {
    $page = 'dashboard';
}

$pageTitle = $allowedPages[$page];
$breadcrumbTitle = $pageTitle;

$userAction = $_GET['action'] ?? '';

if ($page === 'users' && $userAction === 'add') {
    $breadcrumbTitle .= ' / TambahUser';
    $pageTitle = 'Tambah User';
} elseif ($page === 'users' && $userAction === 'edit') {
    $breadcrumbTitle .= ' / EditUser';
    $pageTitle = 'Edit User';
} elseif ($page === 'owners' && $userAction === 'detail') {
    $breadcrumbTitle .= ' / Verifikasi Owner';
    $pageTitle = 'Verifikasi Owner';
} elseif ($page === 'promosi' && $userAction === 'verif') {
    $pageTitle = 'Verifikasi Promosi Iklan';
} elseif ($page === 'pajak' && $userAction === 'verif') {
    $breadcrumbTitle .= ' / Verifikasi Pajak';
    $pageTitle = 'Verifikasi Pajak';
} elseif ($page === 'informasi' && $userAction === 'add') {
    $breadcrumbTitle .= ' / TambahInformasi';
    $pageTitle = 'Tambah Informasi';
} elseif ($page === 'informasi' && $userAction === 'edit') {
    $breadcrumbTitle .= ' / EditInformasi';
    $pageTitle = 'Edit Informasi';
}

?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle) ?> - NatureRent</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <?php if ($page === 'users'): ?>
        <link rel="stylesheet" href="assets/css/user_style.css">
    <?php endif; ?>
    <?php if ($page === 'owners'): ?>
        <link rel="stylesheet" href="assets/css/owners_style.css">
    <?php endif; ?>
    <?php if ($page === 'owners' && $userAction === 'detail'): ?>
        <link rel="stylesheet" href="assets/css/owner_verif_style.css">
    <?php endif; ?>
    <?php if ($page === 'banner'): ?>
        <link rel="stylesheet" href="assets/css/banner_style.css">
    <?php endif; ?>
    <?php if ($page === 'promosi'): ?>
        <link rel="stylesheet" href="assets/css/promosi_style.css">
    <?php endif; ?>
    <?php if ($page === 'promosi' && $userAction === 'verif'): ?>
        <link rel="stylesheet" href="assets/css/promosi_verif_style.css">
    <?php endif; ?>
    <?php if ($page === 'informasi'): ?>
    <link rel="stylesheet" href="assets/css/informasi_style.css">
    <?php endif; ?>
    <?php if ($page === 'pajak'): ?>
        <link rel="stylesheet" href="assets/css/user_style.css">
        <link rel="stylesheet" href="assets/css/owners_style.css">
        <link rel="stylesheet" href="assets/css/pajak_style.css">
    <?php endif; ?>

    <script src="https://cdn.jsdelivr.net/npm/iconify-icon@1.0.8/dist/iconify-icon.min.js"></script>
</head>
<body>
    <div class="admin-shell">
        <?php
        $activePage = $page;
        include __DIR__ . '/includes/sidebar.php';
        ?>

        <main class="admin-main">
            <header class="admin-topbar">
                <div>
                    <p class="breadcrumb">Admin / <?= htmlspecialchars($breadcrumbTitle) ?></p>
                    <h1 class="page-title"><?= htmlspecialchars($pageTitle) ?></h1>
                </div>

                <div class="admin-profile">
                    <div>
                        <?= htmlspecialchars($admin['name']) ?>
                        <span><?= htmlspecialchars($admin['role']) ?></span>
                    </div>
                </div>
            </header>

            <?php
            $pageFile = __DIR__ . "/pages/$page.php";

            if ($page === 'users' && $userAction === 'add') {
                $pageFile = __DIR__ . '/pages/user_add.php';
            } elseif ($page === 'users' && $userAction === 'edit') {
                $pageFile = __DIR__ . '/pages/user_edit.php';
            } elseif ($page === 'owners' && $userAction === 'detail') {
                $pageFile = __DIR__ . '/pages/owner_verif.php';
            } elseif ($page === 'promosi' && $userAction === 'verif') {
                $pageFile = __DIR__ . '/pages/promosi_verif.php';
            } elseif ($page === 'pajak' && $userAction === 'verif') {
                $pageFile = __DIR__ . '/pages/pajak_verif.php';
            } elseif ($page === 'informasi' && $userAction === 'add') {
                $pageFile = __DIR__ . '/pages/informasi_add.php';
            } elseif ($page === 'informasi' && $userAction === 'edit') {
                $pageFile = __DIR__ . '/pages/informasi_edit.php';
            }
            
            if (is_file($pageFile)) {
                include $pageFile;
            } else {
                ?>
                <section class="dashboard-placeholder">
                    <h2><?= htmlspecialchars($pageTitle) ?></h2>
                    <p>Konten halaman akan ditambahkan di sini.</p>
                </section>
                <?php
            }
            ?>
        </main>
    </div>
    <script src="assets/js/script.js?v=<?= filemtime(__DIR__ . '/assets/js/script.js') ?>"></script>
    <?php if ($page === 'owners'): ?>
        <script src="assets/js/owners_script.js"></script>
    <?php endif; ?>
    <?php if ($page === 'owners' && $userAction === 'detail'): ?>
        <script src="assets/js/owner_verif_script.js"></script>
    <?php endif; ?>
    <?php if ($page === 'banner'): ?>
        <script src="assets/js/banner_script.js?v=<?= filemtime(__DIR__ . '/assets/js/banner_script.js') ?>"></script>
    <?php endif; ?>
    <?php if ($page === 'promosi'): ?>
        <script src="assets/js/promosi_script.js?v=<?= filemtime(__DIR__ . '/assets/js/promosi_script.js') ?>"></script>
    <?php endif; ?>
    <?php if ($page === 'pajak'): ?>
        <script src="assets/js/pajak_script.js?v=<?= filemtime(__DIR__ . '/assets/js/pajak_script.js') ?>"></script>
    <?php endif; ?>
</body>
</html>
