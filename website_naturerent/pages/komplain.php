<?php

require_once __DIR__ . '/../repositories/komplain_repository.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $aksi = $_POST['aksi'] ?? '';

    if ($aksi === 'update_status') {
        $id     = (int)($_POST['id'] ?? 0);
        $status = $_POST['status'] ?? '';
        if ($id && in_array($status, ['Menunggu', 'Diproses', 'Selesai'])) {
            KomplainRepository::updateStatus($id, $status);
        }
    }

    if ($aksi === 'hapus') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id) KomplainRepository::remove($id);
    }

    $qs = http_build_query(array_filter([
        'page'    => 'komplain',  
        'status'  => $_POST['filter_status']  ?? '',
        'keyword' => $_POST['filter_keyword'] ?? '',
        'p'       => $_POST['page_num']       ?? 1,
    ]));
    header("Location: index.php?$qs");
    exit;
}

$filterStatus  = $_GET['status']  ?? 'Semua';
$filterKeyword = $_GET['keyword'] ?? '';
$currentPage   = max(1, (int)($_GET['p'] ?? 1));
$perPage       = 5;

$allData     = KomplainRepository::getAll($filterStatus, $filterKeyword);
$summary     = KomplainRepository::getSummary();
$total       = count($allData);
$lastPage    = max(1, (int)ceil($total / $perPage));
$currentPage = min($currentPage, $lastPage);
$offset      = ($currentPage - 1) * $perPage;
$pageData    = array_slice($allData, $offset, $perPage);

function komplainStatusBadge(string $s): string
{
    $map = [
        'Menunggu' => ['bg' => '#FAEEDA', 'color' => '#854F0B'],
        'Diproses' => ['bg' => '#FEF9C3', 'color' => '#854D0E'],
        'Selesai'  => ['bg' => '#E1F5EE', 'color' => '#0F6E56'],
    ];
    $style = $map[$s] ?? ['bg' => '#F1EFE8', 'color' => '#5F5E5A'];
    return sprintf(
        '<span style="background:%s;color:%s;padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;">%s</span>',
        $style['bg'], $style['color'], htmlspecialchars($s)
    );
}

function komplainTruncate(string $str, int $max = 35): string
{
    return mb_strlen($str) > $max ? mb_substr($str, 0, $max) . '...' : $str;
}

function komplainPageUrl(int $p, string $status, string $keyword): string
{
    $params = ['page' => 'komplain', 'p' => $p];
    if ($status !== 'Semua') $params['status'] = $status;
    if ($keyword !== '') $params['keyword'] = $keyword;
    return 'index.php?' . http_build_query($params);
}

function komplainFormatTanggal(string $ts): string
{
    if (!$ts) return '—';
    return date('d M Y, H:i', strtotime($ts));
}
?>

<div class="komplain-wrap">

    <div class="komplain-stat-grid">

        <div class="komplain-stat-card">
            <div class="komplain-stat-top">
                <div class="komplain-stat-icon" style="background:#E8F0FE;">
                    <iconify-icon icon="tabler:message-report" style="color:#2563EB;"></iconify-icon>
                </div>
                <span class="komplain-stat-badge" style="background:#E8F0FE;color:#2563EB;">Semua</span>
            </div>
            <p class="komplain-stat-label">Total Komplain</p>
            <p class="komplain-stat-value"><?= $summary['total'] ?></p>
            <p class="komplain-stat-sub">Semua komplain masuk</p>
        </div>

        <div class="komplain-stat-card">
            <div class="komplain-stat-top">
                <div class="komplain-stat-icon" style="background:#FAEEDA;">
                    <iconify-icon icon="tabler:clock" style="color:#854F0B;"></iconify-icon>
                </div>
                <span class="komplain-stat-badge" style="background:#FAEEDA;color:#854F0B;">Menunggu</span>
            </div>
            <p class="komplain-stat-label">Belum Ditangani</p>
            <p class="komplain-stat-value"><?= $summary['menunggu'] ?></p>
            <p class="komplain-stat-sub">Perlu segera ditinjau</p>
        </div>

        <div class="komplain-stat-card">
            <div class="komplain-stat-top">
                <div class="komplain-stat-icon" style="background:#FEF9C3;">
                    <iconify-icon icon="tabler:settings" style="color:#854D0E;"></iconify-icon>
                </div>
                <span class="komplain-stat-badge" style="background:#FEF9C3;color:#854D0E;">Diproses</span>
            </div>
            <p class="komplain-stat-label">Diproses</p>
            <p class="komplain-stat-value"><?= $summary['diproses'] ?></p>
            <p class="komplain-stat-sub">Sedang ditangani</p>
        </div>

        <div class="komplain-stat-card">
            <div class="komplain-stat-top">
                <div class="komplain-stat-icon" style="background:#E1F5EE;">
                    <iconify-icon icon="tabler:circle-check" style="color:#0F6E56;"></iconify-icon>
                </div>
                <span class="komplain-stat-badge" style="background:#E1F5EE;color:#0F6E56;">Selesai</span>
            </div>
            <p class="komplain-stat-label">Selesai</p>
            <p class="komplain-stat-value"><?= $summary['selesai'] ?></p>
            <p class="komplain-stat-sub">Komplain terselesaikan</p>
        </div>

    </div>

    <div class="komplain-table-card">

        <!-- Toolbar -->
        <div class="komplain-table-header">
            <h2 class="komplain-table-title">Daftar Komplain</h2>
            <div class="komplain-toolbar">
                <form method="GET" action="index.php" id="komplainFilterForm">
                    <input type="hidden" name="page" value="komplain">
                    <input type="hidden" name="status" id="hiddenStatus" 
                        value="<?= htmlspecialchars($filterStatus === 'Semua' ? '' : $filterStatus) ?>">
                    <div class="komplain-search-box">
                        <iconify-icon icon="tabler:search"></iconify-icon>
                        <input
                            type="text"
                            name="keyword"    
                            id="komplainKeyword"
                            placeholder="Cari nama atau ID pesanan"
                            value="<?= htmlspecialchars($filterKeyword) ?>"
                        >
                    </div>
                </form>
                <div class="komplain-filter-wrap">
                    <select class="komplain-filter-sel" id="komplainStatusFilter" onchange="komplainFilterChange()">
                        <?php foreach (['Semua', 'Menunggu', 'Diproses', 'Selesai'] as $s): ?>
                            <option value="<?= $s ?>" <?= $filterStatus === $s ? 'selected' : '' ?>>
                                <?= $s === 'Semua' ? 'Semua status' : $s ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <div class="komplain-table-wrap">
            <table class="komplain-table">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Nama Pengguna</th>
                        <th>Kategori</th>
                        <th>Deskripsi</th>
                        <th>ID Pesanan</th>
                        <th>Tanggal</th>
                        <th>Status</th>
                        <th style="text-align:center;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($pageData)): ?>
                        <tr>
                            <td colspan="8" style="text-align:center;padding:36px;color:#9E9E9E;">
                                Tidak ada data komplain ditemukan.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($pageData as $i => $row): ?>
                            <tr>
                                <td><?= $offset + $i + 1 ?></td>
                                <td>
                                    <strong><?= htmlspecialchars($row['nama_pengguna'] ?? '-') ?></strong>
                                    <div style="font-size:11.5px;color:#9e9e9e;margin-top:2px;">
                                        <?= htmlspecialchars($row['email'] ?? '') ?>
                                    </div>
                                </td>
                                <td><?= htmlspecialchars($row['category'] ?? '-') ?></td>
                                <td class="komplain-td-masalah" title="<?= htmlspecialchars($row['description'] ?? '') ?>">
                                    <?= htmlspecialchars(komplainTruncate($row['description'] ?? '')) ?>
                                </td>
                                <td class="komplain-td-id"><?= htmlspecialchars($row['id_pesanan'] ?? '-') ?></td>
                                <td style="font-size:12px;color:#6d6a66;white-space:nowrap;">
                                    <?= komplainFormatTanggal($row['created_at'] ?? '') ?>
                                </td>
                                <td><?= komplainStatusBadge($row['status'] ?? 'Menunggu') ?></td>
                                <td>
                                    <div class="komplain-aksi" style="justify-content:center;">
                                        <a href="index.php?page=komplain&action=detail&id=<?= (int)$row['id_support'] ?>"
                                            class="komplain-btn komplain-btn-edit"
                                            title="Detail & Ubah Status">
                                                <iconify-icon icon="tabler:clipboard-text"></iconify-icon>
                                            </a>
                                        <button
                                            type="button"
                                            class="komplain-btn komplain-btn-hapus"
                                            title="Hapus"
                                            onclick="komplainOpenHapus(<?= (int)$row['id_support'] ?>, '<?= htmlspecialchars(addslashes($row['nama_pengguna'] ?? '')) ?>')"
                                        >
                                            <iconify-icon icon="tabler:trash"></iconify-icon>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="komplain-pagination-wrap">
            <span>
                Menampilkan
                <?= $total === 0 ? 0 : $offset + 1 ?>–<?= min($offset + $perPage, $total) ?>
                dari <?= $total ?> data
            </span>
            <div class="komplain-pagination">
                <a href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(komplainPageUrl($currentPage - 1, $filterStatus, $filterKeyword)) ?>"
                   class="komplain-page-btn <?= $currentPage <= 1 ? 'disabled' : '' ?>">
                    <iconify-icon icon="tabler:arrow-left"></iconify-icon>
                </a>

                <?php for ($p = 1; $p <= $lastPage; $p++): ?>
                    <a href="<?= htmlspecialchars(komplainPageUrl($p, $filterStatus, $filterKeyword)) ?>"
                       class="komplain-page-btn <?= $p === $currentPage ? 'active' : '' ?>">
                        <?= $p ?>
                    </a>
                <?php endfor; ?>

                <a href="<?= $currentPage >= $lastPage ? '#' : htmlspecialchars(komplainPageUrl($currentPage + 1, $filterStatus, $filterKeyword)) ?>"
                   class="komplain-page-btn <?= $currentPage >= $lastPage ? 'disabled' : '' ?>">
                    <iconify-icon icon="tabler:arrow-right"></iconify-icon>
                </a>
            </div>
        </div>

    </div>

</div>

<div class="komplain-modal-overlay" id="komplainModalDetail">
    <div class="komplain-modal-box">
        <button class="komplain-modal-close" onclick="komplainCloseModal('komplainModalDetail')">&#215;</button>
        <div class="komplain-modal-title">Detail Komplain</div>

        <div class="km-row">
            <span class="km-lbl">Nama Pengguna</span>
            <span class="km-val" id="km-nama">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">Email</span>
            <span class="km-val" id="km-email">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">No. Telepon</span>
            <span class="km-val" id="km-telp">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">ID Pesanan</span>
            <span class="km-val" id="km-id">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">Kategori</span>
            <span class="km-val" id="km-kategori">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">Tanggal</span>
            <span class="km-val" id="km-tgl">—</span>
        </div>
        <div class="km-row">
            <span class="km-lbl">Status</span>
            <span class="km-val" id="km-status">—</span>
        </div>
        <div class="km-row" style="flex-direction:column;gap:5px;">
            <span class="km-lbl">Deskripsi</span>
            <div class="km-detail-box" id="km-deskripsi">—</div>
        </div>
        <div class="km-row" id="km-attachment-row" style="display:none;">
            <span class="km-lbl">Lampiran</span>
            <span class="km-val">
                <a id="km-attachment" href="#" target="_blank"
                   style="color:#297b2d;font-weight:600;font-size:13px;">
                   Lihat Lampiran
                </a>
            </span>
        </div>

        <div class="km-divider"></div>

        <form method="POST" action="index.php">
            <input type="hidden" name="aksi"           value="update_status">
            <input type="hidden" name="id"             id="km-form-id">
            <input type="hidden" name="filter_status"  value="<?= htmlspecialchars($filterStatus) ?>">
            <input type="hidden" name="filter_keyword" value="<?= htmlspecialchars($filterKeyword) ?>">
            <input type="hidden" name="page_num"       value="<?= $currentPage ?>">
            <div class="km-status-row">
                <label>Ubah Status:</label>
                <select name="status" id="km-sel-status" class="km-sel">
                    <option value="Menunggu">Menunggu</option>
                    <option value="Diproses">Diproses</option>
                    <option value="Selesai">Selesai</option>
                </select>
                <button type="submit" class="km-btn-simpan">Simpan</button>
            </div>
        </form>
    </div>
</div>

<div class="komplain-modal-overlay" id="komplainModalHapus">
    <div class="komplain-modal-box" style="max-width:380px;text-align:center;padding:36px 28px;">
        <div class="km-hapus-icon">
            <iconify-icon icon="tabler:trash"></iconify-icon>
        </div>
        <p class="km-hapus-title">Hapus Komplain?</p>
        <p class="km-hapus-desc">Anda yakin akan menghapus komplain ini?</p>
        <form method="POST" action="index.php?page=komplain">
            <input type="hidden" name="aksi"           value="hapus">
            <input type="hidden" name="id"             id="km-hapus-id">
            <input type="hidden" name="filter_status"  value="<?= htmlspecialchars($filterStatus) ?>">
            <input type="hidden" name="filter_keyword" value="<?= htmlspecialchars($filterKeyword) ?>">
            <input type="hidden" name="page_num"       value="<?= $currentPage ?>">
            <div class="km-hapus-actions">
                <button type="button" class="km-hapus-batal"
                    onclick="komplainCloseModal('komplainModalHapus')">Batal</button>
                <button type="submit" class="km-hapus-konfirm">Ya, Hapus</button>
            </div>
        </form>
    </div>
</div>

<script>
const _komplainData = <?= json_encode(
    array_values(KomplainRepository::getAll()),
    JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT
) ?>;

function kmBadge(s) {
    const map = {
        Menunggu : { bg: '#FAEEDA', color: '#854F0B' },
        Diproses : { bg: '#FEF9C3', color: '#854D0E' },
        Selesai  : { bg: '#E1F5EE', color: '#0F6E56' },
    };
    const st = map[s] ?? { bg: '#F1EFE8', color: '#5F5E5A' };
    return `<span style="background:${st.bg};color:${st.color};padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;">${s}</span>`;
}

function kmFormatTgl(ts) {
    if (!ts) return '—';
    const d = new Date(ts);
    return d.toLocaleDateString('id-ID', { day:'2-digit', month:'short', year:'numeric' })
         + ', ' + d.toLocaleTimeString('id-ID', { hour:'2-digit', minute:'2-digit' });
}

function komplainOpenDetail(id) {
    const r = _komplainData.find(x => x.id_support == id);
    if (!r) return;

    document.getElementById('km-nama').textContent      = r.nama_pengguna ?? '—';
    document.getElementById('km-email').textContent     = r.email          ?? '—';
    document.getElementById('km-telp').textContent      = r.no_telepon     ?? '—';
    document.getElementById('km-id').textContent        = r.id_pesanan     ?? '—';
    document.getElementById('km-kategori').textContent  = r.category       ?? '—';
    document.getElementById('km-tgl').textContent       = kmFormatTgl(r.created_at);
    document.getElementById('km-deskripsi').textContent = r.description    ?? '—';
    document.getElementById('km-status').innerHTML      = kmBadge(r.status ?? 'Menunggu');
    document.getElementById('km-form-id').value         = r.id_support;
    document.getElementById('km-sel-status').value      = r.status ?? 'Menunggu';

    const attachRow = document.getElementById('km-attachment-row');
    if (r.attachment_url) {
        document.getElementById('km-attachment').href = r.attachment_url;
        attachRow.style.display = 'flex';
    } else {
        attachRow.style.display = 'none';
    }

    document.getElementById('komplainModalDetail').classList.add('open');
}

function komplainOpenHapus(id, nama) {
    document.getElementById('km-hapus-id').value       = id;
    document.getElementById('komplainModalHapus').classList.add('open');
}

function komplainCloseModal(id) {
    document.getElementById(id).classList.remove('open');
}

document.querySelectorAll('.komplain-modal-overlay').forEach(el => {
    el.addEventListener('click', e => { if (e.target === el) el.classList.remove('open'); });
});

function komplainFilterChange() {
    const val = document.getElementById('komplainStatusFilter').value;
    document.getElementById('hiddenStatus').value = val !== 'Semua' ? val : '';
    document.getElementById('komplainFilterForm').submit();
}

let _kmTimer;
document.getElementById('komplainKeyword').addEventListener('input', function () {
    clearTimeout(_kmTimer);
    _kmTimer = setTimeout(() => document.getElementById('komplainFilterForm').submit(), 500);
});
</script>