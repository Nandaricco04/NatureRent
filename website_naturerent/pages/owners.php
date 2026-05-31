<?php
require_once __DIR__ . '/../repositories/owner_repository.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action  = $_POST['action'] ?? '';
    $ownerId = (int) ($_POST['owner_id'] ?? 0);

    if ($ownerId > 0) {
        if ($action === 'deactivate') {
            deactivateOwner($ownerId);
        } elseif ($action === 'activate') {
            activateOwner($ownerId);
        }
    }

    header('Location: index.php?page=owners');
    exit;
}

$owners = getAllOwners();
$counts = countOwnerByStatus();

$search = strtolower(trim($_GET['search'] ?? ''));
if ($search !== '') {
    $owners = array_values(array_filter($owners, function ($o) use ($search) {
        $namaToko = strtolower($o['nama_toko'] ?? '');
        $email    = strtolower($o['users']['email'] ?? '');
        return str_contains($namaToko, $search) || str_contains($email, $search);
    }));
}

$perPage     = 5;
$totalData   = count($owners);
$totalPages  = max(1, (int) ceil($totalData / $perPage));
$currentPage = max(1, min((int) ($_GET['p'] ?? 1), $totalPages));
$offset      = ($currentPage - 1) * $perPage;
$pageOwners  = array_slice($owners, $offset, $perPage);

function ownerPageUrl(int $page, string $keyword): string
{
    $params = ['page' => 'owners', 'p' => $page];
    if ($keyword !== '') $params['search'] = $keyword;
    return 'index.php?' . http_build_query($params);
}

function statusBadge(string $status): string
{
    $map = [
        'approved' => ['label' => 'Approved', 'color' => '#0F6E56', 'bg' => '#E1F5EE'],
        'pending'  => ['label' => 'Pending',  'color' => '#854F0B', 'bg' => '#FAEEDA'],
        'rejected' => ['label' => 'Rejected', 'color' => '#A32D2D', 'bg' => '#FCEBEB'],
        'inactive' => ['label' => 'Inactive', 'color' => '#5F5E5A', 'bg' => '#F1EFE8'],
    ];

    $s     = strtolower($status);
    $style = $map[$s] ?? ['label' => ucfirst($status), 'color' => '#555', 'bg' => '#eee'];

    return sprintf(
        '<span style="background:%s;color:%s;padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;">%s</span>',
        $style['bg'], $style['color'], htmlspecialchars($style['label'])
    );
}
?>

<div class="owner-stat-grid">
    <div class="owner-stat-card">
        <div class="owner-stat-top">
            <div class="owner-stat-icon" style="background:#E1F5EE;">
                <iconify-icon icon="tabler:circle-check" style="color:#0F6E56;"></iconify-icon>
            </div>
            <span class="owner-stat-badge" style="background:#E1F5EE;color:#0F6E56;">Approved</span>
        </div>
        <p class="owner-stat-label">Terverifikasi</p>
        <p class="owner-stat-value"><?= $counts['approved'] ?></p>
        <p class="owner-stat-sub">Aktif berjualan</p>
    </div>

    <div class="owner-stat-card">
        <div class="owner-stat-top">
            <div class="owner-stat-icon" style="background:#FAEEDA;">
                <iconify-icon icon="tabler:clock" style="color:#854F0B;"></iconify-icon>
            </div>
            <span class="owner-stat-badge" style="background:#FAEEDA;color:#854F0B;">Pending</span>
        </div>
        <p class="owner-stat-label">Menunggu Verifikasi</p>
        <p class="owner-stat-value"><?= $counts['pending'] ?></p>
        <p class="owner-stat-sub">Perlu ditinjau</p>
    </div>

    <div class="owner-stat-card">
        <div class="owner-stat-top">
            <div class="owner-stat-icon" style="background:#FCEBEB;">
                <iconify-icon icon="tabler:circle-x" style="color:#A32D2D;"></iconify-icon>
            </div>
            <span class="owner-stat-badge" style="background:#FCEBEB;color:#A32D2D;">Rejected</span>
        </div>
        <p class="owner-stat-label">Ditolak</p>
        <p class="owner-stat-value"><?= $counts['rejected'] ?></p>
        <p class="owner-stat-sub">Dokumen tidak sesuai</p>
    </div>

    <div class="owner-stat-card">
        <div class="owner-stat-top">
            <div class="owner-stat-icon" style="background:#F1EFE8;">
                <iconify-icon icon="tabler:user-off" style="color:#5F5E5A;"></iconify-icon>
            </div>
            <span class="owner-stat-badge" style="background:#F1EFE8;color:#5F5E5A;">Inactive</span>
        </div>
        <p class="owner-stat-label">Nonaktif</p>
        <p class="owner-stat-value"><?= $counts['inactive'] ?></p>
        <p class="owner-stat-sub">Akun dinonaktifkan</p>
    </div>
</div>

<div class="owner-table-card">
    <div class="owner-table-header">
        <h2 class="owner-table-title">Daftar Pemilik Rental</h2>
        <form method="GET" action="index.php">
            <input type="hidden" name="page" value="owners">
            <div class="owner-search-box">
                <iconify-icon icon="tabler:search" style="color:#9E9E9E;font-size:16px;flex-shrink:0;"></iconify-icon>
                <input
                    type="text"
                    name="search"
                    placeholder="Cari pemilik rental dari nama atau email"
                    value="<?= htmlspecialchars($_GET['search'] ?? '') ?>"
                    onchange="this.form.submit()"
                >
            </div>
        </form>
    </div>

    <div class="owner-table-wrap">
    <table class="owner-table">
        <thead>
            <tr>
                <th>No</th>
                <th>Nama Toko</th>
                <th>Email</th>
                <th>No. Telepon</th>
                <th>Kota</th>
                <th>Status</th>
                <th style="text-align:center;">Aksi</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($pageOwners)): ?>
                <tr>
                    <td colspan="7" style="text-align:center;padding:32px;color:#9E9E9E;">
                        Tidak ada data pemilik rental
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($pageOwners as $i => $owner):
                    $status   = strtolower($owner['status_verifikasi'] ?? 'pending');
                    $namaKota = $owner['lokasi']['nama_kota'] ?? '-';
                    $email    = $owner['users']['email'] ?? '-';
                    $no       = $offset + $i + 1;
                ?>
                <tr>
                    <td><?= $no ?></td>
                    <td><strong><?= htmlspecialchars($owner['nama_toko'] ?? '-') ?></strong></td>
                    <td style="color:#6D6A66;"><?= htmlspecialchars($email) ?></td>
                    <td><?= htmlspecialchars($owner['nomor_telepon'] ?? '-') ?></td>
                    <td><?= htmlspecialchars($namaKota) ?></td>
                    <td><?= statusBadge($status) ?></td>
                    <td style="text-align:right;">
                        <div style="display:flex;gap:8px;justify-content:flex-end;">
                            <a
                                href="index.php?page=owners&action=detail&id=<?= $owner['id_owner'] ?>"
                                class="owner-btn owner-btn-verify"
                                title="Verifikasi"
                            >
                                <iconify-icon icon="tabler:user-scan"></iconify-icon>
                            </a>

                            <?php if ($status === 'inactive'): ?>
                                <button
                                    class="owner-btn owner-btn-activate"
                                    title="Aktifkan kembali"
                                    onclick="ownerShowModal(<?= $owner['id_owner'] ?>, 'activate')"
                                >
                                    <iconify-icon icon="tabler:user-check"></iconify-icon>
                                </button>
                            <?php else: ?>
                                <button
                                    class="owner-btn owner-btn-inactive"
                                    title="Nonaktifkan"
                                    onclick="ownerShowModal(<?= $owner['id_owner'] ?>, 'deactivate')"
                                >
                                    <iconify-icon icon="tabler:user-off"></iconify-icon>
                                </button>
                            <?php endif; ?>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
    </div>

    <div class="owner-pagination-wrap">
        <span>
            Menampilkan <?= $totalData === 0 ? 0 : $offset + 1 ?>–<?= min($offset + $perPage, $totalData) ?>
            dari <?= $totalData ?> data
        </span>
        <div class="owner-pagination">
            <a href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(ownerPageUrl($currentPage - 1, $_GET['search'] ?? '')) ?>"
               class="owner-page-btn <?= $currentPage <= 1 ? 'disabled' : '' ?>">
                <iconify-icon icon="tabler:arrow-left"></iconify-icon>
            </a>

            <?php for ($p = 1; $p <= $totalPages; $p++): ?>
                <a href="<?= htmlspecialchars(ownerPageUrl($p, $_GET['search'] ?? '')) ?>"
                   class="owner-page-btn <?= $p === $currentPage ? 'active' : '' ?>">
                    <?= $p ?>
                </a>
            <?php endfor; ?>

            <a href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(ownerPageUrl($currentPage + 1, $_GET['search'] ?? '')) ?>"
               class="owner-page-btn <?= $currentPage >= $totalPages ? 'disabled' : '' ?>">
                <iconify-icon icon="tabler:arrow-right"></iconify-icon>
            </a>
        </div>
    </div>
</div>

<div class="owner-modal-overlay" id="ownerModalOverlay">
    <div class="owner-modal-box">
        <div class="owner-modal-icon" id="ownerModalIcon" style="background:#F1EFE8;color:#5F5E5A;">
            <iconify-icon icon="tabler:user-off"></iconify-icon>
        </div>
        <p class="owner-modal-title" id="ownerModalTitle">Nonaktifkan akun ini?</p>
        <p class="owner-modal-desc"  id="ownerModalDesc">Anda yakin ingin menonaktifkan akun ini?</p>
        <form method="POST" action="index.php?page=owners">
            <input type="hidden" name="owner_id" id="ownerModalId">
            <input type="hidden" name="action"   id="ownerModalAction">
            <div class="owner-modal-actions">
                <button type="button" class="owner-btn-batal" onclick="ownerCloseModal()">Batal</button>
                <button type="submit" class="owner-btn-konfirm" id="ownerModalKonfirm">Ya, Nonaktifkan</button>
            </div>
        </form>
    </div>
</div>