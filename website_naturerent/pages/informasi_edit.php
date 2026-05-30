<?php
require_once __DIR__ . '/../repositories/informasi_repository.php';

$repo          = new InformasiRepository();
$informasiId   = max(0, (int) ($_GET['id'] ?? 0));
$informasi     = $informasiId > 0 ? $repo->getInformasiById($informasiId) : null;
$formErrors    = [];
$formValues    = [
    'title'       => $informasi['title'] ?? '',
    'description' => $informasi['description'] ?? '',
];

if (!$informasi) {
    $formErrors[] = 'Data informasi tidak ditemukan.';
}

if ($informasi && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $formValues['title']       = trim($_POST['title'] ?? '');
    $formValues['description'] = trim($_POST['description'] ?? '');

    if ($formValues['title'] === '') {
        $formErrors[] = 'Judul wajib diisi.';
    }

    if ($formValues['description'] === '') {
        $formErrors[] = 'Deskripsi wajib diisi.';
    }

    if (empty($formErrors)) {
        $result = $repo->updateInformasi($informasiId, $formValues['title'], $formValues['description']);

        if ($result) {
            header('Location: index.php?page=informasi');
            exit;
        }

        $formErrors[] = 'Perubahan gagal disimpan. Periksa koneksi atau izin database.';
    }
}

function formIcon(string $name): string
{
    $icons = [
        'info'    => '<circle cx="12" cy="12" r="10"></circle><path d="M12 16v-4"></path><path d="M12 8h.01"></path>',
        'title'   => '<path d="M4 6h16M4 12h16M4 18h7"></path>',
        'desc'    => '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><path d="M14 2v6h6"></path><path d="M16 13H8"></path><path d="M16 17H8"></path><path d="M10 9H8"></path>',
        'chevron' => '<path d="m9 18 6-6-6-6"></path>',
    ];

    return '<svg viewBox="0 0 24 24" aria-hidden="true">' . ($icons[$name] ?? '') . '</svg>';
}
?>
<section class="content-card add-user-card">
    <form class="add-user-form" method="POST" action="index.php?page=informasi&action=edit&id=<?= urlencode((string) $informasiId) ?>">
        <div class="add-user-body">
            <div class="form-intro">
                <div class="form-intro-icon">
                    <?= formIcon('info') ?>
                </div>
                <div>
                    <h2>Edit Informasi</h2>
                    <p>Update informasi yang diinginkan</p>
                </div>
            </div>

            <?php if (!empty($formErrors)): ?>
                <div class="form-alert">
                    <?= htmlspecialchars($formErrors[0]) ?>
                </div>
            <?php endif; ?>

            <?php if ($informasi): ?>
                <div class="add-user-grid" style="grid-template-columns: 1fr;">
                    <label class="form-field">
                        <span>Judul</span>
                        <div class="input-shell">
                            <?= formIcon('title') ?>
                            <input
                                type="text"
                                name="title"
                                value="<?= htmlspecialchars($formValues['title']) ?>"
                                placeholder="Masukkan Judul"
                                required
                            >
                        </div>
                    </label>

                    <label class="form-field">
                        <span>Deskripsi</span>
                        <div class="input-shell input-shell--textarea">
                            <?= formIcon('desc') ?>
                            <textarea
                                name="description"
                                placeholder="Masukkan Deskripsi"
                                rows="6"
                                required
                            ><?= htmlspecialchars($formValues['description']) ?></textarea>
                        </div>
                    </label>
                </div>
            <?php endif; ?>
        </div>

        <div class="add-user-actions">
            <a class="secondary-button" href="index.php?page=informasi">Batal</a>
            <?php if ($informasi): ?>
                <button class="primary-button save-user-button" type="submit">
                    Simpan Perubahan
                    <?= formIcon('chevron') ?>
                </button>
            <?php endif; ?>
        </div>
    </form>
</section>