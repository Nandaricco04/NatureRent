<?php
$activePage = $activePage ?? 'dashboard';

$menuGroups = [
    [
        'label' => 'Main',
        'items' => [
            ['page' => 'dashboard', 'title' => 'Dashboard', 'icon' => 'Dashboard.png'],
        ],
    ],
    [
        'label' => 'Management',
        'items' => [
            ['page' => 'users', 'title' => 'User Management', 'icon' => 'User.png'],
            ['page' => 'owners', 'title' => 'Owner Management', 'icon' => 'Owner.png'],
            ['page' => 'transaksi', 'title' => 'Transaksi', 'icon' => 'Transaksi.png'],
            ['page' => 'komplain', 'title' => 'Komplain', 'icon' => 'Komplain.png'],
        ],
    ],
    [
        'label' => 'Content Management',
        'items' => [
            ['page' => 'informasi', 'title' => 'Informasi', 'icon' => 'Informasi.png'],
            ['page' => 'banner', 'title' => 'Banner Destinasi', 'icon' => 'Destinasi.png'],
            ['page' => 'kategori', 'title' => 'Kategori Alat', 'icon' => 'Alat.png'],
            ['page' => 'promosi', 'title' => 'Promosi Alat', 'icon' => 'Promosi Alat.png'],
        ],
    ],
];

function sidebarIcon(string $fileName): string
{
    $src = 'assets/icon/' . rawurlencode($fileName);

    return '<img class="sidebar-icon" src="' . htmlspecialchars($src) . '" alt="" aria-hidden="true">';
}
?>
<aside class="admin-sidebar">
    <div class="sidebar-logo">
        <img src="assets/img/Logo.png" alt="NatureRent">
    </div>

    <nav class="sidebar-nav" aria-label="Menu admin">
        <?php foreach ($menuGroups as $group): ?>
            <div class="sidebar-group">
                <p class="sidebar-label"><?= htmlspecialchars($group['label']) ?></p>
                <?php foreach ($group['items'] as $item): ?>
                    <?php $isActive = $activePage === $item['page']; ?>
                    <a
                        class="sidebar-link <?= $isActive ? 'is-active' : '' ?>"
                        href="index.php?page=<?= urlencode($item['page']) ?>"
                    >
                        <?= sidebarIcon($item['icon']) ?>
                        <span><?= htmlspecialchars($item['title']) ?></span>
                    </a>
                <?php endforeach; ?>
            </div>
        <?php endforeach; ?>
    </nav>

    <a class="sidebar-logout" href="logout.php">Logout</a>
</aside>
