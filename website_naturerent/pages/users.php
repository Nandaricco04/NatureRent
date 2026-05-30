<?php
require_once __DIR__ . '/../repositories/user_repository.php';

$deleteError = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'delete_user') {
    $deleteId = max(0, (int) ($_POST['id_user'] ?? 0));

    if ($deleteId > 0) {
        $result = deleteRegularUser($deleteId);

        if ($result['ok']) {
            header('Location: index.php?page=users');
            exit;
        }

        $deleteError = 'User gagal dihapus. Periksa koneksi atau izin database.';
    }
}

$keyword = strtolower(trim($_GET['search'] ?? ''));
$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 10;

$users = getUsersByRole('user');

if ($keyword !== '') {
    $users = array_values(array_filter($users, function (array $user) use ($keyword): bool {
        $name = strtolower((string) ($user['nama'] ?? ''));
        $email = strtolower((string) ($user['email'] ?? ''));

        return str_contains($name, $keyword) || str_contains($email, $keyword);
    }));
}

$totalUsers = count($users);
$totalPages = max(1, (int) ceil($totalUsers / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleUsers = array_slice($users, $offset, $perPage);

$startNumber = $totalUsers === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalUsers);

function formatUserDate(array $user): string
{
    $dateValue = $user['created_at'] ?? $user['tanggal_daftar'] ?? null;

    if (!$dateValue) {
        return '-';
    }

    $timestamp = strtotime((string) $dateValue);

    if (!$timestamp) {
        return '-';
    }

    return date('d-m-Y', $timestamp);
}

function userPageUrl(int $page, string $keyword): string
{
    $params = ['page' => 'users', 'p' => $page];

    if ($keyword !== '') {
        $params['search'] = $keyword;
    }

    return 'index.php?' . http_build_query($params);
}
?>
<section class="content-card user-management-card">
    <div class="content-card-header">
        <h2>Daftar Pengguna</h2>

        <form class="user-search" method="GET">
            <input type="hidden" name="page" value="users">
            <label class="search-field">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <circle cx="11" cy="11" r="8"></circle>
                    <path d="m21 21-4.35-4.35"></path>
                </svg>
                <input
                    type="search"
                    name="search"
                    value="<?= htmlspecialchars($keyword) ?>"
                    placeholder="Cari user dari nama atau email"
                >
            </label>
            <a class="primary-button add-user-link" href="index.php?page=users&action=add">+ Tambah User</a>
        </form>
    </div>

    <?php if ($deleteError !== ''): ?>
        <div class="table-alert"><?= htmlspecialchars($deleteError) ?></div>
    <?php endif; ?>

    <div class="table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Nama Lengkap</th>
                    <th>Email</th>
                    <th>Password</th>
                    <th>Tanggal Daftar</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($visibleUsers)): ?>
                    <tr>
                        <td class="empty-table" colspan="6">Data pengguna belum tersedia.</td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($visibleUsers as $index => $user): ?>
                    <tr>
                        <td><?= $offset + $index + 1 ?></td>
                        <td><?= htmlspecialchars($user['nama'] ?? '-') ?></td>
                        <td><?= htmlspecialchars($user['email'] ?? '-') ?></td>
                        <td>********</td>
                        <td><?= htmlspecialchars(formatUserDate($user)) ?></td>
                        <td>
                            <div class="table-actions">
                                <a
                                    class="action-button edit"
                                    href="index.php?page=users&action=edit&id=<?= urlencode((string) ($user['id_user'] ?? '')) ?>"
                                    aria-label="Edit user"
                                >
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 20h9"></path>
                                        <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                                    </svg>
                                </a>
                                <button
                                    class="action-button delete js-delete-user"
                                    type="button"
                                    data-user-id="<?= htmlspecialchars((string) ($user['id_user'] ?? '')) ?>"
                                    data-user-name="<?= htmlspecialchars($user['nama'] ?? 'User') ?>"
                                    aria-label="Hapus user"
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

    <div class="table-footer">
        <p>Showing <?= $startNumber ?> of <?= $totalUsers ?></p>

        <div class="pagination">
            <a
                class="page-button <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(userPageUrl($currentPage - 1, $keyword)) ?>"
                aria-label="Halaman sebelumnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M19 12H5"></path>
                    <path d="m12 19-7-7 7-7"></path>
                </svg>
            </a>

            <?php for ($pageNumber = 1; $pageNumber <= $totalPages; $pageNumber++): ?>
                <a
                    class="page-button <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                    href="<?= htmlspecialchars(userPageUrl($pageNumber, $keyword)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endfor; ?>

            <a
                class="page-button <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(userPageUrl($currentPage + 1, $keyword)) ?>"
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

<div class="delete-modal" data-delete-modal hidden>
    <div class="delete-modal-backdrop" data-delete-cancel></div>
    <section class="delete-dialog" role="dialog" aria-modal="true" aria-labelledby="delete-title">
        <div class="delete-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <path d="M3 6h18"></path>
                <path d="M8 6V4h8v2"></path>
                <path d="M19 6l-1 14H6L5 6"></path>
                <path d="M10 11v6"></path>
                <path d="M14 11v6"></path>
            </svg>
        </div>

        <h2 id="delete-title">Hapus User?</h2>
        <p>kamu akan menghapus<br>akun ini, yakin?</p>

        <div class="delete-actions">
            <button class="secondary-button delete-cancel" type="button" data-delete-cancel>Batal</button>
            <form method="POST" action="index.php?page=users">
                <input type="hidden" name="action" value="delete_user">
                <input type="hidden" name="id_user" value="" data-delete-user-id>
                <button class="danger-button" type="submit">Ya, Hapus</button>
            </form>
        </div>
    </section>
</div>
