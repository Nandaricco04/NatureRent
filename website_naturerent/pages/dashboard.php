<?php
require_once __DIR__ . '/../repositories/transaksi_repository.php';
require_once __DIR__ . '/../repositories/user_repository.php';
require_once __DIR__ . '/../repositories/owner_repository.php';
require_once __DIR__ . '/../repositories/pajak_repository.php';

$dashboardTransactions = getAdminTransactions();
$dashboardTaxes = fetchTaxTransactionRows();
$dashboardUsers = getUsersByRole('user');
$ownerCounts = countOwnerByStatus();
$dashboardAdminName = (string) ($admin['name'] ?? $_SESSION['admin']['name'] ?? 'Admin');

$statusCounts = [
    'dipesan' => 0,
    'diambil' => 0,
    'selesai' => 0,
    'dibatalkan' => 0,
];
$totalTaxRevenue = 0;

foreach ($dashboardTransactions as $transaction) {
    $status = adminTransactionStatus($transaction);
    $statusCounts[$status] = ($statusCounts[$status] ?? 0) + 1;
}

foreach ($dashboardTaxes as $taxTransaction) {
    if (taxStatus($taxTransaction) === 'sudah_dibayar') {
        $totalTaxRevenue += taxAmount($taxTransaction);
    }
}

$today = new DateTimeImmutable('today');
$dailyRevenue = [];
$dailyLabels = [];

for ($offset = 6; $offset >= 0; $offset--) {
    $date = $today->modify("-{$offset} days");
    $key = $date->format('Y-m-d');
    $dailyRevenue[$key] = 0;
    $dailyLabels[$key] = $date->format('D');
}

foreach ($dashboardTaxes as $taxTransaction) {
    $dateValue = $taxTransaction['created_at'] ?? null;

    try {
        $taxDate = $dateValue ? new DateTimeImmutable((string) $dateValue) : null;
    } catch (Exception $exception) {
        $taxDate = null;
    }

    if ($taxDate && isset($dailyRevenue[$taxDate->format('Y-m-d')]) && taxStatus($taxTransaction) === 'sudah_dibayar') {
        $dailyRevenue[$taxDate->format('Y-m-d')] += taxAmount($taxTransaction);
    }
}

$chartValues = array_values($dailyRevenue);
$chartMax = max(max($chartValues), 1);
$chartWidth = 700;
$chartHeight = 220;
$chartPaddingX = 20;
$chartPaddingY = 18;
$chartStep = ($chartWidth - ($chartPaddingX * 2)) / max(count($chartValues) - 1, 1);
$chartPoints = [];

foreach ($chartValues as $index => $value) {
    $x = $chartPaddingX + ($index * $chartStep);
    $y = $chartHeight - $chartPaddingY - (($value / $chartMax) * ($chartHeight - ($chartPaddingY * 2)));
    $chartPoints[] = round($x, 2) . ',' . round($y, 2);
}

$chartPolyline = implode(' ', $chartPoints);
$chartArea = $chartPaddingX . ',' . ($chartHeight - $chartPaddingY) . ' '
    . $chartPolyline . ' '
    . ($chartWidth - $chartPaddingX) . ',' . ($chartHeight - $chartPaddingY);
$recentTransactions = array_slice($dashboardTransactions, 0, 5);
$activeTransactions = $statusCounts['dipesan'] + $statusCounts['diambil'];
$statusTotal = array_sum($statusCounts);
$totalStatuses = max($statusTotal, 1);
$statusColors = [
    'dipesan' => '#f59e0b',
    'diambil' => '#3b82f6',
    'selesai' => '#22a447',
    'dibatalkan' => '#ef4444',
];
$statusLabels = [
    'dipesan' => 'Dipesan',
    'diambil' => 'Diambil',
    'selesai' => 'Selesai',
    'dibatalkan' => 'Dibatalkan',
];
$donutStops = [];
$donutOffset = 0;

foreach ($statusCounts as $status => $count) {
    $nextOffset = $donutOffset + (($count / $totalStatuses) * 100);
    $donutStops[] = $statusColors[$status] . ' ' . round($donutOffset, 2) . '% ' . round($nextOffset, 2) . '%';
    $donutOffset = $nextOffset;
}

$donutBackground = $statusTotal > 0 ? implode(', ', $donutStops) : '#e9eee9 0% 100%';
$dayTranslations = ['Mon' => 'Sen', 'Tue' => 'Sel', 'Wed' => 'Rab', 'Thu' => 'Kam', 'Fri' => 'Jum', 'Sat' => 'Sab', 'Sun' => 'Min'];
?>

<section class="dashboard-page">
    <div class="dashboard-welcome">
        <div>
            <p>Ringkasan hari ini</p>
            <h2>Selamat datang, <?= htmlspecialchars($dashboardAdminName) ?></h2>
            <span>Pantau transaksi dan perkembangan NatureRent dalam satu halaman.</span>
        </div>
        <a href="index.php?page=transaksi">Lihat transaksi <iconify-icon icon="tabler:arrow-right"></iconify-icon></a>
    </div>

    <div class="dashboard-stat-grid">
        <article class="dashboard-stat-card revenue">
            <div class="stat-card-icon"><iconify-icon icon="tabler:wallet"></iconify-icon></div>
            <div><span>Pendapatan Aplikasi</span><strong><?= htmlspecialchars(formatTaxMoney($totalTaxRevenue)) ?></strong><small>Dari pajak yang sudah dibayar</small></div>
        </article>
        <article class="dashboard-stat-card transaction">
            <div class="stat-card-icon"><iconify-icon icon="tabler:receipt"></iconify-icon></div>
            <div><span>Total Transaksi</span><strong><?= count($dashboardTransactions) ?></strong><small><?= $activeTransactions ?> transaksi masih aktif</small></div>
        </article>
        <article class="dashboard-stat-card user">
            <div class="stat-card-icon"><iconify-icon icon="tabler:users"></iconify-icon></div>
            <div><span>Total Pengguna</span><strong><?= count($dashboardUsers) ?></strong><small>Pengguna terdaftar</small></div>
        </article>
        <article class="dashboard-stat-card owner">
            <div class="stat-card-icon"><iconify-icon icon="tabler:building-store"></iconify-icon></div>
            <div><span>Owner Aktif</span><strong><?= (int) ($ownerCounts['approved'] ?? 0) ?></strong><small><?= (int) ($ownerCounts['pending'] ?? 0) ?> menunggu verifikasi</small></div>
        </article>
    </div>

    <div class="dashboard-chart-grid">
        <article class="dashboard-panel revenue-panel">
            <header class="dashboard-panel-header">
                <div><span>Performa aplikasi</span><h3>Pendapatan Pajak 7 Hari Terakhir</h3></div>
                <strong><?= htmlspecialchars(formatTaxMoney(array_sum($chartValues))) ?></strong>
            </header>
            <div class="revenue-chart">
                <div class="chart-scale"><span><?= htmlspecialchars(formatTaxMoney($chartMax)) ?></span><span><?= htmlspecialchars(formatTaxMoney((int) ($chartMax / 2))) ?></span><span>Rp 0</span></div>
                <div class="chart-canvas">
                    <svg viewBox="0 0 <?= $chartWidth ?> <?= $chartHeight ?>" preserveAspectRatio="none" role="img" aria-label="Grafik pendapatan pajak tujuh hari terakhir">
                        <defs>
                            <linearGradient id="dashboard-chart-fill" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stop-color="#35a853" stop-opacity=".32"/>
                                <stop offset="100%" stop-color="#35a853" stop-opacity=".02"/>
                            </linearGradient>
                        </defs>
                        <line x1="20" y1="18" x2="680" y2="18"></line>
                        <line x1="20" y1="110" x2="680" y2="110"></line>
                        <line x1="20" y1="202" x2="680" y2="202"></line>
                        <polygon points="<?= htmlspecialchars($chartArea) ?>"></polygon>
                        <polyline points="<?= htmlspecialchars($chartPolyline) ?>"></polyline>
                        <?php foreach ($chartPoints as $point): ?>
                            <?php [$x, $y] = explode(',', $point); ?>
                            <circle cx="<?= $x ?>" cy="<?= $y ?>" r="5"></circle>
                        <?php endforeach; ?>
                    </svg>
                    <div class="chart-labels">
                        <?php foreach ($dailyRevenue as $key => $value): ?>
                            <span><?= htmlspecialchars($dayTranslations[$dailyLabels[$key]] ?? $dailyLabels[$key]) ?><small><?= htmlspecialchars((new DateTimeImmutable($key))->format('d/m')) ?></small></span>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </article>

        <article class="dashboard-panel status-panel">
            <header class="dashboard-panel-header"><div><span>Distribusi</span><h3>Status Transaksi</h3></div></header>
            <div class="status-chart">
                <div class="status-donut" style="--donut: conic-gradient(<?= htmlspecialchars($donutBackground) ?>)">
                    <div><strong><?= count($dashboardTransactions) ?></strong><span>Total</span></div>
                </div>
                <div class="status-legend">
                    <?php foreach ($statusCounts as $status => $count): ?>
                        <div><i style="background: <?= $statusColors[$status] ?>"></i><span><?= $statusLabels[$status] ?></span><strong><?= $count ?></strong></div>
                    <?php endforeach; ?>
                </div>
            </div>
        </article>
    </div>

    <article class="dashboard-panel recent-panel">
        <header class="dashboard-panel-header">
            <div><span>Aktivitas terbaru</span><h3>Transaksi Terbaru</h3></div>
            <a href="index.php?page=transaksi">Lihat semua</a>
        </header>
        <div class="dashboard-table-wrap">
            <table class="dashboard-table">
                <thead><tr><th>ID Transaksi</th><th>Pengguna</th><th>Rental</th><th>Tanggal</th><th>Total</th><th>Status</th></tr></thead>
                <tbody>
                    <?php if (empty($recentTransactions)): ?>
                        <tr><td colspan="6" class="dashboard-empty">Belum ada transaksi.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($recentTransactions as $transaction): ?>
                        <?php $date = adminTransactionDate($transaction); ?>
                        <?php $status = adminTransactionStatus($transaction); ?>
                        <tr>
                            <td><strong><?= htmlspecialchars(adminTransactionCode($transaction)) ?></strong></td>
                            <td><?= htmlspecialchars(adminTransactionUser($transaction)) ?></td>
                            <td><?= htmlspecialchars(adminTransactionStores($transaction)) ?></td>
                            <td><?= $date ? htmlspecialchars($date->format('d M Y')) : '-' ?></td>
                            <td><strong><?= htmlspecialchars(formatAdminTransactionMoney($transaction['total_harga'] ?? 0)) ?></strong></td>
                            <td><span class="dashboard-status <?= htmlspecialchars($status) ?>"><i></i><?= htmlspecialchars(adminTransactionStatusLabel($status)) ?></span></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </article>
</section>
