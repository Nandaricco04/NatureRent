<?php
require_once __DIR__ . '/../repositories/owner_repository.php';
require_once __DIR__ . '/../config/supabase.php';

$ownerId = (int) ($_GET['id'] ?? 0);

if ($ownerId <= 0) {
    header('Location: index.php?page=owners');
    exit;
}

$successMsg = '';
$errorMsg   = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $newStatus = $_POST['status_verifikasi'] ?? '';
    $allowed   = ['pending', 'approved', 'rejected', 'inactive'];

    if (in_array($newStatus, $allowed, true)) {
        $result = updateOwnerStatus($ownerId, $newStatus);
        if ($result['ok']) {
            header('Location: index.php?page=owners');
            exit;
        } else {
            $errorMsg = 'Gagal memperbarui status. Silakan coba lagi.';
        }
    } else {
        $errorMsg = 'Status tidak valid.';
    }
}

$owner = findOwnerById($ownerId);

if ($owner === null) {
    header('Location: index.php?page=owners');
    exit;
}

$currentStatus = strtolower($owner['status_verifikasi'] ?? 'pending');
$namaKota      = $owner['lokasi']['nama_kota'] ?? '-';

function fotoPublicUrl(?string $path): string
{
    if (empty($path)) return '';
    if (str_starts_with($path, 'http')) return $path;
    return rtrim(SUPABASE_URL, '/') . '/storage/v1/object/public/dokumen-owner/' . ltrim($path, '/');
}

function verifField(string $label, string $value, string $icon): string
{
    $val = htmlspecialchars($value ?: '-');
    return <<<HTML
    <div class="verif-field">
        <label class="verif-label">{$label}</label>
        <div class="verif-input">
            <iconify-icon icon="{$icon}" class="verif-input-icon"></iconify-icon>
            <span>{$val}</span>
        </div>
    </div>
    HTML;
}

function verifFotoField(string $label, ?string $path, string $icon): string
{
    $url     = fotoPublicUrl($path);
    $display = htmlspecialchars(basename($path ?: '-'));

    if ($url) {
        $content = <<<HTML
        <a href="{$url}" target="_blank" class="verif-foto-link" title="Klik untuk lihat foto">
            <iconify-icon icon="{$icon}" class="verif-input-icon"></iconify-icon>
            <span>{$display}</span>
            <iconify-icon icon="tabler:external-link" class="verif-foto-ext"></iconify-icon>
        </a>
        HTML;
    } else {
        $content = <<<HTML
        <div class="verif-input">
            <iconify-icon icon="{$icon}" class="verif-input-icon"></iconify-icon>
            <span style="color:#9E9E9E;">Belum diupload</span>
        </div>
        HTML;
    }

    return <<<HTML
    <div class="verif-field">
        <label class="verif-label">{$label}</label>
        {$content}
    </div>
    HTML;
}
?>

<div class="verif-wrap">

    <div class="verif-header">
        <div class="verif-header-icon">
            <iconify-icon icon="tabler:building-store"></iconify-icon>
        </div>
        <div>
            <p class="verif-header-title">Verifikasi Owner</p>
            <p class="verif-header-sub">Cek semua informasi untuk verifikasi owner</p>
        </div>
    </div>

    <?php if ($successMsg): ?>
        <div class="verif-alert success"><?= htmlspecialchars($successMsg) ?></div>
    <?php endif; ?>
    <?php if ($errorMsg): ?>
        <div class="verif-alert error"><?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <form method="POST" action="index.php?page=owners&action=detail&id=<?= $ownerId ?>">

        <div class="verif-grid">
            <?= verifField('Nama Toko',      $owner['nama_toko']      ?? '', 'tabler:building-store') ?>
            <?= verifField('No Telepon',     $owner['nomor_telepon']  ?? '', 'tabler:phone') ?>
            <?= verifField('Kota',           $namaKota,                      'tabler:building') ?>
            <?= verifField('Jam Operasional',$owner['jam_operasional'] ?? '', 'tabler:clock') ?>
        </div>
        <div class="verif-grid full" style="margin-top:14px;">
            <?= verifField('Alamat', $owner['alamat'] ?? '', 'tabler:map-pin') ?>
        </div>

        <hr class="verif-divider">
        <p class="verif-section-title">Dokumen</p>
        <div class="verif-grid">
            <?= verifFotoField('Foto KTP',          $owner['foto_ktp']          ?? '', 'tabler:id-badge') ?>
            <?= verifFotoField('Foto NPWP',         $owner['foto_npwp']         ?? '', 'tabler:file-invoice') ?>
            <?= verifFotoField('Foto Tempat Usaha', $owner['foto_tempat_usaha'] ?? '', 'tabler:building-store') ?>
            <?= verifFotoField('Foto NIB',          $owner['foto_nib']          ?? '', 'tabler:license') ?>
        </div>

        <hr class="verif-divider">
        <p class="verif-section-title">Data Keuangan</p>
        <div class="verif-grid">
            <?= verifField('Pilih Bank',     $owner['bank']           ?? '', 'tabler:building-bank') ?>
            <?= verifField('Nomor Rekening', $owner['nomor_rekening'] ?? '', 'tabler:credit-card') ?>
        </div>

        <hr class="verif-divider">
        <p class="verif-section-title">Status Verifikasi</p>

        <div class="verif-status-list">
            <label class="verif-status-item">
                <input type="radio" name="status_verifikasi" value="pending"
                    <?= $currentStatus === 'pending' ? 'checked' : '' ?>>
                <div class="verif-status-text">
                    <p class="verif-status-name">Pending</p>
                    <p class="verif-status-desc">Akun belum diverifikasi, menunggu tinjauan admin</p>
                </div>
                <span class="verif-status-badge" style="background:#FAEEDA;color:#854F0B;">Pending</span>
            </label>

            <label class="verif-status-item">
                <input type="radio" name="status_verifikasi" value="approved"
                    <?= $currentStatus === 'approved' ? 'checked' : '' ?>>
                <div class="verif-status-text">
                    <p class="verif-status-name">Approve</p>
                    <p class="verif-status-desc">Akun aktif dan dapat menerima pesanan dari pelanggan</p>
                </div>
                <span class="verif-status-badge" style="background:#E1F5EE;color:#0F6E56;">Approved</span>
            </label>

            <label class="verif-status-item">
                <input type="radio" name="status_verifikasi" value="rejected"
                    <?= $currentStatus === 'rejected' ? 'checked' : '' ?>>
                <div class="verif-status-text">
                    <p class="verif-status-name">Rejected</p>
                    <p class="verif-status-desc">Pendaftaran ditolak, akun tidak dapat digunakan</p>
                </div>
                <span class="verif-status-badge" style="background:#FCEBEB;color:#A32D2D;">Rejected</span>
            </label>

            <label class="verif-status-item">
                <input type="radio" name="status_verifikasi" value="inactive"
                    <?= $currentStatus === 'inactive' ? 'checked' : '' ?>>
                <div class="verif-status-text">
                    <p class="verif-status-name">Inactive</p>
                    <p class="verif-status-desc">Akun sudah tidak aktif lagi, tidak dapat digunakan</p>
                </div>
                <span class="verif-status-badge" style="background:#F1EFE8;color:#5F5E5A;">Inactive</span>
            </label>
        </div>

        <div class="verif-footer">
            <a href="index.php?page=owners" class="verif-btn-batal">Batal</a>
            <button type="submit" class="verif-btn-simpan">
                Simpan Perubahan
                <iconify-icon icon="tabler:chevron-right"></iconify-icon>
            </button>
        </div>

    </form>
</div>