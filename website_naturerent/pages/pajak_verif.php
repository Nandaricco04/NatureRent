<?php
require_once __DIR__ . '/../repositories/pajak_repository.php';

$formError = '';
$transactionId = (string) ($_GET['id'] ?? '');
$transaction = findTaxTransactionById($transactionId);

if ($transaction === null) {
    ?>
    <section class="content-card pajak-verify-card">
        <div class="table-alert">Data pajak tidak ditemukan.</div>
    </section>
    <?php
    return;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'update_pajak') {
    $newStatus = (string) ($_POST['status_pajak'] ?? '');
    $allowedStatuses = ['menunggu_verifikasi', 'sudah_dibayar', 'gagal'];

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

$transaction = findTaxTransactionById($transactionId) ?? $transaction;
$currentStatus = taxStatus($transaction);
$proofUrl = taxProofUrl($transaction);

$statusOptions = [
    'menunggu_verifikasi' => [
        'title' => 'Menunggu Verifikasi',
        'description' => 'Pajak belum diverifikasi, menunggu tinjauan admin',
        'button' => 'Menunggu',
        'class' => 'waiting',
    ],
    'sudah_dibayar' => [
        'title' => 'Sudah Bayar',
        'description' => 'Sudah Membayar Pajak',
        'button' => 'Sudah Bayar',
        'class' => 'paid',
    ],
    'gagal' => [
        'title' => 'Gagal',
        'description' => 'Pajak tidak sesuai',
        'button' => 'Gagal',
        'class' => 'failed',
    ],
];
?>
<section class="content-card pajak-verify-card">
    <form method="POST" action="index.php?page=pajak&action=verif&id=<?= urlencode($transactionId) ?>">
        <input type="hidden" name="action" value="update_pajak">

        <div class="pajak-verify-body">
            <div class="pajak-verify-intro">
                <div class="pajak-verify-icon" aria-hidden="true">
                    <img src="assets/icon/pajak1.png" alt="">
                </div>
                <div>
                    <h2>Verifikasi Pajak</h2>
                    <p>Cek semua informasi untuk verifikasi pajak</p>
                </div>
            </div>

            <?php if ($formError !== ''): ?>
                <div class="table-alert pajak-verify-alert"><?= htmlspecialchars($formError) ?></div>
            <?php endif; ?>

            <div class="pajak-verify-grid">
                <div class="pajak-info-field">
                    <span>ID Pesanan</span>
                    <div class="pajak-info-box">
                        <iconify-icon icon="tabler:info-circle"></iconify-icon>
                        <?= htmlspecialchars(taxTransactionCode($transaction)) ?>
                    </div>
                </div>

                <!-- <div class="pajak-info-field">
                    <span>Nama Toko</span>
                    <div class="pajak-info-box">
                        <iconify-icon icon="tabler:store"></iconify-icon>
                        <?= htmlspecialchars(taxStoreName($transaction)) ?>
                    </div>
                </div> -->
                <div class="pajak-info-field">
    <span>Nama Toko</span>
    <div class="pajak-info-box">
        <iconify-icon icon="tabler:building-store"></iconify-icon>
        <?= htmlspecialchars(taxStoreName($transaction)) ?>
    </div>
</div>

                <div class="pajak-info-field">
                    <span>Nama Alat</span>
                    <div class="pajak-info-box">
                        <iconify-icon icon="tabler:tools"></iconify-icon>
                        <?= htmlspecialchars(taxProductNames($transaction)) ?>
                    </div>
                </div>

                <div class="pajak-info-field">
                    <span>Nominal</span>
                    <div class="pajak-info-box">
                        <iconify-icon icon="tabler:cash"></iconify-icon>
                        <?= htmlspecialchars(formatTaxMoney(taxAmount($transaction))) ?>
                    </div>
                </div>

                <div class="pajak-info-field">
                    <span>Metode Pajak</span>
                    <div class="pajak-info-box">
                        <iconify-icon icon="tabler:qrcode"></iconify-icon>
                        <?= htmlspecialchars(taxPaymentMethod($transaction)) ?>
                    </div>
                </div>

                <div class="pajak-info-field">
                    <span>Bukti Pembayaran</span>
                    <a
                        class="pajak-doc-link"
                        href="<?= htmlspecialchars($proofUrl ?: '#') ?>"
                        target="_blank"
                        rel="noopener"
                    >
                        <iconify-icon icon="tabler:photo" class="pajak-doc-icon"></iconify-icon>
                        <?= htmlspecialchars(taxProofName($transaction)) ?>
                        <iconify-icon icon="tabler:external-link" class="pajak-doc-ext"></iconify-icon>
                    </a>
                </div>
            </div>

            <div class="pajak-status-section">
                <h3>Status Saat Ini</h3>

                <?php foreach ($statusOptions as $statusValue => $option): ?>
                    <?php $inputId = 'pajak_status_' . $statusValue; ?>
                    <input
                        class="pajak-status-input"
                        type="radio"
                        id="<?= htmlspecialchars($inputId) ?>"
                        name="status_pajak"
                        value="<?= htmlspecialchars($statusValue) ?>"
                        <?= $currentStatus === $statusValue ? 'checked' : '' ?>
                    >
                    <label class="pajak-status-option <?= htmlspecialchars($option['class']) ?>" for="<?= htmlspecialchars($inputId) ?>">
                        <span class="pajak-status-radio"></span>
                        <span class="pajak-status-copy">
                            <strong><?= htmlspecialchars($option['title']) ?></strong>
                            <small><?= htmlspecialchars($option['description']) ?></small>
                        </span>
                        <span class="pajak-status-pill"><?= htmlspecialchars($option['button']) ?></span>
                    </label>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="pajak-verify-actions">
            <a class="pajak-cancel-button" href="index.php?page=pajak">Batal</a>
            <button class="pajak-save-button" type="submit">
                Simpan Perubahan
                <span aria-hidden="true">&rsaquo;</span>
            </button>
        </div>
    </form>
</section>
