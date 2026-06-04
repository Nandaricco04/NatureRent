<?php
require_once __DIR__ . '/../repositories/transaksi_repository.php';

$transactions = getAdminTransactions();
$allowedStatuses = ['all', 'dipesan', 'diambil', 'selesai', 'dibatalkan'];
$statusFilter = strtolower(trim((string) ($_GET['status'] ?? 'all')));
$statusFilter = in_array($statusFilter, $allowedStatuses, true) ? $statusFilter : 'all';
$keyword = strtolower(trim((string) ($_GET['search'] ?? '')));

function filterAdminTransactions(array $rows, string $status, string $keyword): array
{
    return array_values(array_filter($rows, function (array $transaction) use ($status, $keyword): bool {
        if ($status !== 'all' && adminTransactionStatus($transaction) !== $status) {
            return false;
        }

        if ($keyword === '') {
            return true;
        }

        $haystack = strtolower(implode(' ', [
            adminTransactionCode($transaction),
            adminTransactionUser($transaction),
            adminTransactionStores($transaction),
            adminTransactionProducts($transaction),
        ]));

        return str_contains($haystack, $keyword);
    }));
}

function filterExportTransactions(array $rows, string $status, string $payment, string $rental, string $start, string $end): array
{
    $startDate = DateTimeImmutable::createFromFormat('!Y-m-d', $start) ?: null;
    $endDate = DateTimeImmutable::createFromFormat('!Y-m-d', $end) ?: null;

    return array_values(array_filter($rows, function (array $transaction) use ($status, $payment, $rental, $startDate, $endDate): bool {
        if ($status !== 'all' && adminTransactionStatus($transaction) !== $status) {
            return false;
        }

        $transactionPayment = strtolower(trim((string) ($transaction['payment_method'] ?? '')));
        if ($payment !== 'all' && $transactionPayment !== $payment) {
            return false;
        }

        $transactionRentals = array_map('strtolower', $transaction['_store_names'] ?? []);
        if ($rental !== 'all' && !in_array($rental, $transactionRentals, true)) {
            return false;
        }

        $date = adminTransactionDate($transaction);
        if (($startDate || $endDate) && !$date) {
            return false;
        }

        return !($date && $startDate && $date < $startDate)
            && !($date && $endDate && $date > $endDate->setTime(23, 59, 59));
    }));
}

if (($_GET['action'] ?? '') === 'export') {
    $exportStatus = strtolower(trim((string) ($_GET['export_status'] ?? 'all')));
    $exportStatus = in_array($exportStatus, $allowedStatuses, true) ? $exportStatus : 'all';
    $exportRows = filterExportTransactions(
        $transactions,
        $exportStatus,
        strtolower(trim((string) ($_GET['payment'] ?? 'all'))),
        strtolower(trim((string) ($_GET['rental'] ?? 'all'))),
        (string) ($_GET['start_date'] ?? ''),
        (string) ($_GET['end_date'] ?? '')
    );

    if (ob_get_length()) {
        ob_clean();
    }

    header('Content-Type: text/csv; charset=UTF-8');
    header('Content-Disposition: attachment; filename="laporan-transaksi-' . date('Y-m-d') . '.csv"');
    $output = fopen('php://output', 'wb');
    fwrite($output, "\xEF\xBB\xBF");
    fputcsv($output, ['ID', 'Pengguna', 'Rental', 'Produk', 'Tanggal', 'Pembayaran', 'Total', 'Status']);

    foreach ($exportRows as $transaction) {
        $date = adminTransactionDate($transaction);
        fputcsv($output, [
            adminTransactionCode($transaction),
            adminTransactionUser($transaction),
            adminTransactionStores($transaction),
            adminTransactionProducts($transaction),
            $date ? $date->format('d-m-Y') : '-',
            strtoupper((string) ($transaction['payment_method'] ?? '-')),
            formatAdminTransactionMoney($transaction['total_harga'] ?? 0),
            adminTransactionStatusLabel(adminTransactionStatus($transaction)),
        ]);
    }

    fclose($output);
    exit;
}

$filteredTransactions = filterAdminTransactions($transactions, $statusFilter, $keyword);
$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 6;
$totalRows = count($filteredTransactions);
$totalPages = max(1, (int) ceil($totalRows / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleTransactions = array_slice($filteredTransactions, $offset, $perPage);
$startNumber = $totalRows === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalRows);
$paginationStart = max(1, $currentPage - 2);
$paginationEnd = min($totalPages, $paginationStart + 2);
$paginationStart = max(1, $paginationEnd - 2);

$paymentMethods = [];
$rentalNames = [];
$transactionDates = [];
foreach ($transactions as $transaction) {
    $method = strtolower(trim((string) ($transaction['payment_method'] ?? '')));
    if ($method !== '') {
        $paymentMethods[$method] = strtoupper($method);
    }

    foreach ($transaction['_store_names'] ?? [] as $rentalName) {
        $rentalName = trim((string) $rentalName);
        if ($rentalName !== '') {
            $rentalNames[strtolower($rentalName)] = $rentalName;
        }
    }

    $date = adminTransactionDate($transaction);
    if ($date) {
        $transactionDates[] = $date;
    }
}

asort($rentalNames, SORT_NATURAL | SORT_FLAG_CASE);
usort($transactionDates, fn(DateTimeImmutable $a, DateTimeImmutable $b): int => $a <=> $b);
$today = new DateTimeImmutable('today');
$minimumTransactionDate = $transactionDates[0] ?? $today;
$maximumTransactionDate = $transactionDates[count($transactionDates) - 1] ?? $today;
$defaultStart = '';
$defaultEnd = '';

function transactionPageUrl(int $page, string $status, string $keyword): string
{
    $params = ['page' => 'transaksi', 'status' => $status, 'p' => $page];
    if ($keyword !== '') {
        $params['search'] = $keyword;
    }

    return 'index.php?' . http_build_query($params);
}
?>
<section class="transaksi-page">
    <form class="transaction-export-card" method="GET" data-export-form>
        <input type="hidden" name="page" value="transaksi">
        <input type="hidden" name="action" value="export">
        <input type="hidden" name="period" value="weekly" data-period-value>
        <input type="hidden" name="payment" value="all" data-payment-value>
        <input type="hidden" name="rental" value="all" data-rental-value>
        <input type="hidden" name="export_status" value="all" data-status-value>
        <input type="hidden" name="end_date" value="<?= htmlspecialchars($defaultEnd) ?>" data-end-date>

        <header class="export-card-header">
            <div class="export-title-icon"><iconify-icon icon="tabler:file-spreadsheet"></iconify-icon></div>
            <div>
                <h2>Export Laporan Transaksi</h2>
                <p>Pilih periode, rentang tanggal, pembayaran, dan status untuk mengekspor laporan transaksi.</p>
            </div>
        </header>

        <div class="export-form">
            <div class="export-period-row">
                <span class="export-label">Periode</span>
                <div class="period-options" data-period-options>
                    <button type="button" data-period="daily"><iconify-icon icon="tabler:calendar"></iconify-icon>Harian</button>
                    <button class="is-active" type="button" data-period="weekly"><iconify-icon icon="tabler:calendar"></iconify-icon>Mingguan</button>
                    <button type="button" data-period="monthly"><iconify-icon icon="tabler:calendar"></iconify-icon>Bulanan</button>
                    <button type="button" data-period="yearly"><iconify-icon icon="tabler:calendar"></iconify-icon>Tahunan</button>
                </div>
            </div>

            <div class="export-date-row">
                <span class="export-label">Rentang Tanggal</span>
                <div class="date-range">
                    <label class="date-choice">
                        <iconify-icon icon="tabler:calendar"></iconify-icon>
                        <span data-start-date-label>Pilih tanggal awal</span>
                        <iconify-icon icon="tabler:calendar"></iconify-icon>
                        <input type="date" name="start_date" value="<?= htmlspecialchars($defaultStart) ?>" aria-label="Pilih tanggal awal" data-start-date>
                    </label>
                    <iconify-icon class="date-arrow" icon="tabler:arrow-right"></iconify-icon>
                    <span class="date-result">
                        <iconify-icon icon="tabler:calendar"></iconify-icon>
                        <span data-end-date-label>Tanggal akhir otomatis</span>
                        <iconify-icon icon="tabler:calendar"></iconify-icon>
                    </span>
                </div>
            </div>

            <div class="export-select-grid">
                <label class="export-select-field">
                    <span class="export-label">Pembayaran</span>
                    <button class="filter-picker-button" type="button" data-open-picker="payment">
                        <iconify-icon class="picker-method-icon" icon="tabler:credit-card"></iconify-icon>
                        <span data-payment-button-label>Semua Metode</span>
                        <iconify-icon icon="tabler:chevron-down"></iconify-icon>
                    </button>
                </label>

                <label class="export-select-field">
                    <span class="export-label">Rental</span>
                    <button class="filter-picker-button" type="button" data-open-picker="rental">
                        <iconify-icon class="picker-method-icon" icon="tabler:building-store"></iconify-icon>
                        <span data-rental-button-label>Semua Rental</span>
                        <iconify-icon icon="tabler:chevron-down"></iconify-icon>
                    </button>
                </label>

                <label class="export-select-field">
                    <span class="export-label">Status</span>
                    <button class="filter-picker-button" type="button" data-open-picker="status">
                        <span class="picker-dot all"></span>
                        <span data-status-button-label>Semua Status</span>
                        <iconify-icon icon="tabler:chevron-down"></iconify-icon>
                    </button>
                </label>
            </div>

            <div class="export-summary">
                <iconify-icon icon="tabler:info-circle-filled"></iconify-icon>
                <div>
                    <strong>Ringkasan Filter</strong>
                    <p>
                        Periode <span data-summary-period>Mingguan</span>
                        <i></i>
                        <span data-summary-range>Belum memilih tanggal</span>
                        <i></i>
                        Pembayaran <span data-summary-payment>Semua Metode</span>
                        <i></i>
                        Rental <span data-summary-rental>Semua Rental</span>
                        <i></i>
                        Status <span data-summary-status>Semua Status</span>
                    </p>
                </div>
            </div>

            <div class="export-actions">
                <button class="export-button" type="submit">
                    <iconify-icon icon="tabler:download"></iconify-icon>
                    Export CSV
                </button>
            </div>
        </div>
    </form>

    <nav class="transaction-tabs" aria-label="Filter status transaksi">
        <?php foreach (['all' => 'All', 'dipesan' => 'Dipesan', 'diambil' => 'Diambil', 'selesai' => 'Selesai', 'dibatalkan' => 'Dibatalkan'] as $value => $label): ?>
            <a class="<?= $statusFilter === $value ? 'is-active' : '' ?>" href="<?= htmlspecialchars(transactionPageUrl(1, $value, $keyword)) ?>"><?= htmlspecialchars($label) ?></a>
        <?php endforeach; ?>
    </nav>

    <section class="transaction-list-card">
        <div class="transaction-list-header">
            <h2>Daftar Transaksi</h2>
            <form method="GET">
                <input type="hidden" name="page" value="transaksi">
                <input type="hidden" name="status" value="<?= htmlspecialchars($statusFilter) ?>">
                <label class="transaction-search">
                    <iconify-icon icon="tabler:search"></iconify-icon>
                    <input type="search" name="search" value="<?= htmlspecialchars($keyword) ?>" placeholder="Cari transaksi">
                </label>
            </form>
        </div>

        <div class="table-wrap">
            <table class="transaction-table">
                <thead><tr><th>ID</th><th>Pengguna</th><th>Rental</th><th>Produk</th><th>Tanggal</th><th>Payment</th><th>Total</th><th>Status</th></tr></thead>
                <tbody>
                    <?php if (empty($visibleTransactions)): ?>
                        <tr><td class="transaction-empty" colspan="8">Data transaksi tidak ditemukan.</td></tr>
                    <?php endif; ?>
                    <?php foreach ($visibleTransactions as $transaction): ?>
                        <?php $date = adminTransactionDate($transaction); ?>
                        <?php $status = adminTransactionStatus($transaction); ?>
                        <tr>
                            <td class="transaction-id"><?= htmlspecialchars(adminTransactionCode($transaction)) ?></td>
                            <td><?= htmlspecialchars(adminTransactionUser($transaction)) ?></td>
                            <td class="transaction-store"><?= htmlspecialchars(adminTransactionStores($transaction)) ?></td>
                            <td><?= htmlspecialchars(adminTransactionProducts($transaction)) ?></td>
                            <td class="transaction-date"><?= $date ? htmlspecialchars($date->format('d M Y')) : '-' ?></td>
                            <td><span class="payment-pill"><i></i><?= htmlspecialchars(strtoupper((string) ($transaction['payment_method'] ?? '-'))) ?></span></td>
                            <td class="transaction-total"><?= htmlspecialchars(formatAdminTransactionMoney($transaction['total_harga'] ?? 0)) ?></td>
                            <td><span class="transaction-status <?= htmlspecialchars($status) ?>"><i></i><?= htmlspecialchars(adminTransactionStatusLabel($status)) ?></span></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <div class="transaction-footer">
            <p>Menampilkan <?= $startNumber ?>-<?= $endNumber ?> dari <?= $totalRows ?> transaksi</p>
            <div class="transaction-pagination">
                <a class="<?= $currentPage <= 1 ? 'is-disabled' : '' ?>" href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(transactionPageUrl($currentPage - 1, $statusFilter, $keyword)) ?>" aria-label="Halaman sebelumnya"><iconify-icon icon="tabler:arrow-left"></iconify-icon></a>
                <?php for ($pageNumber = $paginationStart; $pageNumber <= $paginationEnd; $pageNumber++): ?>
                    <a class="<?= $pageNumber === $currentPage ? 'is-active' : '' ?>" href="<?= htmlspecialchars(transactionPageUrl($pageNumber, $statusFilter, $keyword)) ?>"><?= $pageNumber ?></a>
                <?php endfor; ?>
                <a class="<?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>" href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(transactionPageUrl($currentPage + 1, $statusFilter, $keyword)) ?>" aria-label="Halaman berikutnya"><iconify-icon icon="tabler:arrow-right"></iconify-icon></a>
            </div>
        </div>
    </section>
</section>

<div class="transaction-picker" data-picker="payment" hidden>
    <button class="picker-backdrop" type="button" data-close-picker aria-label="Tutup pilihan pembayaran"></button>
    <section class="picker-dialog" role="dialog" aria-modal="true" aria-labelledby="payment-picker-title">
        <div class="picker-handle"></div>
        <h2 id="payment-picker-title">Metode Pembayaran</h2>
        <div class="picker-options">
            <button class="picker-option is-selected" type="button" data-picker-option="payment" data-value="all" data-label="Semua Metode"><span class="picker-icon"><iconify-icon icon="tabler:credit-card"></iconify-icon></span><strong>Semua Metode</strong><span class="picker-check"></span></button>
            <?php foreach ($paymentMethods as $value => $label): ?>
                <button class="picker-option" type="button" data-picker-option="payment" data-value="<?= htmlspecialchars($value) ?>" data-label="<?= htmlspecialchars($label) ?>"><span class="picker-icon"><iconify-icon icon="<?= $value === 'qris' ? 'tabler:qrcode' : 'tabler:cash' ?>"></iconify-icon></span><strong><?= htmlspecialchars($label) ?></strong><span class="picker-check"></span></button>
            <?php endforeach; ?>
        </div>
    </section>
</div>

<div class="transaction-picker" data-picker="rental" hidden>
    <button class="picker-backdrop" type="button" data-close-picker aria-label="Tutup pilihan rental"></button>
    <section class="picker-dialog" role="dialog" aria-modal="true" aria-labelledby="rental-picker-title">
        <div class="picker-handle"></div>
        <h2 id="rental-picker-title">Pilih Rental</h2>
        <div class="picker-options">
            <button class="picker-option is-selected" type="button" data-picker-option="rental" data-value="all" data-label="Semua Rental"><span class="picker-icon"><iconify-icon icon="tabler:building-store"></iconify-icon></span><strong>Semua Rental</strong><span class="picker-check"></span></button>
            <?php foreach ($rentalNames as $value => $label): ?>
                <button class="picker-option" type="button" data-picker-option="rental" data-value="<?= htmlspecialchars($value) ?>" data-label="<?= htmlspecialchars($label) ?>"><span class="picker-icon"><iconify-icon icon="tabler:building-store"></iconify-icon></span><strong><?= htmlspecialchars($label) ?></strong><span class="picker-check"></span></button>
            <?php endforeach; ?>
        </div>
    </section>
</div>

<div class="transaction-picker" data-picker="status" hidden>
    <button class="picker-backdrop" type="button" data-close-picker aria-label="Tutup pilihan status"></button>
    <section class="picker-dialog" role="dialog" aria-modal="true" aria-labelledby="status-picker-title">
        <div class="picker-handle"></div>
        <h2 id="status-picker-title">Status Transaksi</h2>
        <div class="picker-options">
            <?php foreach (['all' => 'Semua Status', 'diambil' => 'Diambil', 'dipesan' => 'Dipesan', 'selesai' => 'Selesai', 'dibatalkan' => 'Dibatalkan'] as $value => $label): ?>
                <button class="picker-option <?= $value === 'all' ? 'is-selected' : '' ?>" type="button" data-picker-option="status" data-value="<?= $value ?>" data-label="<?= $label ?>"><span class="status-choice <?= $value ?>"></span><strong><?= $label ?></strong><span class="picker-check"></span></button>
            <?php endforeach; ?>
        </div>
    </section>
</div>
