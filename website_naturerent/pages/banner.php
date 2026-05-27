<?php
require_once __DIR__ . '/../repositories/banner_repository.php';

$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 6;
$formErrors = [];
$oldInput = [
    'id_destination' => '',
    'nama_destination' => '',
    'lokasi_id' => '',
    'gambar' => '',
];

function bannerPageUrl(int $page): string
{
    return 'index.php?' . http_build_query(['page' => 'banner', 'p' => $page]);
}

$locations = getLocations();
$destinations = getDestinations();
$actionModal = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'delete_destination') {
    $deleteId = (string) ($_POST['id_destination'] ?? '');
    $deleteDestination = null;

    foreach ($destinations as $destination) {
        if (destinationId($destination) === $deleteId) {
            $deleteDestination = $destination;
            break;
        }
    }

    if ($deleteDestination === null) {
        $formErrors[] = 'Data banner tidak ditemukan.';
    } else {
        $deleteResult = deleteDestination((int) $deleteId);

        if ($deleteResult['ok']) {
            $imageUrl = destinationImage($deleteDestination);

            if ($imageUrl !== '') {
                deleteDestinationImage($imageUrl);
            }

            header('Location: index.php?page=banner');
            exit;
        }

        $formErrors[] = 'Banner gagal dihapus. Periksa koneksi atau izin database.';
    }
}

if (($_GET['action'] ?? '') === 'add') {
    ob_start();
    require __DIR__ . '/banner_add.php';
    $actionModal = ob_get_clean();
} elseif (($_GET['action'] ?? '') === 'edit') {
    ob_start();
    require __DIR__ . '/banner_edit.php';
    $actionModal = ob_get_clean();
}

$totalDestinations = count($destinations);
$totalPages = max(1, (int) ceil($totalDestinations / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleDestinations = array_slice($destinations, $offset, $perPage);

$startNumber = $totalDestinations === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalDestinations);
?>
<section class="content-card destination-card">
    <div class="destination-header">
        <h2>Banner Destinasi</h2>

        <a class="destination-upload" href="index.php?page=banner&action=add" aria-label="Upload banner destinasi">
            <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M12 16V4"></path>
                <path d="m7 9 5-5 5 5"></path>
                <path d="M5 20h14"></path>
            </svg>
            <span>Upload Banner</span>
        </a>
    </div>

    <?php if (!empty($formErrors)): ?>
        <div class="destination-alert">
            <?= htmlspecialchars(implode(' ', $formErrors)) ?>
        </div>
    <?php endif; ?>

    <div class="destination-content">
        <?php if (empty($visibleDestinations)): ?>
            <div class="destination-empty">belum ada destinasi</div>
        <?php else: ?>
            <div class="destination-grid">
                <?php foreach ($visibleDestinations as $destination): ?>
                    <?php
                    $destinationId = destinationId($destination);
                    $imageUrl = destinationImage($destination);
                    ?>
                    <article class="destination-item">
                        <?php if ($imageUrl !== ''): ?>
                            <img src="<?= htmlspecialchars($imageUrl) ?>" alt="<?= htmlspecialchars(destinationTitle($destination)) ?>">
                        <?php else: ?>
                            <div class="destination-image-placeholder"></div>
                        <?php endif; ?>

                        <div class="destination-body">
                            <h3><?= htmlspecialchars(destinationTitle($destination)) ?></h3>
                            <p><?= htmlspecialchars(destinationLocationName($destination, $locations)) ?></p>

                            <div class="destination-actions">
                                <a
                                    class="destination-action edit"
                                    href="index.php?page=banner&action=edit&id=<?= urlencode((string) $destinationId) ?>"
                                    aria-label="Edit destinasi"
                                >
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 20h9"></path>
                                        <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                                    </svg>
                                </a>
                                <button
                                    class="destination-action delete"
                                    type="button"
                                    data-delete-banner
                                    data-banner-id="<?= htmlspecialchars((string) $destinationId) ?>"
                                    data-banner-name="<?= htmlspecialchars(destinationTitle($destination)) ?>"
                                    aria-label="Hapus destinasi"
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
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>

    <div class="destination-footer">
        <p>Menampilkan <?= $startNumber ?>-<?= $endNumber ?> dari <?= $totalDestinations ?> data</p>

        <div class="destination-pagination">
            <a
                class="destination-page <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(bannerPageUrl($currentPage - 1)) ?>"
                aria-label="Halaman sebelumnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M19 12H5"></path>
                    <path d="m12 19-7-7 7-7"></path>
                </svg>
            </a>

            <?php for ($pageNumber = 1; $pageNumber <= $totalPages; $pageNumber++): ?>
                <a
                    class="destination-page <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                    href="<?= htmlspecialchars(bannerPageUrl($pageNumber)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endfor; ?>

            <a
                class="destination-page <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(bannerPageUrl($currentPage + 1)) ?>"
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

<div class="delete-banner-modal" data-delete-banner-modal hidden>
    <div class="delete-banner-backdrop" data-delete-banner-cancel></div>
    <section class="delete-banner-dialog" role="dialog" aria-modal="true" aria-labelledby="delete-banner-title">
        <div class="delete-banner-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <path d="M3 6h18"></path>
                <path d="M8 6V4h8v2"></path>
                <path d="M19 6l-1 14H6L5 6"></path>
                <path d="M10 11v6"></path>
                <path d="M14 11v6"></path>
            </svg>
        </div>

        <h2 id="delete-banner-title">Hapus Banner?</h2>
        <p>kamu akan menghapus<br>banner ini, yakin?</p>

        <div class="delete-banner-actions">
            <button class="delete-banner-cancel" type="button" data-delete-banner-cancel>Batal</button>
            <form method="POST" action="index.php?page=banner">
                <input type="hidden" name="action" value="delete_destination">
                <input type="hidden" name="id_destination" value="" data-delete-banner-id>
                <button class="delete-banner-confirm" type="submit">Ya, Hapus</button>
            </form>
        </div>
    </section>
</div>

<?= $actionModal ?>
