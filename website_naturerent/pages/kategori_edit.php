<?php
require_once __DIR__ . '/../repositories/kategori_repository.php';

$formError = '';
$editCategoryId = (string) ($_GET['id'] ?? $_POST['id_category'] ?? '');
$editCategory = findAdminCategoryById($editCategoryId);

if ($editCategory === null) {
    $formError = 'Data kategori tidak ditemukan.';
    $editCategory = [
        'id_category' => $editCategoryId,
        'name' => (string) ($_POST['name'] ?? ''),
        '_total_listing' => 0,
        '_listing_aktif' => 0,
    ];
}

$inputValue = (string) ($_POST['name'] ?? adminCategoryName($editCategory));

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST' && ($_POST['action'] ?? '') === 'update_category') {
    $editCategoryId = (string) ($_POST['id_category'] ?? '');
    $inputValue = trim((string) ($_POST['name'] ?? ''));

    if ($editCategoryId === '') {
        $formError = 'Data kategori tidak valid.';
    } elseif ($inputValue === '') {
        $formError = 'Nama kategori wajib diisi.';
    } else {
        $result = updateAdminCategory($editCategoryId, $inputValue);

        if ($result['ok']) {
            header('Location: index.php?page=kategori');
            exit;
        }

        $formError = 'Kategori gagal diperbarui. Periksa koneksi atau izin database.';
    }
}
?>
<div class="kategori-modal-overlay">
    <section class="kategori-modal" role="dialog" aria-modal="true" aria-labelledby="kategori-modal-title">
        <header class="kategori-modal-header">
            <h2 id="kategori-modal-title">Edit Kategori</h2>
            <a class="kategori-modal-close" href="index.php?page=kategori" aria-label="Tutup modal">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M18 6 6 18"></path>
                    <path d="m6 6 12 12"></path>
                </svg>
            </a>
        </header>

        <form class="kategori-modal-form" method="POST" action="index.php?page=kategori&action=edit&id=<?= urlencode((string) ($editCategory['id_category'] ?? '')) ?>">
            <input type="hidden" name="action" value="update_category">
            <input type="hidden" name="id_category" value="<?= htmlspecialchars((string) ($editCategory['id_category'] ?? '')) ?>">

            <label for="kategori-name">Nama Kategori</label>
            <input id="kategori-name" name="name" value="<?= htmlspecialchars($inputValue) ?>" autocomplete="off" autofocus>

            <div class="kategori-modal-meta">
                <p>Total Listing: <?= adminCategoryTotalListing($editCategory) ?></p>
                <p>Listing Aktif: <?= adminCategoryActiveListing($editCategory) ?></p>
            </div>

            <?php if ($formError !== ''): ?>
                <p class="kategori-modal-error"><?= htmlspecialchars($formError) ?></p>
            <?php endif; ?>

            <div class="kategori-modal-actions">
                <a class="kategori-modal-cancel" href="index.php?page=kategori">Batal</a>
                <button class="kategori-modal-submit" type="submit">Simpan</button>
            </div>
        </form>
    </section>
</div>
