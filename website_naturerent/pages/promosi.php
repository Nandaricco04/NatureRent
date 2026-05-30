<?php
require_once __DIR__ . '/../repositories/promosi_repository.php';

$deleteError = '';

$promotions = getPromotions();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'delete_promosi') {
    $deleteId = (string) ($_POST['id_sewa'] ?? '');
    $deletePromotion = null;

    foreach ($promotions as $promotion) {
        if (promotionId($promotion) === $deleteId) {
            $deletePromotion = $promotion;
            break;
        }
    }

    if ($deleteId === '' || $deletePromotion === null) {
        $deleteError = 'Data promosi tidak ditemukan.';
    } else {
        $result = deletePromotion($deleteId);

        if ($result['ok']) {
            setPromotionProductInactive($deletePromotion);
            header('Location: index.php?page=promosi');
            exit;
        }

        $deleteError = 'Promosi gagal dihapus. Periksa koneksi atau izin database.';
    }
}

$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 6;
$totalPromotions = count($promotions);
$totalPages = max(1, (int) ceil($totalPromotions / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visiblePromotions = array_slice($promotions, $offset, $perPage);
$startNumber = $totalPromotions === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalPromotions);

function promosiPageUrl(int $page): string
{
    return 'index.php?' . http_build_query(['page' => 'promosi', 'p' => $page]);
}
?>
<section class="content-card promosi-card">
    <div class="promosi-header">
        <h2>Daftar Promosi Alat</h2>
    </div>

    <?php if ($deleteError !== ''): ?>
        <div class="promosi-alert"><?= htmlspecialchars($deleteError) ?></div>
    <?php endif; ?>

    <div class="promosi-table-wrap">
        <table class="promosi-table">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Alat</th>
                    <th>Toko</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Selesai</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($visiblePromotions)): ?>
                    <tr>
                        <td class="promosi-empty" colspan="7">Data promosi belum tersedia.</td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($visiblePromotions as $index => $promotion): ?>
                    <?php
                    $promotionId = promotionId($promotion);
                    $productName = promotionProductName($promotion);
                    ?>
                    <tr>
                        <td><?= $offset + $index + 1 ?></td>
                        <td>
                            <span class="promosi-product"><?= htmlspecialchars($productName) ?></span>
                        </td>
                        <td><?= htmlspecialchars(promotionStoreName($promotion)) ?></td>
                        <td><?= htmlspecialchars(formatPromotionMoney($promotion['total_bayar'] ?? 0)) ?></td>
                        <td>
                            <?php $status = promotionStatus($promotion); ?>
                            <span class="promosi-status-badge <?= htmlspecialchars(promotionStatusClass($status)) ?>">
                                <?= htmlspecialchars(promotionStatusLabel($status)) ?>
                            </span>
                        </td>
                        <td><?= htmlspecialchars(formatPromotionDate($promotion['tanggal_selesai'] ?? null)) ?></td>
                        <td>
                            <div class="promosi-actions">
                                <a
                                    class="promosi-action verify"
                                    href="index.php?page=promosi&action=verif&id=<?= urlencode($promotionId) ?>"
                                    aria-label="Verifikasi promosi <?= htmlspecialchars($productName) ?>"
                                >
                                    <img src="assets/icon/verif.png" alt="" aria-hidden="true">
                                </a>
                                <button
                                    class="promosi-action delete js-delete-promosi"
                                    type="button"
                                    data-promosi-id="<?= htmlspecialchars($promotionId) ?>"
                                    data-promosi-name="<?= htmlspecialchars($productName) ?>"
                                    aria-label="Hapus promosi <?= htmlspecialchars($productName) ?>"
                                >
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M3 6h18"></path>
                                        <path d="M8 6V4h8v2"></path>
                                        <path d="M19 6l-1 14H6L5 6"></path>
                                        <path d="M10 11v6"></path>
                                        <path d="M14 11v6"></path>
                                    </svg>
                                </button>
                            </div>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <div class="promosi-footer">
        <p>Showing <?= $endNumber ?> of <?= $totalPromotions ?></p>

        <div class="promosi-pagination">
            <a
                class="promosi-page <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(promosiPageUrl($currentPage - 1)) ?>"
                aria-label="Halaman sebelumnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M19 12H5"></path>
                    <path d="m12 19-7-7 7-7"></path>
                </svg>
            </a>

            <?php for ($pageNumber = 1; $pageNumber <= $totalPages; $pageNumber++): ?>
                <a
                    class="promosi-page <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                    href="<?= htmlspecialchars(promosiPageUrl($pageNumber)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endfor; ?>

            <a
                class="promosi-page <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(promosiPageUrl($currentPage + 1)) ?>"
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

<div class="promosi-delete-modal" data-promosi-delete-modal hidden>
    <div class="promosi-delete-backdrop" data-promosi-delete-cancel></div>
    <section class="promosi-delete-dialog" role="dialog" aria-modal="true" aria-labelledby="promosi-delete-title">
        <div class="promosi-delete-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <path d="M3 6h18"></path>
                <path d="M8 6V4h8v2"></path>
                <path d="M19 6l-1 14H6L5 6"></path>
                <path d="M10 11v6"></path>
                <path d="M14 11v6"></path>
            </svg>
        </div>

        <h2 id="promosi-delete-title">Hapus Promosi?</h2>
        <p>kamu akan menghapus<br>promosi ini, yakin?</p>

        <div class="promosi-delete-actions">
            <button class="promosi-delete-cancel" type="button" data-promosi-delete-cancel>Batal</button>
            <form method="POST" action="index.php?page=promosi">
                <input type="hidden" name="action" value="delete_promosi">
                <input type="hidden" name="id_sewa" value="" data-promosi-delete-id>
                <button class="promosi-delete-confirm" type="submit">Ya, Hapus</button>
            </form>
        </div>
    </section>
</div>
