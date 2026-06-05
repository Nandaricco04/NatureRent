<?php
require_once __DIR__ . '/../repositories/komplain_repository.php';

$id = (int) ($_GET['id'] ?? 0);

if ($id <= 0) {
    header('Location: index.php?page=komplain');
    exit;
}

$successMsg = '';
$errorMsg   = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $newStatus = $_POST['status'] ?? '';
    $allowed   = ['Menunggu', 'Diproses', 'Selesai'];

    if (in_array($newStatus, $allowed, true)) {
        $ok = KomplainRepository::updateStatus($id, $newStatus);
        if ($ok) {
            header('Location: index.php?page=komplain');
            exit;
        } else {
            $errorMsg = 'Gagal memperbarui status. Silakan coba lagi.';
        }
    }
}

$row = KomplainRepository::getById($id);

if ($row === null) {
    header('Location: index.php?page=komplain');
    exit;
}

$currentStatus = $row['status'] ?? 'Menunggu';

function detailFormatTanggal(?string $ts): string
{
    if (!$ts) return '—';
    return date('d M Y, H:i', strtotime($ts));
}

function detailField(string $label, string $value, string $icon): string
{
    $val = htmlspecialchars($value ?: '—');
    return <<<HTML
    <div class="kd-field">
        <label class="kd-label">{$label}</label>
        <div class="kd-input">
            <iconify-icon icon="{$icon}" class="kd-input-icon"></iconify-icon>
            <span>{$val}</span>
        </div>
    </div>
    HTML;
}
?>

<div class="kd-wrap">

    <div class="kd-header">
        <div class="kd-header-icon">
            <iconify-icon icon="tabler:user-search"></iconify-icon>
        </div>
        <div>
            <p class="kd-header-title">Detail Komplain</p>
            <p class="kd-header-sub">Tinjau detail komplain dan perbarui statusnya</p>
        </div>
    </div>

    <?php if ($successMsg): ?>
        <div class="kd-alert success"><?= htmlspecialchars($successMsg) ?></div>
    <?php endif; ?>
    <?php if ($errorMsg): ?>
        <div class="kd-alert error"><?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <form method="POST" action="index.php?page=komplain&action=detail&id=<?= $id ?>">

        <p class="kd-section-title">Informasi Pengguna</p>
        <div class="kd-grid full">
            <?= detailField('Nama Pengguna', $row['nama_pengguna'] ?? '', 'tabler:user') ?>
        </div>
        <div class="kd-grid" style="margin-top:14px;">
            <?= detailField('Email',         $row['email']          ?? '', 'tabler:mail') ?>
            <?= detailField('Nomor Telepon', $row['nomor_telepon']  ?? '', 'tabler:phone') ?>
        </div>

        <hr class="kd-divider">

        <p class="kd-section-title">Detail Komplain</p>
        <div class="kd-grid">
            <?= detailField('ID Pesanan', $row['id_pesanan'] ?? '', 'tabler:receipt') ?>
            <?= detailField('Kategori',   $row['category']  ?? '', 'tabler:tag') ?>
        </div>

        <div class="kd-field" style="margin-top:14px;">
            <label class="kd-label">Deskripsi Masalah</label>
            <textarea class="kd-textarea" readonly><?= htmlspecialchars($row['description'] ?? '') ?></textarea>
        </div>

        <div class="kd-grid" style="margin-top:14px;">
            <div class="kd-field">
                <label class="kd-label">Lampiran</label>
                <?php if (!empty($row['attachment_url'])): ?>
                    <a href="<?= htmlspecialchars($row['attachment_url']) ?>"
                        target="_blank"
                        class="kd-lampiran-link">
                            <iconify-icon icon="tabler:photo" class="kd-input-icon"></iconify-icon>
                            <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:200px;">
                                <?= htmlspecialchars(basename($row['attachment_url'])) ?>
                            </span>
                            <iconify-icon icon="tabler:external-link" class="kd-lampiran-ext"></iconify-icon>
                    </a>
                <?php else: ?>
                    <div class="kd-input">
                        <iconify-icon icon="tabler:photo" class="kd-input-icon"></iconify-icon>
                        <span style="color:#9E9E9E;">Tidak ada lampiran</span>
                    </div>
                <?php endif; ?>
            </div>

            <?= detailField('Tanggal Masuk', detailFormatTanggal($row['created_at'] ?? ''), 'tabler:calendar') ?>
        </div>

        <hr class="kd-divider">

        <p class="kd-section-title">Status Komplain</p>

        <div class="kd-status-list">
            <label class="kd-status-item">
                <input type="radio" name="status" value="Menunggu"
                    <?= $currentStatus === 'Menunggu' ? 'checked' : '' ?>>
                <div class="kd-status-text">
                    <p class="kd-status-name">Menunggu</p>
                    <p class="kd-status-desc">Komplain baru masuk, belum ada tindakan dari admin</p>
                </div>
                <span class="kd-status-badge" style="background:#FAEEDA;color:#854F0B;">Menunggu</span>
            </label>

            <label class="kd-status-item">
                <input type="radio" name="status" value="Diproses"
                    <?= $currentStatus === 'Diproses' ? 'checked' : '' ?>>
                <div class="kd-status-text">
                    <p class="kd-status-name">Diproses</p>
                    <p class="kd-status-desc">Admin sedang meninjau dan menangani komplain ini</p>
                </div>
                <span class="kd-status-badge" style="background:#FEF9C3;color:#854D0E;">Diproses</span>
            </label>

            <label class="kd-status-item">
                <input type="radio" name="status" value="Selesai"
                    <?= $currentStatus === 'Selesai' ? 'checked' : '' ?>>
                <div class="kd-status-text">
                    <p class="kd-status-name">Selesai</p>
                    <p class="kd-status-desc">Komplain telah ditangani dan diselesaikan</p>
                </div>
                <span class="kd-status-badge" style="background:#E1F5EE;color:#0F6E56;">Selesai</span>
            </label>
        </div>

        <div class="kd-footer">
            <a href="index.php?page=komplain" class="kd-btn-batal">Batal</a>
            <button type="submit" class="kd-btn-simpan">
                Simpan Perubahan
                <iconify-icon icon="tabler:chevron-right"></iconify-icon>
            </button>
        </div>

    </form>
</div>