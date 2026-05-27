<?php
require_once __DIR__ . '/../repositories/banner_repository.php';

$formErrors = $formErrors ?? [];
$locations = $locations ?? getLocations();
$oldInput = $oldInput ?? [
    'id_destination' => '',
    'nama_destination' => '',
    'lokasi_id' => '',
    'gambar' => '',
];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'create_destination') {
    $oldInput['nama_destination'] = trim($_POST['nama_destination'] ?? '');
    $oldInput['lokasi_id'] = trim($_POST['lokasi_id'] ?? '');

    if ($oldInput['nama_destination'] === '') {
        $formErrors[] = 'Nama destinasi wajib diisi.';
    }

    if ($oldInput['lokasi_id'] === '') {
        $formErrors[] = 'Lokasi destinasi wajib dipilih.';
    }

    if (empty($_FILES['gambar']['tmp_name']) || ($_FILES['gambar']['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        $formErrors[] = 'Gambar destinasi wajib diupload.';
    }

    if (empty($formErrors)) {
        $imageUpload = uploadDestinationImage($_FILES['gambar']);

        if (!$imageUpload['ok']) {
            $formErrors[] = $imageUpload['error'];
        } else {
            $createResult = createDestination($oldInput['nama_destination'], (int) $oldInput['lokasi_id'], $imageUpload['url']);

            if ($createResult['ok']) {
                header('Location: index.php?page=banner');
                exit;
            }

            $formErrors[] = 'Data destinasi gagal disimpan. Periksa tabel destination atau izin database.';
        }
    }
}

$selectedLocationName = '';

foreach ($locations as $location) {
    if (locationId($location) === $oldInput['lokasi_id']) {
        $selectedLocationName = locationName($location);
        break;
    }
}
?>
<div
    class="destination-modal"
    data-destination-modal
    data-edit-mode="false"
    data-return-url="index.php?page=banner"
>
    <div class="destination-modal-backdrop" data-close-destination-modal></div>
    <section class="destination-dialog" role="dialog" aria-modal="true" aria-labelledby="destination-modal-title">
        <div class="destination-dialog-header">
            <div class="destination-dialog-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                    <circle cx="8.5" cy="10.5" r="1.5"></circle>
                    <path d="m21 16-5-5L5 19"></path>
                </svg>
            </div>
            <div>
                <h2 id="destination-modal-title">Informasi Banner Destinasi</h2>
                <p>Isi Informasi banner destinasi dengan lengkap</p>
            </div>
            <button class="destination-close" type="button" data-close-destination-modal aria-label="Tutup modal">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M18 6 6 18"></path>
                    <path d="m6 6 12 12"></path>
                </svg>
            </button>
        </div>

        <form class="destination-form" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" value="create_destination">

            <label class="destination-field">
                <span>Nama Destinasi</span>
                <span class="destination-input-shell">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M6 7h12"></path>
                        <path d="M6 12h12"></path>
                        <path d="M6 17h12"></path>
                        <path d="M9 4v16"></path>
                        <path d="M15 4v16"></path>
                    </svg>
                    <input
                        type="text"
                        name="nama_destination"
                        value="<?= htmlspecialchars($oldInput['nama_destination']) ?>"
                        placeholder="Masukkan nama destinasi"
                        required
                    >
                </span>
            </label>

            <label class="destination-field">
                <span>Lokasi Destinasi</span>
                <span class="destination-input-shell">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M12 21s7-5.2 7-11a7 7 0 0 0-14 0c0 5.8 7 11 7 11Z"></path>
                        <circle cx="12" cy="10" r="2"></circle>
                    </svg>
                    <input type="hidden" name="lokasi_id" value="<?= htmlspecialchars($oldInput['lokasi_id']) ?>" data-location-value required>
                    <button class="destination-location-trigger" type="button" data-location-trigger>
                        <span data-location-label><?= htmlspecialchars($selectedLocationName !== '' ? $selectedLocationName : 'Pilih Lokasi') ?></span>
                    </button>
                    <svg class="destination-select-arrow" viewBox="0 0 24 24" aria-hidden="true">
                        <path d="m6 9 6 6 6-6"></path>
                    </svg>
                    <span class="destination-location-menu" data-location-menu hidden>
                        <?php if (empty($locations)): ?>
                            <span class="destination-location-empty">Lokasi belum tersedia</span>
                        <?php endif; ?>
                        <?php foreach ($locations as $location): ?>
                            <?php $id = locationId($location); ?>
                            <?php if ($id !== ''): ?>
                                <button
                                    class="destination-location-option <?= $oldInput['lokasi_id'] === $id ? 'is-selected' : '' ?>"
                                    type="button"
                                    data-location-option
                                    data-location-id="<?= htmlspecialchars($id) ?>"
                                    data-location-name="<?= htmlspecialchars(locationName($location)) ?>"
                                >
                                    <?= htmlspecialchars(locationName($location)) ?>
                                </button>
                            <?php endif; ?>
                        <?php endforeach; ?>
                    </span>
                </span>
            </label>

            <label class="destination-field">
                <span>Gambar Destinasi</span>
                <span class="destination-upload-field">
                    <span class="destination-file-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 16V4"></path>
                            <path d="m7 9 5-5 5 5"></path>
                            <path d="M5 20h14"></path>
                        </svg>
                    </span>
                    <span class="destination-file-copy">
                        <strong>Upload File Gambar</strong>
                        <small>Format: JPG, PNG, JPEG. Maksimal 3 MB</small>
                    </span>
                    <span class="destination-file-button">Upload File</span>
                    <input type="file" name="gambar" accept="image/png,image/jpeg,image/jpg" data-destination-file required>
                </span>
            </label>

            <div class="destination-preview" data-destination-preview hidden>
                <img src="" alt="Preview gambar destinasi">
                <span data-destination-file-name></span>
            </div>

            <div class="destination-form-actions">
                <button class="destination-cancel" type="button" data-close-destination-modal>Batal</button>
                <button class="destination-save" type="submit">Simpan</button>
            </div>
        </form>
    </section>
</div>
