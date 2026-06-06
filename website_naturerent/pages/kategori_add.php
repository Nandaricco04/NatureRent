<?php
require_once __DIR__ . '/../repositories/kategori_repository.php';

$formError = '';
$inputValue = (string) ($_POST['name'] ?? '');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST' && ($_POST['action'] ?? '') === 'create_category') {
    $inputValue = trim((string) ($_POST['name'] ?? ''));

    if ($inputValue === '') {
        $formError = 'Nama kategori wajib diisi.';
    } else {
        $result = createAdminCategory($inputValue);

        if ($result['ok']) {
            header('Location: index.php?page=kategori');
            exit;
        }

        $formError = 'Kategori gagal ditambahkan. Periksa koneksi atau izin database.';
    }
}
?>
<div class="kategori-modal-overlay">
    <section class="kategori-modal" role="dialog" aria-modal="true" aria-labelledby="kategori-modal-title">
        <header class="kategori-modal-header">
            <h2 id="kategori-modal-title">Tambah Kategori</h2>
            <a class="kategori-modal-close" href="index.php?page=kategori" aria-label="Tutup modal">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M18 6 6 18"></path>
                    <path d="m6 6 12 12"></path>
                </svg>
            </a>
        </header>

        <form class="kategori-modal-form" method="POST" action="index.php?page=kategori&action=add">
            <input type="hidden" name="action" value="create_category">

            <label for="kategori-name">Nama Kategori</label>
            <input id="kategori-name" name="name" value="<?= htmlspecialchars($inputValue) ?>" autocomplete="off" autofocus>

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
