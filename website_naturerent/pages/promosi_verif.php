<?php
require_once __DIR__ . '/../repositories/promosi_repository.php';

$formError = '';
$promotionId = (string) ($_GET['id'] ?? '');
$promotion = findPromotionById($promotionId);

if ($promotion === null) {
    ?>
    <section class="content-card promosi-verify-card">
        <div class="promosi-alert">Data promosi tidak ditemukan.</div>
    </section>
    <?php
    return;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'update_status_promosi') {
    $newStatus = (string) ($_POST['status'] ?? '');
    $allowedStatuses = ['menunggu_verifikasi', 'aktif', 'ditolak', 'selesai'];

    if (!in_array($newStatus, $allowedStatuses, true)) {
        $formError = 'Status promosi tidak valid.';
    } else {
        $result = updatePromotionStatus($promotion, $newStatus);

        if ($result['ok']) {
            header('Location: index.php?page=promosi');
            exit;
        }

        $formError = 'Status promosi gagal diperbarui. Periksa koneksi atau izin database.';
    }
}

$promotion = findPromotionById($promotionId) ?? $promotion;
$currentStatus = promotionStatus($promotion);
$proofUrl = promotionProofUrl($promotion);
$statusOptions = [
    'menunggu_verifikasi' => [
        'title' => 'Menunggu Verifikasi',
        'description' => 'Promosi belum diverifikasi, menunggu tinjauan admin',
        'button' => 'Menunggu',
        'class' => 'waiting',
    ],
    'aktif' => [
        'title' => 'Aktif',
        'description' => 'Promosi Aktif',
        'button' => 'Aktif',
        'class' => 'active',
    ],
    'ditolak' => [
        'title' => 'Di tolak',
        'description' => 'Promosi di tolak',
        'button' => 'Ditolak',
        'class' => 'rejected',
    ],
    'selesai' => [
        'title' => 'Selesai',
        'description' => 'Promosi alat telah selesai',
        'button' => 'Selesai',
        'class' => 'finished',
    ],
];
?>
<section class="content-card promosi-verify-card">
    <form method="POST" action="index.php?page=promosi&action=verif&id=<?= urlencode($promotionId) ?>">
        <input type="hidden" name="action" value="update_status_promosi">

        <div class="promosi-verify-body">
            <div class="promosi-verify-intro">
                <div class="promosi-verify-icon" aria-hidden="true">
                    <img src="assets/icon/Promosi%20Alat1.png" alt="">
                </div>
                <div>
                    <h2>Verifikasi Promosi Iklan</h2>
                    <p>Cek semua informasi untuk verifikasi promosi</p>
                </div>
            </div>

            <?php if ($formError !== ''): ?>
                <div class="promosi-alert promosi-verify-alert"><?= htmlspecialchars($formError) ?></div>
            <?php endif; ?>

            <div class="promosi-verify-grid">
                <div class="promosi-info-field">
                    <span>Nama Alat</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="m14.7 6.3 3 3"></path>
                            <path d="M5 21 19 7l-2-2L3 19v2h2Z"></path>
                            <path d="m15 5 2-2 4 4-2 2"></path>
                        </svg>
                        <?= htmlspecialchars(promotionProductName($promotion)) ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Nama Toko</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M4 10h16"></path>
                            <path d="M5 10 6 4h12l1 6"></path>
                            <path d="M6 10v10h12V10"></path>
                            <path d="M9 20v-6h6v6"></path>
                        </svg>
                        <?= htmlspecialchars(promotionStoreName($promotion)) ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Durasi Iklan</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"></circle>
                            <path d="M12 7v5l3 2"></path>
                        </svg>
                        <?= htmlspecialchars(promotionDurationLabel($promotion) ?: '-') ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Tanggal Mulai</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                            <path d="M16 3v4"></path>
                            <path d="M8 3v4"></path>
                            <path d="M3 11h18"></path>
                        </svg>
                        <?= htmlspecialchars(formatPromotionDate($promotion['tanggal_mulai'] ?? null)) ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Tanggal Selesai</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                            <path d="M16 3v4"></path>
                            <path d="M8 3v4"></path>
                            <path d="M3 11h18"></path>
                        </svg>
                        <?= htmlspecialchars(formatPromotionDate($promotion['tanggal_selesai'] ?? null)) ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Total Bayar</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="6" width="18" height="12" rx="2"></rect>
                            <circle cx="12" cy="12" r="2"></circle>
                        </svg>
                        <?= htmlspecialchars(formatPromotionMoney($promotion['total_bayar'] ?? 0)) ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Metode pembayaran</span>
                    <div class="promosi-info-box">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="6" width="18" height="12" rx="2"></rect>
                            <path d="M7 10h6"></path>
                        </svg>
                        <?= htmlspecialchars($promotion['metode_pembayaran'] ?? '-') ?>
                    </div>
                </div>

                <div class="promosi-info-field">
                    <span>Bukti Pembayaran</span>
                    <a
                        class="promosi-doc-link"
                        href="<?= htmlspecialchars($proofUrl ?: '#') ?>"
                        target="_blank"
                        rel="noopener"
                    >
                        <iconify-icon icon="tabler:photo" class="promosi-doc-icon"></iconify-icon>
                        <?= htmlspecialchars(promotionProofName($promotion)) ?>
                        <iconify-icon icon="tabler:external-link" class="promosi-doc-ext"></iconify-icon>
                    </a>
                </div>
            </div>

            <div class="promosi-status-section">
                <h3>Status Saat Ini</h3>

                <?php foreach ($statusOptions as $statusValue => $option): ?>
                    <?php $inputId = 'status_' . $statusValue; ?>
                    <input
                        class="promosi-status-input"
                        type="radio"
                        id="<?= htmlspecialchars($inputId) ?>"
                        name="status"
                        value="<?= htmlspecialchars($statusValue) ?>"
                        <?= $currentStatus === $statusValue ? 'checked' : '' ?>
                    >
                    <label class="promosi-status-option <?= htmlspecialchars($option['class']) ?>" for="<?= htmlspecialchars($inputId) ?>">
                        <span class="promosi-status-radio"></span>
                        <span class="promosi-status-copy">
                            <strong><?= htmlspecialchars($option['title']) ?></strong>
                            <small><?= htmlspecialchars($option['description']) ?></small>
                        </span>
                        <span class="promosi-status-pill"><?= htmlspecialchars($option['button']) ?></span>
                    </label>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="promosi-verify-actions">
            <a class="promosi-cancel-button" href="index.php?page=promosi">Batal</a>
            <button class="promosi-save-button" type="submit">
                Simpan Perubahan
                <span aria-hidden="true">&rsaquo;</span>
            </button>
        </div>
    </form>
</section>
