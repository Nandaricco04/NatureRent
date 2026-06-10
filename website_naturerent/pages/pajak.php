<?php
require_once __DIR__ . '/../repositories/pajak_repository.php';

$formError = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'update_pajak') {
    $transactionId = (string) ($_POST['id_transaksi'] ?? '');
    $newStatus = (string) ($_POST['status_pajak'] ?? '');
    $allowedStatuses = ['sudah_dibayar', 'gagal'];

    if (!in_array($newStatus, $allowedStatuses, true)) {
        $formError = 'Status pajak tidak valid.';
    } else {
        $result = updateTaxStatus($transactionId, $newStatus);

        if ($result['ok']) {
            header('Location: index.php?page=pajak');
            exit;
        }

        $formError = 'Status pajak gagal diperbarui. Periksa koneksi atau izin database.';
    }
}

$transactions = getTaxTransactions();
$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 5;
$totalRows = count($transactions);
$totalPages = max(1, (int) ceil($totalRows / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleTransactions = array_slice($transactions, $offset, $perPage);
$startNumber = $totalRows === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalRows);

$paidCount = count(array_filter($transactions, fn(array $row): bool => taxStatus($row) === 'sudah_dibayar'));
$waitingCount = count(array_filter($transactions, fn(array $row): bool => taxStatus($row) === 'menunggu_verifikasi'));
$unpaidCount = count(array_filter($transactions, fn(array $row): bool => taxStatus($row) === 'belum_dibayar'));
$failedCount = count(array_filter($transactions, fn(array $row): bool => taxStatus($row) === 'gagal'));

function taxPageUrl(int $page): string
{
    return 'index.php?' . http_build_query(['page' => 'pajak', 'p' => $page]);
}

function taxPaginationRange(int $currentPage, int $totalPages): array
{
    $start = max(1, min($currentPage - 1, $totalPages - 2));
    $end = min($totalPages, $start + 2);

    return range($start, $end);
}
?>
<section class="pajak-page">
    <div class="pajak-stat-grid">
        <article class="owner-stat-card">
            <div class="owner-stat-top">
                <div class="owner-stat-icon" style="background:#E1F5EE;">
                    <iconify-icon icon="tabler:circle-check" style="color:#0F6E56;"></iconify-icon>
                </div>
                <span class="owner-stat-badge" style="background:#E1F5EE;color:#0F6E56;">Sudah Bayar</span>
            </div>
            <p class="owner-stat-label">Sudah Dibayar</p>
            <p class="owner-stat-value"><?= $paidCount ?></p>
            <p class="owner-stat-sub">Sudah membayar pajak</p>
        </article>

        <article class="owner-stat-card">
            <div class="owner-stat-top">
                <div class="owner-stat-icon" style="background:#FAEEDA;">
                    <iconify-icon icon="tabler:clock" style="color:#854F0B;"></iconify-icon>
                </div>
                <span class="owner-stat-badge" style="background:#FAEEDA;color:#854F0B;">Menunggu</span>
            </div>
            <p class="owner-stat-label">Menunggu Verifikasi</p>
            <p class="owner-stat-value"><?= $waitingCount ?></p>
            <p class="owner-stat-sub">Perlu ditinjau</p>
        </article>

        <article class="owner-stat-card">
            <div class="owner-stat-top">
                <div class="owner-stat-icon" style="background:#EAF1FF;">
                    <iconify-icon icon="tabler:receipt-off" style="color:#285EA8;"></iconify-icon>
                </div>
                <span class="owner-stat-badge" style="background:#EAF1FF;color:#285EA8;">Belum Bayar</span>
            </div>
            <p class="owner-stat-label">Belum Bayar</p>
            <p class="owner-stat-value"><?= $unpaidCount ?></p>
            <p class="owner-stat-sub">Pajak belum dibayar</p>
        </article>

        <article class="owner-stat-card">
            <div class="owner-stat-top">
                <div class="owner-stat-icon" style="background:#FCEBEB;">
                    <iconify-icon icon="tabler:circle-x" style="color:#A32D2D;"></iconify-icon>
                </div>
                <span class="owner-stat-badge" style="background:#FCEBEB;color:#A32D2D;">Gagal</span>
            </div>
            <p class="owner-stat-label">Gagal</p>
            <p class="owner-stat-value"><?= $failedCount ?></p>
            <p class="owner-stat-sub">Pajak tidak sesuai</p>
        </article>
    </div>

    <section class="content-card pajak-card">
        <div class="content-card-header">
            <h2>Daftar Pajak Transaksi</h2>
        </div>

        <?php if ($formError !== ''): ?>
            <div class="table-alert"><?= htmlspecialchars($formError) ?></div>
        <?php endif; ?>

        <div class="table-wrap">
            <table class="admin-table pajak-table">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>ID Pesanan</th>
                        <th>Toko</th>
                        <th>Nama Alat</th>
                        <th>Nominal</th>
                        <th>Metode</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($visibleTransactions)): ?>
                        <tr>
                            <td class="empty-table" colspan="8">Data pajak belum tersedia.</td>
                        </tr>
                    <?php endif; ?>

                    <?php foreach ($visibleTransactions as $index => $transaction): ?>
                        <?php
                        $status = taxStatus($transaction);
                        $proofUrl = taxProofUrl($transaction);
                        ?>
                        <tr>
                            <td><?= $offset + $index + 1 ?></td>
                            <td><?= htmlspecialchars(taxTransactionCode($transaction)) ?></td>
                            <td><?= htmlspecialchars(taxStoreName($transaction)) ?></td>
                            <td class="pajak-product-name"><?= htmlspecialchars(taxProductNames($transaction)) ?></td>
                            <td><?= htmlspecialchars(formatTaxMoney(taxAmount($transaction))) ?></td>
                            <td><span class="pajak-method-pill"><i></i><?= htmlspecialchars(taxPaymentMethod($transaction)) ?></span></td>
                            <td>
                                <span class="pajak-status <?= htmlspecialchars(taxStatusClass($status)) ?>">
                                    <?= htmlspecialchars(taxStatusLabel($status)) ?>
                                </span>
                            </td>
                            <td>
                                <div class="table-actions pajak-actions">
                                    <div>
                                        <a
                                            class="action-button approve"
                                            href="index.php?page=pajak&action=verif&id=<?= urlencode((string) ($transaction['id_transaksi'] ?? '')) ?>"
                                            aria-label="Verifikasi pajak"
                                        >
                                            <iconify-icon icon="tabler:user-scan"></iconify-icon>
                                        </a>
                                    </div>

                                    <button
                                        class="action-button reject js-fail-pajak"
                                        type="button"
                                        data-transaction-id="<?= htmlspecialchars((string) ($transaction['id_transaksi'] ?? '')) ?>"
                                        aria-label="Gagalkan pajak"
                                    >
                                        <svg viewBox="0 0 24 24" aria-hidden="true">
                                            <circle cx="12" cy="12" r="9"></circle>
                                            <path d="m15 9-6 6"></path>
                                            <path d="m9 9 6 6"></path>
                                        </svg>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <div class="table-footer">
            <p>Menampilkan <?= $startNumber ?>-<?= $endNumber ?> dari <?= $totalRows ?> data</p>

            <div class="pagination">
                <a
                    class="page-button <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                    href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(taxPageUrl($currentPage - 1)) ?>"
                    aria-label="Halaman sebelumnya"
                >
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M19 12H5"></path>
                        <path d="m12 19-7-7 7-7"></path>
                    </svg>
                </a>

                <?php foreach (taxPaginationRange($currentPage, $totalPages) as $pageNumber): ?>
                    <a
                        class="page-button <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                        href="<?= htmlspecialchars(taxPageUrl($pageNumber)) ?>"
                    >
                        <?= $pageNumber ?>
                    </a>
                <?php endforeach; ?>

                <a
                    class="page-button <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                    href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(taxPageUrl($currentPage + 1)) ?>"
                    aria-label="Halaman berikutnya"
                >
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M5 12h14"></path>
                        <path d="m12 5 7 7-7 7"></path>
                    </svg>
                </a>
            </div>
        </div>
    </section>
</section>

<div class="pajak-fail-modal" data-pajak-fail-modal hidden>
    <div class="pajak-fail-backdrop" data-pajak-fail-cancel></div>
    <section class="pajak-fail-dialog" role="dialog" aria-modal="true" aria-labelledby="pajak-fail-title">
        <div class="pajak-fail-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <path d="m15 9-6 6"></path>
                <path d="m9 9 6 6"></path>
            </svg>
        </div>
        <h2 id="pajak-fail-title">Gagalkan Pajak?</h2>
        <p>kamu akan gagalkan<br>pajak ini, yakin?</p>

        <div class="pajak-fail-actions">
            <button class="pajak-fail-cancel" type="button" data-pajak-fail-cancel>Batal</button>
            <form method="POST" action="index.php?page=pajak">
                <input type="hidden" name="action" value="update_pajak">
                <input type="hidden" name="id_transaksi" value="" data-pajak-fail-id>
                <input type="hidden" name="status_pajak" value="gagal">
                <button class="pajak-fail-confirm" type="submit">Ya, Gagalkan</button>
            </form>
        </div>
    </section>
</div>
