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
} elseif ($page === 'users' && $userAction === 'edit') {
    $breadcrumbTitle .= ' / EditUser';
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
    <?php if ($page === 'banner'): ?>
        <link rel="stylesheet" href="assets/css/banner_style.css">
    <?php endif; ?>
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
    <?php if ($page === 'banner'): ?>
        <script src="assets/js/banner_script.js?v=<?= filemtime(__DIR__ . '/assets/js/banner_script.js') ?>"></script>
    <?php endif; ?>
</body>
</html>
