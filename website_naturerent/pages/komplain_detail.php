<?php
// pages/komplain_detail.php

require_once __DIR__ . '/../repositories/komplain_repository.php';

// ── Ambil ID dari URL ──────────────────────────────────────────────────────
$id = (int) ($_GET['id'] ?? 0);

if ($id <= 0) {
    header('Location: index.php?page=komplain');
    exit;
}

// ── Handle simpan status ───────────────────────────────────────────────────
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

// ── Ambil data komplain ────────────────────────────────────────────────────
$row = KomplainRepository::getById($id);

if ($row === null) {
    header('Location: index.php?page=komplain');
    exit;
}

$currentStatus = $row['status'] ?? 'Menunggu';

// ── Helper: format tanggal ─────────────────────────────────────────────────
function detailFormatTanggal(?string $ts): string
{
    if (!$ts) return '—';
    return date('d M Y, H:i', strtotime($ts));
}

// ── Helper: render field readonly ─────────────────────────────────────────
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

<style>
.kd-wrap {
    margin: 24px 32px 40px;
    background: #fff;
    border-radius: 14px;
    padding: 28px 32px;
    border: 1px solid #E8E2DC;
}

/* ── Header ── */
.kd-header {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 28px;
}

.kd-header-icon {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    background: #EAF6EC;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 26px;
    color: #297B2D;
    flex-shrink: 0;
}

.kd-header-title {
    font-size: 18px;
    font-weight: 700;
    color: #212121;
    margin: 0 0 4px;
}

.kd-header-sub {
    font-size: 13px;
    color: #6D6A66;
    margin: 0;
}

/* ── Alert ── */
.kd-alert {
    padding: 12px 16px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    margin-bottom: 20px;
}

.kd-alert.success { background: #E1F5EE; color: #0F6E56; }
.kd-alert.error   { background: #FCEBEB; color: #A32D2D; }

/* ── Section title ── */
.kd-section-title {
    font-size: 15px;
    font-weight: 700;
    color: #212121;
    margin: 0 0 14px;
}

/* ── Grid fields ── */
.kd-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}

.kd-grid.full { grid-template-columns: 1fr; }

.kd-field { display: flex; flex-direction: column; gap: 6px; }

.kd-label {
    font-size: 12px;
    font-weight: 600;
    color: #6D6A66;
}

.kd-input {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 10px;
    border: 1px solid #E8E2DC;
    border-radius: 8px;
    padding: 10px 14px;
    background: #F9F8F6;
    font-size: 13px;
    color: #212121;
    min-height: 42px;
}

.kd-input-icon {
    font-size: 16px;
    color: #297B2D;
    flex-shrink: 0;
}

/* ── Textarea deskripsi ── */
.kd-textarea {
    width: 100%;
    min-height: 90px;
    border: 1px solid #E8E2DC;
    border-radius: 8px;
    padding: 10px 14px;
    background: #F9F8F6;
    font-size: 13px;
    color: #212121;
    font-family: 'Poppins', sans-serif;
    resize: none;
    box-sizing: border-box;
    line-height: 1.6;
}

/* ── Lampiran link ── */
.kd-lampiran-link {
    display: flex;
    align-items: center;
    gap: 10px;
    border: 1px solid #E8E2DC;
    border-radius: 8px;
    padding: 10px 14px;
    background: #F9F8F6;
    font-size: 13px;
    color: #212121;
    text-decoration: none;
    transition: background 0.15s, border-color 0.15s;
    min-height: 42px;
}

.kd-lampiran-link:hover {
    background: #EAF6EC;
    border-color: #297B2D;
    color: #297B2D;
}

.kd-lampiran-ext {
    margin-left: auto;
    font-size: 14px;
    color: #9E9E9E;
}

/* ── Divider ── */
.kd-divider {
    border: none;
    border-top: 1px solid #F0EDE8;
    margin: 24px 0;
}

/* ── Status list ── */
.kd-status-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.kd-status-item {
    display: flex;
    align-items: center;
    gap: 14px;
    border: 1.5px solid #E8E2DC;
    border-radius: 10px;
    padding: 14px 16px;
    cursor: pointer;
    transition: border-color 0.15s, background 0.15s;
}

.kd-status-item:has(input:checked) {
    border-color: #297B2D;
    background: #F4FBF4;
}

.kd-status-item input[type="radio"] {
    width: 18px;
    height: 18px;
    accent-color: #297B2D;
    flex-shrink: 0;
    cursor: pointer;
}

.kd-status-text { flex: 1; }

.kd-status-name {
    font-size: 14px;
    font-weight: 700;
    color: #212121;
    margin: 0 0 2px;
}

.kd-status-desc {
    font-size: 12px;
    color: #6D6A66;
    margin: 0;
}

.kd-status-badge {
    font-size: 11px;
    font-weight: 600;
    padding: 4px 12px;
    border-radius: 20px;
}

/* ── Footer ── */
.kd-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 28px;
    padding-top: 20px;
    border-top: 1px solid #F0EDE8;
}

.kd-btn-batal {
    height: 40px;
    padding: 0 24px;
    border-radius: 8px;
    border: 1.5px solid #212121;
    background: #fff;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    font-family: 'Poppins', sans-serif;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    color: #212121;
    transition: background 0.15s;
}

.kd-btn-batal:hover { background: #F5F2ED; }

.kd-btn-simpan {
    height: 40px;
    padding: 0 24px;
    border-radius: 8px;
    border: none;
    background: #297B2D;
    color: #fff;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    font-family: 'Poppins', sans-serif;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: background 0.15s;
}

.kd-btn-simpan:hover { background: #1f6022; }
</style>

<div class="kd-wrap">

    <!-- ── Header ── -->
    <div class="kd-header">
        <div class="kd-header-icon">
            <iconify-icon icon="tabler:user-search"></iconify-icon>
        </div>
        <div>
            <p class="kd-header-title">Detail Komplain</p>
            <p class="kd-header-sub">Tinjau detail komplain dan perbarui statusnya</p>
        </div>
    </div>

    <!-- ── Alert ── -->
    <?php if ($successMsg): ?>
        <div class="kd-alert success"><?= htmlspecialchars($successMsg) ?></div>
    <?php endif; ?>
    <?php if ($errorMsg): ?>
        <div class="kd-alert error"><?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <form method="POST" action="index.php?page=komplain&action=detail&id=<?= $id ?>">

        <!-- ── Informasi Pengguna ── -->
        <p class="kd-section-title">Informasi Pengguna</p>
        <div class="kd-grid full">
            <?= detailField('Nama Pengguna', $row['nama_pengguna'] ?? '', 'tabler:user') ?>
        </div>
        <div class="kd-grid" style="margin-top:14px;">
            <?= detailField('Email',         $row['email']          ?? '', 'tabler:mail') ?>
            <?= detailField('Nomor Telepon', $row['nomor_telepon']  ?? '', 'tabler:phone') ?>
        </div>

        <hr class="kd-divider">

        <!-- ── Detail Komplain ── -->
        <p class="kd-section-title">Detail Komplain</p>
        <div class="kd-grid">
            <?= detailField('ID Pesanan', $row['id_pesanan'] ?? '', 'tabler:receipt') ?>
            <?= detailField('Kategori',   $row['category']  ?? '', 'tabler:tag') ?>
        </div>

        <!-- Deskripsi -->
        <div class="kd-field" style="margin-top:14px;">
            <label class="kd-label">Deskripsi Masalah</label>
            <textarea class="kd-textarea" readonly><?= htmlspecialchars($row['description'] ?? '') ?></textarea>
        </div>

        <!-- Lampiran & Tanggal -->
        <div class="kd-grid" style="margin-top:14px;">
            <!-- Lampiran -->
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

            <!-- Tanggal Masuk -->
            <?= detailField('Tanggal Masuk', detailFormatTanggal($row['created_at'] ?? ''), 'tabler:calendar') ?>
        </div>

        <hr class="kd-divider">

        <!-- ── Status Komplain ── -->
        <p class="kd-section-title">Status Komplain</p>

        <div class="kd-status-list">
            <!-- Menunggu -->
            <label class="kd-status-item">
                <input type="radio" name="status" value="Menunggu"
                    <?= $currentStatus === 'Menunggu' ? 'checked' : '' ?>>
                <div class="kd-status-text">
                    <p class="kd-status-name">Menunggu</p>
                    <p class="kd-status-desc">Komplain baru masuk, belum ada tindakan dari admin</p>
                </div>
                <span class="kd-status-badge" style="background:#FAEEDA;color:#854F0B;">Menunggu</span>
            </label>

            <!-- Diproses -->
            <label class="kd-status-item">
                <input type="radio" name="status" value="Diproses"
                    <?= $currentStatus === 'Diproses' ? 'checked' : '' ?>>
                <div class="kd-status-text">
                    <p class="kd-status-name">Diproses</p>
                    <p class="kd-status-desc">Admin sedang meninjau dan menangani komplain ini</p>
                </div>
                <span class="kd-status-badge" style="background:#FEF9C3;color:#854D0E;">Diproses</span>
            </label>

            <!-- Selesai -->
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

        <!-- ── Footer ── -->
        <div class="kd-footer">
            <a href="index.php?page=komplain" class="kd-btn-batal">Batal</a>
            <button type="submit" class="kd-btn-simpan">
                Simpan Perubahan
                <iconify-icon icon="tabler:chevron-right"></iconify-icon>
            </button>
        </div>

    </form>
</div>

<script>
// Auto hide alert setelah 3 detik
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.kd-alert').forEach(function (el) {
        setTimeout(function () {
            el.style.transition = 'opacity 0.5s';
            el.style.opacity    = '0';
            setTimeout(function () { el.remove(); }, 500);
        }, 3000);
    });
});
</script>