<?php
require_once __DIR__ . '/../repositories/kategori_repository.php';

$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 10;
$modalAction = $_GET['action'] ?? '';
$deleteError = '';

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST' && ($_POST['action'] ?? '') === 'delete_category') {
    $deleteId = (string) ($_POST['id_category'] ?? '');

    if ($deleteId !== '') {
        $result = deleteAdminCategory($deleteId);

        if ($result['ok']) {
            header('Location: index.php?page=kategori');
            exit;
        }

        $deleteError = 'Kategori gagal dihapus. Pastikan tidak ada produk yang masih memakai kategori ini.';
    }
}

$categories = getAdminCategories();
$totalCategories = count($categories);
$totalPages = max(1, (int) ceil($totalCategories / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleCategories = array_slice($categories, $offset, $perPage);
$startNumber = $totalCategories === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalCategories);

function kategoriPageUrl(int $page): string
{
    return 'index.php?' . http_build_query(['page' => 'kategori', 'p' => $page]);
}

function kategoriPaginationRange(int $currentPage, int $totalPages): array
{
    $start = max(1, min($currentPage - 1, $totalPages - 2));
    $end = min($totalPages, $start + 2);

    return range($start, $end);
}
?>
<section class="kategori-card">
    <div class="kategori-header">
        <h2>Kategori Alat</h2>

        <div class="kategori-actions">
            <a class="kategori-button kategori-button-outline" href="index.php?page=kategori&action=produk">
                <span>Lihat Produk</span>
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M5 12h14"></path>
                    <path d="m13 5 7 7-7 7"></path>
                </svg>
            </a>
            <a class="kategori-button" href="index.php?page=kategori&action=add">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M12 5v14"></path>
                    <path d="M5 12h14"></path>
                </svg>
                <span>Tambah Kategori</span>
            </a>
        </div>
    </div>

    <div class="kategori-table-wrap">
        <table class="kategori-table">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Nama Kategori</th>
                    <th>Total Listing</th>
                    <th>Listing Aktif</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($visibleCategories)): ?>
                    <tr>
                        <td class="kategori-empty" colspan="5">Data kategori alat belum tersedia.</td>
                    </tr>
                <?php endif; ?>

                <?php if ($deleteError !== ''): ?>
                    <tr>
                        <td class="kategori-empty" colspan="5"><?= htmlspecialchars($deleteError) ?></td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($visibleCategories as $index => $category): ?>
                    <?php
                    $categoryId = (string) ($category['id_category'] ?? '');
                    $categoryName = adminCategoryName($category);
                    ?>
                    <tr>
                        <td><?= $offset + $index + 1 ?></td>
                        <td><?= htmlspecialchars($categoryName) ?></td>
                        <td><?= adminCategoryTotalListing($category) ?></td>
                        <td><?= adminCategoryActiveListing($category) ?></td>
                        <td>
                            <div class="kategori-row-actions">
                                <a
                                    class="kategori-icon-button edit"
                                    href="index.php?page=kategori&action=edit&id=<?= urlencode($categoryId) ?>"
                                    aria-label="Edit kategori <?= htmlspecialchars($categoryName) ?>"
                                >
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 20h9"></path>
                                        <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                                    </svg>
                                </a>
                                <button
                                    class="kategori-icon-button delete"
                                    type="button"
                                    data-delete-category
                                    data-category-id="<?= htmlspecialchars($categoryId) ?>"
                                    aria-label="Hapus kategori <?= htmlspecialchars($categoryName) ?>"
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

    <div class="kategori-footer">
        <p>Menampilkan <?= $startNumber ?>-<?= $endNumber ?> dari <?= $totalCategories ?> data</p>

        <div class="kategori-pagination">
            <a
                class="kategori-page-button <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(kategoriPageUrl($currentPage - 1)) ?>"
                aria-label="Halaman sebelumnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M19 12H5"></path>
                    <path d="m12 19-7-7 7-7"></path>
                </svg>
            </a>

            <?php foreach (kategoriPaginationRange($currentPage, $totalPages) as $pageNumber): ?>
                <a
                    class="kategori-page-button <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                    href="<?= htmlspecialchars(kategoriPageUrl($pageNumber)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endforeach; ?>

            <a
                class="kategori-page-button <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(kategoriPageUrl($currentPage + 1)) ?>"
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

<?php
if ($modalAction === 'add') {
    include __DIR__ . '/kategori_add.php';
} elseif ($modalAction === 'edit') {
    include __DIR__ . '/kategori_edit.php';
}
?>

<div class="kategori-modal-overlay" data-delete-category-modal hidden>
    <section class="kategori-delete-modal" role="dialog" aria-modal="true" aria-labelledby="kategori-delete-title">
        <div class="kategori-delete-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <path d="M3 6h18"></path>
                <path d="M8 6V4h8v2"></path>
                <path d="M19 6l-1 14H6L5 6"></path>
                <path d="M10 11v6"></path>
                <path d="M14 11v6"></path>
            </svg>
        </div>

        <h2 id="kategori-delete-title">Hapus kategori ini?</h2>
        <p>Anda yakin ingin<br>menghapus kategori ini?</p>

        <div class="kategori-delete-actions">
            <button class="kategori-modal-cancel" type="button" data-delete-category-cancel>Batal</button>
            <form method="POST" action="index.php?page=kategori">
                <input type="hidden" name="action" value="delete_category">
                <input type="hidden" name="id_category" value="" data-delete-category-id>
                <button class="kategori-delete-submit" type="submit">Ya, Hapus</button>
            </form>
        </div>
    </section>
</div>

<script>
(function () {
    const modal = document.querySelector('[data-delete-category-modal]');
    const idInput = document.querySelector('[data-delete-category-id]');
    const triggers = document.querySelectorAll('[data-delete-category]');
    const cancelButtons = document.querySelectorAll('[data-delete-category-cancel]');

    if (!modal || !idInput) return;

    function openModal(id) {
        idInput.value = id;
        modal.hidden = false;
    }

    function closeModal() {
        modal.hidden = true;
        idInput.value = '';
    }

    triggers.forEach((button) => {
        button.addEventListener('click', () => openModal(button.dataset.categoryId || ''));
    });

    cancelButtons.forEach((button) => {
        button.addEventListener('click', closeModal);
    });
})();
</script>
