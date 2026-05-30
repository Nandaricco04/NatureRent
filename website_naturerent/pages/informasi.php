<?php
require_once __DIR__ . '/../repositories/informasi_repository.php';

$deleteError = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'delete_informasi') {
    $deleteId = max(0, (int) ($_POST['id_informasi'] ?? 0));

    if ($deleteId > 0) {
        $repo   = new InformasiRepository();
        $result = $repo->deleteInformasi($deleteId);

        if ($result) {
            header('Location: index.php?page=informasi');
            exit;
        }

        $deleteError = 'Informasi gagal dihapus. Periksa koneksi atau izin database.';
    }
}

$currentPage  = max(1, (int) ($_GET['p'] ?? 1));
$perPage      = 10;

$repo          = new InformasiRepository();
$informasiList = $repo->getAllInformasi();

$totalItems  = count($informasiList);
$totalPages  = max(1, (int) ceil($totalItems / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset      = ($currentPage - 1) * $perPage;
$visibleItems = array_slice($informasiList, $offset, $perPage);

$startNumber = $totalItems === 0 ? 0 : $offset + 1;

function informasiPageUrl(int $page): string
{
    return 'index.php?' . http_build_query(['page' => 'informasi', 'p' => $page]);
}
?>

<section class="content-card user-management-card">
    <div class="content-card-header">
        <h2>Informasi</h2>
        <a class="primary-button" href="index.php?page=informasi&action=add">+ Tambah Informasi</a>
    </div>

    <?php if ($deleteError !== ''): ?>
        <div class="table-alert"><?= htmlspecialchars($deleteError) ?></div>
    <?php endif; ?>

    <div class="table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Judul</th>
                    <th>Deskripsi</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($visibleItems)): ?>
                    <tr>
                        <td class="empty-table" colspan="4">Data informasi belum tersedia.</td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($visibleItems as $index => $item): ?>
                    <tr>
                        <td><?= $offset + $index + 1 ?></td>
                        <td><?= htmlspecialchars($item['title'] ?? '-') ?></td>
                        <td><?= nl2br(htmlspecialchars($item['description'] ?? '-')) ?></td>
                        <td>
                            <div class="table-actions">
                                <a
                                    class="action-button edit"
                                    href="index.php?page=informasi&action=edit&id=<?= urlencode((string) ($item['id_informasi'] ?? '')) ?>"
                                    aria-label="Edit informasi"
                                >
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 20h9"></path>
                                        <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                                    </svg>
                                </a>
                                <button
                                    class="action-button delete js-delete-informasi"
                                    type="button"
                                    data-informasi-id="<?= htmlspecialchars((string) ($item['id_informasi'] ?? '')) ?>"
                                    aria-label="Hapus informasi"
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
        <p>Showing <?= $startNumber ?> of <?= $totalItems ?></p>

        <div class="pagination">
            <a
                class="page-button <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(informasiPageUrl($currentPage - 1)) ?>"
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
                    href="<?= htmlspecialchars(informasiPageUrl($pageNumber)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endfor; ?>

            <a
                class="page-button <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(informasiPageUrl($currentPage + 1)) ?>"
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

<!-- MODAL HAPUS -->
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

        <h2 id="delete-title">Hapus Informasi?</h2>
        <p>kamu akan menghapus<br>informasi ini, yakin?</p>

        <div class="delete-actions">
            <button class="secondary-button" type="button" data-delete-cancel>Batal</button>
            <form method="POST" action="index.php?page=informasi">
                <input type="hidden" name="action" value="delete_informasi">
                <input type="hidden" name="id_informasi" value="" data-delete-informasi-id>
                <button class="danger-button" type="submit">Ya, Hapus</button>
            </form>
        </div>
    </section>
</div>

<script>
(function () {
    const modal      = document.querySelector('[data-delete-modal]');
    const idInput    = document.querySelector('[data-delete-informasi-id]');
    const cancelBtns = document.querySelectorAll('[data-delete-cancel]');
    const triggers   = document.querySelectorAll('.js-delete-informasi');

    function openModal(id) {
        idInput.value = id;
        modal.hidden  = false;
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        modal.hidden  = true;
        document.body.style.overflow = '';
    }

    triggers.forEach(btn => {
        btn.addEventListener('click', () => openModal(btn.dataset.informasiId));
    });

    cancelBtns.forEach(btn => {
        btn.addEventListener('click', closeModal);
    });
})();
</script>