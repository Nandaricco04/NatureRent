<?php
$activePage = $activePage ?? 'dashboard';

$menuGroups = [
    [
        'label' => 'OVERVIEW',
        'items' => [
            ['page' => 'dashboard', 'title' => 'Dashboard', 'icon' => 'grid'],
            ['page' => 'users', 'title' => 'User Management', 'icon' => 'users'],
            ['page' => 'owners', 'title' => 'Owner Management', 'icon' => 'store'],
        ],
    ],
    [
        'label' => 'CONTENT',
        'items' => [
            ['page' => 'informasi', 'title' => 'Informasi', 'icon' => 'info'],
            ['page' => 'kategori', 'title' => 'Kategori Alat', 'icon' => 'tools'],
        ],
    ],
    [
        'label' => 'CONTENT',
        'items' => [
            ['page' => 'transaksi', 'title' => 'Transaksi', 'icon' => 'receipt'],
            ['page' => 'komplain', 'title' => 'Komplain', 'icon' => 'complaint'],
            ['page' => 'banner', 'title' => 'Baner Destinasi', 'icon' => 'megaphone'],
            ['page' => 'promosi', 'title' => 'Promosi Alat', 'icon' => 'money'],
        ],
    ],
];

function sidebarIcon(string $name): string
{
    $icons = [
        'grid' => '<rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect>',
        'users' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path>',
        'store' => '<path d="M3 9l1.4-5h15.2L21 9"></path><path d="M5 9v11h14V9"></path><path d="M9 20v-6h6v6"></path><path d="M3 9h18"></path>',
        'info' => '<circle cx="12" cy="12" r="10"></circle><path d="M12 16v-4"></path><path d="M12 8h.01"></path>',
        'tools' => '<path d="M14.7 6.3a4 4 0 0 0-5 5L3 18l3 3 6.7-6.7a4 4 0 0 0 5-5l-2.9 2.9-3-3 2.9-2.9Z"></path><path d="M19 21l-5-5"></path>',
        'receipt' => '<path d="M4 3h16v18l-3-2-3 2-3-2-3 2-4-2V3Z"></path><path d="M8 8h8"></path><path d="M8 13h6"></path>',
        'complaint' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><circle cx="18" cy="8" r="3"></circle><path d="M18 6v2"></path><path d="M18 10h.01"></path>',
        'megaphone' => '<path d="M3 11v2a2 2 0 0 0 2 2h2l5 4V5L7 9H5a2 2 0 0 0-2 2Z"></path><path d="M16 9a5 5 0 0 1 0 6"></path><path d="M19 6a9 9 0 0 1 0 12"></path>',
        'money' => '<path d="M12 2v20"></path><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7H14a3.5 3.5 0 0 1 0 7H6"></path>',
    ];

    return '<svg viewBox="0 0 24 24" aria-hidden="true">' . ($icons[$name] ?? $icons['grid']) . '</svg>';
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
